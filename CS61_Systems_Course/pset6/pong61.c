#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netdb.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include <assert.h>
#include <pthread.h>
#include "serverinfo.h"
#include <math.h>
#include <time.h>

// constants for host, port, and user. 
static const char* pong_host = PONG_HOST;
static const char* pong_port = PONG_PORT;
static const char* pong_user = PONG_USER;
static struct addrinfo* pong_addr;

// globals
int nthreads = 0;                   // to keep track of total number of threads
int nrequests = 0;                  // to keep track of total number of requests
int nconns = 0;                     // to keep track of total number of connections
double resume_time = 0;             // resume time - set when server sends STOP signal

// mutex & condvar
pthread_mutex_t mutex;             // regular lock
pthread_mutex_t list_mutex;        // lock variable used at handling of lists
pthread_mutex_t connection_mutex;  // lock variable used at handling of connections

//this method checks if thread need to wait based on server STOP request
int wait_check();

//variable used to make main thread wait until new thread receives hander from server
pthread_cond_t condvar;

// TIME HELPERS
double elapsed_base = 0;

// timestamp()
//    Return the current absolute time as a real number of seconds.
double timestamp(void) {
    struct timeval now;
    gettimeofday(&now, NULL);
    return now.tv_sec + (double) now.tv_usec / 1000000;
}

// elapsed()
//    Return the number of seconds that have elapsed since `elapsed_base`.
double elapsed(void) {
    return timestamp() - elapsed_base;
}


// HTTP CONNECTION MANAGEMENT

// http_connection
//    This object represents an open HTTP connection to a server.
typedef struct http_connection http_connection;
struct http_connection {
    int fd;                 // Socket file descriptor

    int state;              // Response parsing status (see below)
    int status_code;        // Response status code (e.g., 200, 402)
    size_t content_length;  // Content-Length value
    int has_content_length; // 1 iff Content-Length was provided
    int eof;                // 1 iff connection EOF has been reached

    size_t len;             // Length of response buffer
    int first_pass;         // first pass
    int buf_size;           // size of buf
    
    http_connection* next;  // linked list property
    char* buf;              // Response buffer
 };

// linked list
typedef struct conn_list conn_list;
struct conn_list {
  int count;
  http_connection* first;
};

//variable to access connections and their count
conn_list *my_conn_list;

// `http_connection::state` constants
#define HTTP_REQUEST 0      // Request not sent yet
#define HTTP_INITIAL 1      // Before first line of response
#define HTTP_HEADERS 2      // After first line of response, in headers
#define HTTP_BODY    3      // In body
#define HTTP_DONE    (-1)   // Body complete, available for a new request
#define HTTP_CLOSED  (-2)   // Body complete, connection closed
#define HTTP_BROKEN  (-3)   // Parse error

// drop constants
#define DIS_CONST  10000 // 10000
#define DIS_MAX  1000000 //1000000

// thread constants
#define MAX_THREADS 30
#define MAX_CONNECTIONS 30
#define MAX_REQ 6

// helper functions
char* http_truncate_response(http_connection* conn);
static int http_process_response_headers(http_connection* conn);
static int http_check_response_body(http_connection* conn);

static void usage(void);

// adding connection to head of linked list
int push_to_list (http_connection* conn)
{
  if (my_conn_list->count > 0)
  {
    http_connection* temp = my_conn_list->first;
    conn->next = temp;
  }
  my_conn_list->first = conn;
  my_conn_list->count++;  
  return 0;
}

// remove connection from linked list
int pop_from_list (http_connection* conn)
{
  if (my_conn_list->count == 0) return 0;
    
  int count = my_conn_list->count; 
  http_connection* cur = my_conn_list->first; 
  
  while (count > 0)
  {
    if (conn == cur)
    {
      if (cur->next) 
         my_conn_list->first = cur->next;
      else 
         my_conn_list->first = NULL;
    
      my_conn_list->count--;
      conn->next = NULL;
    
      return 0;
    }
    if (cur->next) 
      cur = cur->next; 
       
    count--;   
  }
  return 0;
}

// getting top connection from list
http_connection* recycle_connection ()
{
   if (my_conn_list->count > 0)
   {
     http_connection* myconn = my_conn_list->first;
     
     if (my_conn_list->count > 1)
     {
       http_connection* mynext = myconn->next;
       my_conn_list->first = mynext;
     }
     else
       my_conn_list->first = NULL; 
       
     my_conn_list->count--;
     return myconn;   
   }
   else 
     return NULL;
}

// http_connect(ai)
//    Open a new connection to the server described by `ai`. Returns a new
//    `http_connection` object for that server connection. Exits with an
//    error message if the connection fails.
http_connection* http_connect(const struct addrinfo* ai) {
 
     // connect to the server
    http_connection* conn;

     // logic for phase 3 - to check if we can reuse some of the connections
    if (my_conn_list->count > 0 || nconns >= MAX_CONNECTIONS)
    {
      while (my_conn_list->count == 0) usleep(1);

      pthread_mutex_lock(&list_mutex);
      conn = recycle_connection();
      pthread_mutex_unlock(&list_mutex);
      return conn;
    }
 
    
    // connect to the server
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        perror("socket");
        exit(1);
    }

    int yes = 1;
    (void) setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int));

    int r = connect(fd, ai->ai_addr, ai->ai_addrlen);
    if (r < 0) {
        perror("connect");
        exit(1);
    }

    // construct an http_connection object for this connection
    conn = (http_connection*) malloc(sizeof(http_connection));
    conn->fd = fd;
    conn->state = HTTP_REQUEST;
    conn->eof = 0;
    
    // lock  
    pthread_mutex_lock(&mutex);
    nconns++;
    pthread_mutex_unlock(&mutex);
    return conn;
}


// http_close(conn)
//    Close the HTTP connection `conn` and free its resources.
void http_close(http_connection* conn) {
    close(conn->fd);
    free(conn->buf);
    free(conn);
    
    pthread_mutex_lock(&mutex);
    nconns--;
    pthread_mutex_unlock(&mutex);
}


// http_send_request(conn, uri)
//    Send an HTTP POST request for `uri` to connection `conn`.
//    Exit on error.
void http_send_request(http_connection* conn, const char* uri) {
    assert(conn->state == HTTP_REQUEST || conn->state == HTTP_DONE);

    // prepare and write the request
    char reqbuf[BUFSIZ];
    size_t reqsz = sprintf(reqbuf,
                           "POST /%s/%s HTTP/1.0\r\n"
                           "Host: %s\r\n"
                           "Connection: keep-alive\r\n"
                           "\r\n",
                           pong_user, uri, pong_host);
    size_t pos = 0;
    while (pos < reqsz) {
        ssize_t nw = write(conn->fd, &reqbuf[pos], reqsz - pos);
        if (nw == 0)
            break;
        else if (nw == -1 && errno != EINTR && errno != EAGAIN) {
            perror("write");
            exit(1);
        } else if (nw != -1)
            pos += nw;
    }

    if (pos != reqsz) {
        fprintf(stderr, "%.3f sec: connection closed prematurely\n",
                elapsed());
        exit(1);
    }
     
    // clear response information
    conn->state = HTTP_INITIAL;
    conn->status_code = -1;
    conn->content_length = 0;
    conn->has_content_length = 0;
    conn->len = 0;
    conn->buf = malloc(BUFSIZ);
    conn->next = NULL;
    conn->buf_size = BUFSIZ;
    conn->first_pass = 0;
}


// http_receive_response_headers(conn)
//    Read the server's response headers. On return, `conn->status_code`
//    holds the server's status code. If the connection terminates
//    prematurely, `conn->status_code` is -1.
void http_receive_response_headers(http_connection* conn) {
    assert(conn->state != HTTP_REQUEST);
    if (conn->state < 0)
        return;
   
    while (http_process_response_headers(conn)) {
       
        ssize_t nr = read(conn->fd, &conn->buf[conn->len], BUFSIZ); 
    
        if (nr == 0)
            conn->eof = 1;
        else if (nr == -1 && errno != EINTR && errno != EAGAIN) {
            perror("read");
            exit(1);
        } else if (nr != -1)
            conn->len += nr;
    }

    // Status codes >= 500 mean we are overloading the server
    // and should exit.
    if (conn->status_code >= 500) {
        fprintf(stderr, "%.3f sec: exiting because of "
                "server status %d (%s)\n", elapsed(),
                conn->status_code, http_truncate_response(conn));
        exit(1);
    }
}


// http_receive_response_body(conn)
//    Read the server's response body. On return, `conn->buf` holds the
//    response body, which is `conn->len` bytes long and has been
//    null-terminated.
void http_receive_response_body(http_connection* conn) {

    assert(conn->state < 0 || conn->state == HTTP_BODY);
    if (conn->state < 0)
        return;

    while (http_check_response_body(conn)) {

        ssize_t nr = read(conn->fd, &conn->buf[conn->len], BUFSIZ);
       
        if (nr == 0)
            conn->eof = 1;
        else if (nr == -1 && errno != EINTR && errno != EAGAIN) {
            perror("read");
            exit(1);
        } else if (nr != -1)
            conn->len += nr;
    }
    // null-terminate body
    conn->buf[conn->len] = 0;
}


// http_truncate_response(conn)
//    Truncate the `conn` response text to a manageable length and return
//    that truncated text. Useful for error messages.
char* http_truncate_response(http_connection* conn) {
    char *eol = strchr(conn->buf, '\n');
    if (eol)
        *eol = 0;
    if (strnlen(conn->buf, 100) >= 100)
        conn->buf[100] = 0;
    return conn->buf;
}


// MAIN PROGRAM

typedef struct pong_args {
    int x;
    int y;
    int duration;
    char color[5];
} pong_args;


// method to check if thread need to wait in case server might have sent STOP message
int wait_check()
{     
  if (resume_time == 0) return 0;
  
  pthread_mutex_lock(&connection_mutex);

  double current_time = timestamp() * 1000; 
  
  double wait = resume_time - current_time;
  
  useconds_t wait_microns = (useconds_t) wait*1000;
     
  if(resume_time > 0 ) usleep(wait_microns);
  
  resume_time = 0;
  
  pthread_mutex_unlock(&connection_mutex);
  
  return 0;
}

// pong_thread(threadarg)
//    Connect to the server at the position indicated by `threadarg`
//    (which is a pointer to a `pong_args` structure).
void* pong_thread(void* threadarg) {
    pthread_detach(pthread_self());

    // Copy thread arguments onto our stack.
    pong_args pa = *((pong_args*) threadarg);

    char url[256];
    snprintf(url, sizeof(url), "move?x=%d&y=%d&style=%s&duration=%d",
             pa.x, pa.y, pa.color, pa.duration);

    //checking if thread need to wait for server to get ready
    wait_check();
    
    http_connection* conn = http_connect(pong_addr);
    http_send_request(conn, url);
    http_receive_response_headers(conn);

    //logic for phase 1
    while (conn->state == HTTP_BROKEN || conn->status_code == -1)
      {
	//removing connection from list
        pthread_mutex_lock(&list_mutex);
        int n = pop_from_list(conn);
        pthread_mutex_unlock(&list_mutex);
        
	//closing connection
        http_close(conn);
        
        // exponential backoff
        int multiplier = pow(2,nrequests);
        int sleeptime = multiplier*DIS_CONST;
        if (sleeptime > DIS_MAX) sleeptime = DIS_MAX;
        usleep(sleeptime);
	
	//sending request again
        wait_check();
        conn = http_connect(pong_addr);
        http_send_request(conn, url);
        
	//increasing number of request
        pthread_mutex_lock(&mutex);
        nrequests++;
        pthread_mutex_unlock(&mutex);
        
        //receiving header
        http_receive_response_headers(conn);        
      }
    
    nrequests = 0;
    
    //logic for phase 2, receive body after this so that there is no delay
    pthread_cond_signal(&condvar);
      
    http_receive_response_body(conn);

    double result = strtod(conn->buf, NULL);
    if (result < 0) {
        fprintf(stderr, "%.3f sec: server returned error: %s\n",
                elapsed(), http_truncate_response(conn));
                
        
        exit(1);
    }
    
    //logic for phase 4
    if (result > 0)
    {
      pthread_mutex_lock(&connection_mutex);

      //calculating resume time
      double result_microns = (unsigned long) result *1000;
      
      double time_stamp = timestamp();
      
      double current_time = time_stamp*1000;
      
      resume_time = current_time + result;

      pthread_mutex_unlock(&connection_mutex);
    }

    //decreasing total number of thread
    pthread_mutex_lock(&mutex);
    --nthreads;
    pthread_mutex_unlock(&mutex);

    pthread_exit(NULL);
}

// usage()
//    Explain how pong61 should be run.
static void usage(void) {
    fprintf(stderr, "Usage: ./pong61 [-h HOST] [-p PORT] [USER]\n");
    exit(1);
}
int fun(int width, int height, int r)
{
      const int num_pongs = 45;
      int clipdur = 20;
      int wordlen = 5;
      double end = timestamp() + clipdur;
      
      // play game   
      char url[BUFSIZ];
      
      // set x coordinates
      int x_coords[45] = {7,6,5,4,3,3,3,3,4, 5, 6, 7, 14, 13, 12, 11, 11, 12, 13, 14, 14, 13, 12, 11, 7, 6, 5, 4, 3, 3, 4, 5, 6, 7, 7, 6, 5,13,13,13,13,13,13,13,13};
      
      // set y coordinates
      int y_coords[45] = {2,2,3,4,5,6,7,8,9,10,11,11,  2,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 11,14,15,16,17,18,19,20,21,21,20,19,18,17,14,15,16,17,18,19,20,21};
      
      // initialize colors array
      char colors[45][10];
      
      // populate colors array
      strcpy(colors[0],"pink");
      strcpy(colors[1],"red");
      strcpy(colors[2],"orange");
      strcpy(colors[3],"yellow");
      strcpy(colors[4],"green");
      strcpy(colors[5],"blue");
      strcpy(colors[6],"purple");
      strcpy(colors[7],"black");
      strcpy(colors[8],"white");
      strcpy(colors[9],"on");
      strcpy(colors[10],"red");
      strcpy(colors[11],"orange");
      strcpy(colors[12],"yellow");
      strcpy(colors[13],"green");
      strcpy(colors[14],"blue");
      strcpy(colors[15],"purple");
      strcpy(colors[16],"black");
      strcpy(colors[17],"white");
      strcpy(colors[18],"on");
      strcpy(colors[19],"red");
      strcpy(colors[20],"orange");
      strcpy(colors[21],"yellow");
      strcpy(colors[22],"green");
      strcpy(colors[23],"blue");
      strcpy(colors[24],"purple");
      strcpy(colors[25],"black");
      strcpy(colors[26],"white");
      strcpy(colors[27],"on");
      strcpy(colors[28],"red");
      strcpy(colors[29],"orange");
      strcpy(colors[30],"yellow");
      strcpy(colors[31],"green");
      strcpy(colors[32],"blue");
      strcpy(colors[33],"purple");
      strcpy(colors[34],"black");
      strcpy(colors[35],"white");
      strcpy(colors[36],"on");
      strcpy(colors[37],"red");
      strcpy(colors[38],"orange");
      strcpy(colors[39],"yellow");
      strcpy(colors[40],"green");
      strcpy(colors[41],"blue");
      strcpy(colors[42],"purple");
      strcpy(colors[43],"black");
      strcpy(colors[44],"white");

      for (int i = 0; i < num_pongs; ++i) {
   
        // create a new thread to handle the next position
        pong_args pa;
        pa.x = x_coords[i];
        pa.y = y_coords[i];
        strcpy(pa.color,colors[i]);
        pa.duration = (end - timestamp())*1000;
        
        
        pthread_t pt;
        
        while (nthreads >= MAX_THREADS);
        
	    // increasing total number of threads
        pthread_mutex_lock(&mutex);
        ++nthreads;
        pthread_mutex_unlock(&mutex);
        
        r = pthread_create(&pt, NULL, pong_thread, &pa);
        
        
        if (r != 0) {
            fprintf(stderr, "%.3f sec: pthread_create: %s\n",
                    elapsed(), strerror(r));
            exit(1);
        }

        // wait until that thread signals us to continue
        pthread_mutex_lock(&mutex);
        pthread_cond_wait(&condvar, &mutex);
        pthread_mutex_unlock(&mutex);
        
        // wait 0.1sec
        usleep(100000);
        
    }
    return 0;
}
int normal(int width, int height, int r)
{
      // play game
      int x = 0, y = 0, dx = 1, dy = 1, duration = 4000;
      char color[5] = "on";
      char url[BUFSIZ];
      
      while (1) {
      
        // create a new thread to handle the next position
        pong_args pa;
        pa.x = x;
        pa.y = y;
        strcpy(pa.color,color);
        pa.duration = duration;

        pthread_t pt;
        
	// logic for phase 2
        while (nthreads >= MAX_THREADS);
        
	// increasing total number of thread
        pthread_mutex_lock(&mutex);
        ++nthreads;
        pthread_mutex_unlock(&mutex);
        
        r = pthread_create(&pt, NULL, pong_thread, &pa);
        
        
        if (r != 0) {
            fprintf(stderr, "%.3f sec: pthread_create: %s\n",
                    elapsed(), strerror(r));
            exit(1);
        }
    
        // wait until that thread signals us to continue
        pthread_mutex_lock(&mutex);
        pthread_cond_wait(&condvar, &mutex);
        pthread_mutex_unlock(&mutex);

        // update position
        x += dx;
        y += dy;
        if (x < 0 || x >= width) {
            dx = -dx;
            x += 2 * dx;
        }
        if (y < 0 || y >= height) {
            dy = -dy;
            y += 2 * dy;
        }

        // wait 0.1sec
        usleep(100000);
    }
    return 0;
}
// main(argc, argv)
//    The main loop.
int main(int argc, char** argv) {
    // parse arguments
  int ch = 0;
  int nocheck = 0;
    
      // NEW: Declare connections list
    my_conn_list = malloc(sizeof(conn_list));
    my_conn_list->first = NULL; 
    my_conn_list->count = 0;
    
    while ((ch = getopt(argc, argv, "nh:p:u:")) != -1) {
        if (ch == 'h')
            pong_host = optarg;
        else if (ch == 'p')
            pong_port = optarg;
        else if (ch == 'u')
            pong_user = optarg;
        else if (ch == 'n')
            nocheck = 1;
        else
            usage();
    }
    if (optind == argc - 1)
        pong_user = argv[optind];
    else if (optind != argc)
        usage();

    // look up network address of pong server
    struct addrinfo hints;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_NUMERICSERV;
    int r = getaddrinfo(pong_host, pong_port, &hints, &pong_addr);
    if (r != 0) {
        fprintf(stderr, "problem looking up %s: %s\n",
                pong_host, gai_strerror(r));
        exit(1);
    }

    // reset pong board and get its dimensions
    int width, height;
    {
        http_connection* conn = http_connect(pong_addr);
        http_send_request(conn, nocheck ? "reset?nocheck=1" : "reset");
        http_receive_response_headers(conn);
        http_receive_response_body(conn);
        if (conn->status_code != 200
            || sscanf(conn->buf, "%d %d\n", &width, &height) != 2
            || width <= 0 || height <= 0) {
            fprintf(stderr, "bad response to \"reset\" RPC: %d %s\n",
                    conn->status_code, http_truncate_response(conn));
            exit(1);
        }
        // see if we can take this out!!
        pthread_mutex_lock(&list_mutex);
        int n = pop_from_list(conn);
        pthread_mutex_unlock(&list_mutex);
        
        // do we need to close the parent thread? 
        http_close(conn);
    }
    // measure future times relative to this moment
    elapsed_base = timestamp();

    // print display URL
    printf("Display: http://%s:%s/%s/%s\n",
           pong_host, pong_port, pong_user,
           nocheck ? " (NOCHECK mode)" : "");

    // initialize global synchronization objects
    pthread_mutex_init(&mutex, NULL);
    pthread_cond_init(&condvar, NULL);


    
    if (nocheck == 0) 
      normal(width, height, r);
    else
      fun(width, height, r);
}


// HTTP PARSING

// http_process_response_headers(conn)
//    Parse the response represented by `conn->buf`. Returns 1
//    if more header data remains to be read, 0 if all headers
//    have been consumed.
static int http_process_response_headers(http_connection* conn) {
    size_t i = 0;
 
    //logic for phase 5, need to change buf size
    if (conn->first_pass == 1) {
      conn->buf_size += BUFSIZ;
      conn->buf = realloc(conn->buf, (conn->buf_size)*sizeof(char));
    }
    conn->first_pass = 1;
    
    while ((conn->state == HTTP_INITIAL || conn->state == HTTP_HEADERS)
           && i + 2 <= conn->len) {
      if (conn->buf[i] == '\r' && conn->buf[i+1] == '\n') {
	  conn->buf[i] = 0;
	    
            if (conn->state == HTTP_INITIAL) {
	      int minor;
                if (sscanf(conn->buf, "HTTP/1.%d %d",
                           &minor, &conn->status_code) == 2)
		  conn->state = HTTP_HEADERS;
                else
		  conn->state = HTTP_BROKEN;
            } else if (i == 0)
	      conn->state = HTTP_BODY;
            else if (strncmp(conn->buf, "Content-Length: ", 16) == 0) {
                conn->content_length = strtoul(conn->buf + 16, NULL, 0);
                conn->has_content_length = 1;
            }
            memmove(conn->buf, conn->buf + i + 2, conn->len - (i + 2));
            conn->len -= i + 2;
            i = 0;
        } else
	  ++i;
    }

    if (conn->eof)
        conn->state = HTTP_BROKEN;
    return conn->state == HTTP_INITIAL || conn->state == HTTP_HEADERS;
}

//phase 3 logic here - need to add connection to list so we can use them again

// http_check_response_body(conn)
//    Returns 1 if more response data should be read into `conn->buf`,
//    0 if the connection is broken or the response is complete.
static int http_check_response_body(http_connection* conn) {
  if (conn->state == HTTP_BODY
      && (conn->has_content_length || conn->eof)
      && conn->len >= conn->content_length)
    {
      conn->state = HTTP_DONE;
      
      pthread_mutex_lock(&list_mutex);
      push_to_list(conn);
      pthread_mutex_unlock(&list_mutex);
    }
  if (conn->eof && conn->state == HTTP_DONE)
    conn->state = HTTP_CLOSED;
  else if (conn->eof)
    conn->state = HTTP_BROKEN;
  return conn->state == HTTP_BODY;
}

#ifndef SH61_H
#define SH61_H
#include <unistd.h>
#include <assert.h>
#include <signal.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>

#define TOKEN_NORMAL        0   // normal command word
#define TOKEN_REDIRECTION   1   // redirection operator (>, <, 2>)

// All other tokens are control operators that terminate the current command.
#define TOKEN_SEQUENCE      2   // `;` sequence operator
#define TOKEN_BACKGROUND    3   // `&` background operator
#define TOKEN_PIPE          4   // `|` pipe operator
#define TOKEN_AND           5   // `&&` operator
#define TOKEN_OR            6   // `||` operator

// OOOHHH Wer'
// If you want to handle an extended shell syntax for extra credit, here are
// some other token types to get you started.
#define TOKEN_LPAREN        7   // `(` operator
#define TOKEN_RPAREN        8   // `)` operator
#define TOKEN_APPEND        9   // '>>' operator
#define TOKEN_OTHER         -1

// parse_shell_token(str, type, token)
//    Parse the next token from the shell command `str`. Stores the type of
//    the token in `*type`; this is one of the TOKEN_ constants. Stores the
//    token itself in `*token`; this string should be freed eventually with
//    `free`. Advances `str` to the next token and returns that pointer.
//
//    At the end of the string, returns NULL, sets `*type` to TOKEN_SEQUENCE,
//    and sets `*token` to NULL.
const char* parse_shell_token(const char* str, int* type, char** token);

// set_foreground(pgid)
//    Mark `pgid` as the current foreground process group.
int set_foreground(pid_t pgid);

// handle_signal(signo, handler)
//    Install handler `handler` for signal `signo`. `handler` can be SIG_DFL
//    to install the default handler, or SIG_IGN to ignore the signal. Return
//    0 on success, -1 on failure. See `man 2 sigaction` or `man 3 signal`.
static inline int handle_signal(int signo, void (*handler)(int)) {
    // declare struct sigaction sa
    struct sigaction sa;
    
    // make the handler of this struct equal to the hander in the arg. 
    sa.sa_handler = handler;
    
    // the arg here is the address of sa's mask. 
    sigemptyset(&sa.sa_mask);
    
    // set flags to zero. 
    sa.sa_flags = 0;
    
    // not sure where sigaction is defined.
    return sigaction(signo, &sa, NULL);
}

#endif

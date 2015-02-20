package com.example.gridviewtest2;

import java.io.*;
import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Point;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.GridView;
import android.widget.TextView;
import android.widget.Toast;
import android.view.MotionEvent;
import android.view.View.OnTouchListener;

import android.util.Log;

public class MainActivity extends Activity 
{
	
	private static final String View = null;

	// we have to use static if we want to share the variables
	public static int boardDim;

	public static int screenHeight;

	public static int screenWidth;

	public static int currentTilePosition;

	public static int enteredBoardNumber;

	public static Integer[][] levelMap = new Integer[11][11];

	public int tileDim;

	public  boolean isSomethingEnabled;

	public GridView gv;

	public int shipTilesFound;

	public int actualShipTiles = 0;

	public int boardPosY;

	public int boardPosX;

	public int time;

	public int gridWidth;

	public int gridHeight;

	private Timer myTimer;

	private int seconds = 0;

	public Integer [] mThumbIds = {
			R.drawable.gridtile,
			R.drawable.water,
			R.drawable.shipmid,
			R.drawable.loneship,
			R.drawable.shipbot,
			R.drawable.shiptop,
			R.drawable.shipleft,
			R.drawable.shipright,
			R.drawable.error,
			R.drawable.errorwhite,
			R.drawable.redbox
	};

	public Integer [] startImages = {};

	@Override
	public void onStop()
	{
		super.onStop();
		Log.i("stopme", "onStop");
		myTimer.cancel();
	}

	@Override
	public void onDestroy()
	{
		super.onDestroy();
		Log.i("destroy","destroy");
	}

	@Override
	public void onStart()
	{
		super.onStart();
	}
	// this is the main function

	@Override
	protected void onCreate(Bundle savedInstanceState) {


		super.onCreate(savedInstanceState);

		setWater();

		getLevelData();

		getScreenDimensions();

		setContentView(R.layout.merge);

		timeText();

		setButtons();

		setBoard();

		startTimer();
	}
	public void startTimer()
	{
		myTimer = new Timer();

		myTimer.schedule(new TimerTask () {

			@Override
			public void run() {

				TimerMethod();
			}
		}, 0, 1000);
	}
	public void TimerMethod()
	{
		this.runOnUiThread(Timer_Tick);
	}
	private Runnable Timer_Tick = new Runnable() {
		public void run() {

			seconds++;

			updateTime();
		}
	};
	public void updateTime()
	{
		final TextView text = (TextView) findViewById(R.id.time_view);

		String myTime = toMinutes(seconds);

		text.setText(myTime);
	}
	public int toSeconds(String time)
	{
		int seconds = 0;
		
		String [] timeArray = time.split(":");
		
		int minutes = Integer.parseInt(timeArray[0]);
		
		int loneSeconds= Integer.parseInt(timeArray[1]);
		
		seconds = loneSeconds + minutes*60;
				
		return seconds;
	}
	public String toMinutes(int seconds)
	{
		// divide seconds by 60 and round down to get minutes
		double gameMin = Math.floor(seconds/60);

		// convert double to int
		int intMin = (int) gameMin;

		int gameSec = seconds%60;

		String secString;

		if (gameSec < 10) secString = "0"+ gameSec;

		else secString =  String.valueOf(gameSec);

		String myString = intMin + ":" + secString;

		return myString;
	}
	public void setWater()
	{
		for (int i = 0; i < boardDim; i++)
		{
			for (int j = 0; j < boardDim; j++)
			{
				levelMap[i][j]=1;
			}
		}
	}
	public int toInt(String protoInt)
	{
		int myInt = 1;

		try 
		{

			myInt = Integer.parseInt(protoInt);
		}
		catch (NumberFormatException e)
		{
			//	Log.d("nfe","number format exception with " + protoInt);
			if (protoInt.length() > 1)
			{
				Log.d("nfe","taking substring");
				String sub;

				int end = protoInt.length() - 1;

				sub = protoInt.substring(0,end);

				myInt = toInt(sub);
			}

		}

		return myInt;
	}
	public void plotShip (String [] myCoords)
	{
		int x1 = toInt(myCoords[0])-1;

		int y1 = toInt(myCoords[1])-1;  // not sure why this is the case, but for now...

		int x2 = toInt(myCoords[2])-1;

		int y2 =  toInt(myCoords[3])-1;

		if (x1 == x2 && y1==y2) // lone ship
		{
			levelMap[y1][x1]=2;
		}
		else if (x1 == x2) // ship is vertical
		{
			for (int i = y1, n=y2; i <= n; i++)
			{
				levelMap[i][x1] = 2;

			}
		}


		else if (y1 == y2) // ship is horizontal
		{

			for (int k = x1, n = x2; k <= n; k++)
			{
				levelMap[y1][k]=2;
			}

		}


	}
	// finds the correct level in the array. 
	public String [] getLevel (String [] Levels)
	{
		int counter = 0;

		// declare the level content array.
		String [] levelContent = {};

		for (int i = 1; i < Levels.length; i++)
		{

			// split the level content into an array.
			levelContent = Levels[i].split("\n\n");

			// get the board size of the level we aer examining.
			String boardSize = levelContent[1];

			Log.d("board","boardSize: " + boardSize);
			//change the board size to an integer value.
			int bSize = toInt(boardSize);

			// if we've reached the right board dimension, start counting levels.
			if (bSize == boardDim) counter++;

			// if we've hit the right level, return the level content.
			if (counter == enteredBoardNumber)
				break;

		}
		return levelContent;

	}
	public void parseHint(String [] myCoords)
	{
		Log.d("hint","parseHint");
		int x1 = toInt(myCoords[0])-1;

		int y1 = toInt(myCoords[1])-1; 

		// if this is a ship tile, let's declare that the tiles have been found.
		if (levelMap[y1][x1]==2) shipTilesFound++;

		// change a 1 to a 3, and a 2 to a 4
		levelMap[y1][x1] +=2;

		// 3 = hint water
		// 4 = hint ship
	}
	public void getLevelData()
	{

		// read the file to get the data. 
		String myData = readFile();

		// break into individual levels
		String [] levels = myData.split("Board ");

		// run the levels through the getLevel scanner, and get the correct level
		String [] myLevel = getLevel(levels);

		// get the data values here, which are in key value pairs.  start at index-2.
		for (int i = 2, n = myLevel.length; i < n; i++)
		{
			String[] keyValuePair = myLevel[i].split(":");
			//get the key, get the value.
			String key = keyValuePair[0];

			String value = keyValuePair[1];

			Log.d("hint","key: " + key);
			// get the x1, x2, y1, y2 in an array. 
			String [] myCoords = value.split(",");

			if (key.equalsIgnoreCase("hint"))
			{
				Log.d("hint","hint on first try!");
				parseHint(myCoords);
			}
			else
			{

				int shipTiles = toInt(key);

				actualShipTiles += shipTiles;

				try 
				{
					plotShip(myCoords);
				}
				catch (ArrayIndexOutOfBoundsException e)
				{
					Log.d("hint","caught a hint!");
					parseHint(myCoords);

				}

			}
		}

	}
	public String readFile()
	{
		// set up input stream
		InputStream is = getResources().openRawResource(R.raw.mylevels);	 

		// instantiate an array output stream
		ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

		// this will tell you the status of the reading I think
		int i;

		try 
		{
			i = is.read();

			// while we are not done
			while (i != -1)
			{
				// write to the input stream
				byteArrayOutputStream.write(i);

				// reading one bit at a time
				i = is.read();
			}
			// when the loop is done, close the input stream
			is.close();
		}
		catch (IOException e)
		{
			// Log.v("io","couldn't read file");
			return null;

		}
		return byteArrayOutputStream.toString();
	}

	public void setBoard()
	{
		gv = (GridView) findViewById(R.id.grid_view);

		gv.setAdapter(new ImageAdapter(this));
		final int tileDim = screenWidth/11; // get from settings


		// set grid padding
		gridHeight = boardDim*tileDim;
		gridWidth = boardDim*tileDim;


		final int vertPad = (screenHeight-gridHeight)/2;

		final int horizPad = (screenWidth-gridWidth)/2;



		gv.setPadding(horizPad, screenHeight/8, horizPad, 0);

		gv.setNumColumns(boardDim);



		/*
		 *  On Click Event for Single Gridview Item 
		 */



		gv.setOnTouchListener(new OnTouchListener()
		{
			public boolean onTouch(View view, MotionEvent event)
			{


		

				int y = (int) event.getY();

				int x = (int) event.getX();

				int botLimit = gv.getPaddingTop() + gridHeight;

				if (x > (screenWidth-gridWidth)/2 
						&& x < screenWidth-gv.getPaddingLeft()
						&& y > gv.getPaddingTop()
						&& y < botLimit)
				{
					if (event.getAction()==MotionEvent.ACTION_DOWN)
					{
						for (int i = 0; i < gv.getChildCount(); i++)
						{
							Tile myTile = (Tile) gv.getChildAt(i);

							myTile.setImageResource(0);	
						}
					}
					if (event.getAction()==MotionEvent.ACTION_DOWN || event.getAction()==MotionEvent.ACTION_MOVE)
					{

						int myY = y-gv.getPaddingTop();

						int tileX = (int) Math.ceil((x-gv.getPaddingLeft())/(tileDim*0.98)-1);
						int tileY = (int) Math.ceil((y-gv.getPaddingTop())/(tileDim*.95)-1);

						//text.setText("coords: " + tileX + "," + tileY);

						int position = tileX + tileY*boardDim;

						try 
						{
							activateTile(position, x, y);
						}
						catch (Exception e)
						{
							// Log.e("error","error: " + e);
						}



					}

					if (event.getAction()==MotionEvent.ACTION_UP)
					{
						for (int i = 0; i < gv.getChildCount(); i++)
						{
							Tile myTile = (Tile) gv.getChildAt(i);
							myTile.changed = false;
					
						}
					}


				}
				return true;
			}

		});
	}

	/*
	 * Set up the time text
	 */
	public void timeText()
	{
		final TextView text = (TextView) findViewById(R.id.time_view);

		text.setText("Time: 0:00");

		text.setGravity(Gravity.CENTER_HORIZONTAL);
		
		text.setTextSize(screenWidth/40);
		
		final TextView messageText = (TextView) findViewById(R.id.message_view);
		
		messageText.setTextSize(screenWidth/40);
		
		
	}
	/*
	 * Get Screen Dimensions
	 */
	public void getScreenDimensions()
	{
		Display display = getWindowManager().getDefaultDisplay();

		Point size = new Point();

		display.getSize(size);

		screenWidth = size.x;

		screenHeight = size.y;
		
		
	}

	/*
	 *  Set Button Listeners
	 */
	public void setButtons()
	{
		// declare grid
		final GridView gv = (GridView) findViewById(R.id.grid_view);

		// declare buttons
		final Button checkBtn = (Button) findViewById(R.id.check);

		final Button clearBtn = (Button) findViewById(R.id.clear);

		final Button settingsBtn = (Button) findViewById(R.id.settings);

		final Button quitBtn = (Button) findViewById(R.id.quit);

		checkBtn.setOnClickListener(new View.OnClickListener () {



			public void onClick(View v)
			{
				for (int i = 0; i < gv.getChildCount(); i++)
				{
					Tile myTile = (Tile) gv.getChildAt(i);

					if (myTile.visType != myTile.trueType && myTile.visType > 0)
					{
						if (myTile.tooClose == true)
						{
							myTile.setImageResource(R.drawable.errorwhite);
						}
						else
						{
							myTile.setImageResource(R.drawable.error); // add white
						}
					}
					else
					{
						myTile.setImageResource(0);
					}
				}
			}

		});

		clearBtn.setOnClickListener(new View.OnClickListener () {

			public void onClick(View v)
			{
				for (int i = 0; i < gv.getChildCount(); i++)
				{
					Tile myTile = (Tile) gv.getChildAt(i);
					myTile.visType = 0; 
					myTile.tooClose = false;
					myTile.setBackgroundResource(R.drawable.gridtile);
					myTile.setImageResource(0);

				}
			}

		});


		settingsBtn.setOnClickListener(new View.OnClickListener () {

			public void onClick(View v)
			{
				Intent myIntent = new Intent(v.getContext(), MySettings.class);

				startActivity(myIntent);
			}

		});

		quitBtn.setOnClickListener(new View.OnClickListener () {

			public void onClick(View v)
			{
				Intent myIntent = new Intent(v.getContext(), StartScreen.class);

				startActivity(myIntent);
			}

		});

		// grid view
	}

	public int activateTile(int position, int x, int y)
	{



		// get the current grid view. 
		final GridView gv = (GridView) findViewById(R.id.grid_view);

		//	int buffer = screenWidth-gridWidth;
		//	text.setText("locY: " + y + "padding:" + gv.getPaddingTop());

		Tile myTile  = (Tile) gv.getChildAt(position);

		// sets clicked to true to it can affect other tiles. 
		myTile.clicked = true;


		if (!myTile.changed && !myTile.isHint)
		{
			// set this image to water
			changeTile(myTile, position);
		}
		else
		{
			myTile.clicked = false;
			return 0;
		}

		myTile.changed = true;
		myTile.clicked = false;
		return 0;
	}

	public int changeTile(Tile myTile, int position)
	{
		switch (myTile.visType)
		{
			case 0:
				myTile.setBackgroundResource(mThumbIds[1]);
			
				myTile.visType = 1;
			
				checkForShip(myTile, position); // run check on surrounding ships to see if they shoudl be changed
			break;
			
			case 1: // make into a ship
				
				if (myTile.trueType == 2) shipTilesFound++;
				myTile.setBackgroundResource(mThumbIds[2]);

				shipType(myTile, position); 
				
	
				
				
				
			break;
			
			case 2: // make into a grid tile
				if (myTile.trueType ==2) shipTilesFound--;
				
				myTile.setBackgroundResource(mThumbIds[0]);

				myTile.visType = 0;

				checkForShip(myTile, position); // will run a check on all surrounding ships
				
			
				
			break;
		}
		
	
		
		return 0;
	}
	public String loadPrefs() {
		SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(this);
		
		String strValue = sp.getString("pr", StartScreen.defaultMessage);
		
		return strValue;
	}
	public void checkTime()
	{
		String prString = loadPrefs();
		
		int currentPR;
		
		if (prString.equalsIgnoreCase(StartScreen.defaultMessage))
				currentPR = 20000;
		else 
			currentPR = toSeconds(prString);
		
		if (seconds < currentPR)
		{
			String timeString = toMinutes(seconds);
		
			savePrefs("pr", timeString);
		}
	}
	public void savePrefs(String key, String value)
	{
		SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(this);
			
		Editor edit = sp.edit();
			
		edit.putString(key, value);
			
		edit.commit();
		
	}
	public void playSound()
	{
		Log.d("sound","playsound");
		MediaPlayer mPlayer = new MediaPlayer();
		mPlayer = MediaPlayer.create(this, R.raw.victory);
		mPlayer.setVolume(100,100);
		
		
		mPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener()
		{
			@Override
			public void onPrepared(MediaPlayer mPlayer)
			{
				Log.v("sound","sound started");
				mPlayer.start();
			}
		});
		
	
		//onPrepared(mPlayer);
		//mPlayer.start();
	}
	public void onPrepared(MediaPlayer mPlayer)
	{
		mPlayer.start();
	}
	public void printVictory()
	{
		printMessage("You won!");
	}
	public void getBestTime()
	{
		
	}
	public void printMessage(String message)
	{
		final TextView messageText = (TextView) findViewById(R.id.message_view);
		
		messageText.setText(message);
	}

	public boolean checkForWin()
	{
		boolean errors = false;
		for (int i = 0; i < gv.getChildCount(); i++)
		{
			Tile myTile  = (Tile) gv.getChildAt(i);
			
			Log.d("win","loop number " + i);
			if (myTile.trueType != myTile.visType && myTile.visType != 0)
			{
				
				errors = true;
				printMessage("not a win");
				Log.v("win","not a win");
				return false;
			}
		}
		
		if (actualShipTiles == shipTilesFound && errors == false)
		{
			playSound();
			checkTime(); 
			printVictory();
		}
		return true;
	}
	public int getPosition(int x, int y)
	{
		

		int tileX = (int) ((x-gv.getPaddingLeft())/(tileDim*0.95)-1);
		int tileY = (int) ((y-gv.getPaddingTop())/(tileDim*0.95)-1);

		// // Log.v("tiles","coords: " + tileX + "," + tileY);
		int position = (int) tileY*10 + tileX;

		return position;
	}

	public void makeToast(String message)
	{
		Context context = getApplicationContext();

		Toast toast = Toast.makeText(context, message, Toast.LENGTH_SHORT);

		toast.show();
	}
	/*
	 *  Called by a tile that has become a ship.  Determines its ship shape and checks surrounding tiles. 
	 */
	public int shipType(Tile myTile, int position)
	{

		myTile.visType = 2;
		if (shipTilesFound == actualShipTiles)
		{
			Log.v("win","checking...");
			checkForWin();
		}
		// fix this so you don't have a stack overflow. 
		// tiles affected should not affect neighbors, only check for themselves. 
		
		// perhaps to a try catch here
		
		boolean diagonalNeighbors = false;
		try
		{
			if (myTile.clicked) diagonalNeighbors = diagonalTiles(myTile, position);
		}
		catch (StackOverflowError e)
		{
			Log.v("stack","stack overflow");
		}
	
			if (diagonalNeighbors == false) 
			{
				try
				{
					directTiles(myTile, position);
				}
				catch (StackOverflowError e)
				{
					Log.v("stack","stack overflow with direct tiles");
				}
			}
		
		
		
		return 0;


	}
	// do we need to turn anything red? 

	public Tile[] getDiagonalNeighbors(Tile myTile, int position)
	{
		// // Log.v("crash","getDiagonalNeighbors");
		final GridView gv = (GridView) findViewById(R.id.grid_view);


		Tile alTile = myTile;
		Tile arTile = myTile;
		Tile blTile = myTile;
		Tile brTile = myTile;

		if (!myTile.atTop && !myTile.farLeft)
		{
			//alTile
			alTile = (Tile) gv.getChildAt(position-boardDim-1);

			myTile.alState = alTile.visType;
		}

		if (!myTile.atTop && !myTile.farRight)
		{
			arTile = (Tile) gv.getChildAt(position-boardDim+1);
			myTile.arState = arTile.visType;

		}
		if (!myTile.atBot && !myTile.farLeft)
		{
			blTile = (Tile) gv.getChildAt(position+boardDim-1);
			myTile.blState = blTile.visType;
		}
		if (!myTile.atBot && !myTile.farRight)
		{
			brTile = (Tile) gv.getChildAt(position+boardDim+1);
			myTile.brState = brTile.visType;
		}

		Tile[] tileArray = {alTile,arTile,blTile,brTile};
		return tileArray;
	}
	
	/*
	 * Diagonal Tiles
	 */
	public boolean diagonalTiles(Tile myTile, int position)
	{



		Tile tileArray[] = getDiagonalNeighbors(myTile, position);

		Tile alTile = tileArray[0];
		Tile arTile = tileArray[1];
		Tile blTile = tileArray[2];
		Tile brTile = tileArray[3];

		if (myTile.arState != 2 &&
				myTile.alState != 2 &&
				myTile.blState != 2 &&
				myTile.brState != 2)
		{
			myTile.tooClose = false;
			return false;
		}
		else
		{
			myTile.tooClose = true;
			// turn this tile red. 
			redVsHint(myTile);

			// turn neighboring tiles red if they are ships. 
			if (myTile.alState==2) alTile.setBackgroundResource(R.drawable.redbox);

			if (myTile.arState==2) arTile.setBackgroundResource(R.drawable.redbox);

			if (myTile.brState==2) brTile.setBackgroundResource(R.drawable.redbox);

			if (myTile.blState==2) blTile.setBackgroundResource(R.drawable.redbox);

			if (myTile.clicked) affectDirects(myTile, position); // check for direct tiles. 

			return true;
		}
		// when turning a tile at the top to water, it crashes when it does something with above / below tiles. 
		// 
	}
	public int redVsHint (Tile myTile)
	{
		// if it is a hint, keep it as a hint. 
		if (myTile.isHint == false)
			myTile.setBackgroundResource(R.drawable.redbox);
		else
			myTile.setBackgroundResource(myTile.hintImage); // we'll see if this works
		return 0;
	}
	public int checkForShip(Tile myTile, int position)
	{


		// gets diagonal neighbors to check their types. 
		affectDiagonals(myTile, position);

		// gets direct neighbors to check their types. 
		affectDirects(myTile, position);

		if (myTile.clicked) if (shipTilesFound == actualShipTiles) checkForWin();

		return 0;
	}
	// tells direct neighbors to check their types. 
	public int affectDirects(Tile myTile, int position)
	{
		// // Log.d("crash","affectDirects");
		Tile directs[] = getDirectNeighbors(myTile, position);

		Tile leftTile = directs[0];
		Tile rightTile = directs[1];
		Tile aboveTile = directs[2];
		Tile belowTile = directs[3];

		if (!myTile.farLeft) 
			if (leftTile.visType == 2) 
				shipType(leftTile, position-1);

		if (!myTile.farRight)
			if (rightTile.visType == 2)
				shipType(rightTile, position+1);

		if (!myTile.atTop)
			if (aboveTile.visType == 2)
				shipType(aboveTile, position-boardDim);

		if (!myTile.atBot)
			if (belowTile.visType == 2)
				shipType(belowTile, position+boardDim);

		return 0;
	}
	// tells their diagonal neighbors to check their types. 
	public int affectDiagonals(Tile myTile, int position)
	{
		// // Log.d("crash","affectDiagonals");
		Tile diagonals[] = getDiagonalNeighbors(myTile, position);

		Tile alTile = diagonals[0];
		Tile arTile = diagonals[1];
		Tile blTile = diagonals[2];
		Tile brTile = diagonals[3];

		// see if we need to change diagonal tiles. 
		if (!myTile.topLeft)
			if (alTile.visType == 2)
				shipType(alTile, position-boardDim-1);

		if (!myTile.topRight)
			if (arTile.visType == 2)
				shipType(arTile, position-boardDim+1);

		if (!myTile.botLeft)
			if (blTile.visType == 2)
				shipType(blTile, position+boardDim-1);

		if (!myTile.botRight)
			if (brTile.visType == 2)
				shipType(brTile, position+boardDim+1);

		return 0;
	}
	/*
	 * Function for checking for direct neighbors
	 */
	public Tile [] getDirectNeighbors(Tile myTile, int position)
	{
		// // Log.d("crash","getDirectNeighbors");
	
		Tile aboveTile = myTile;
		Tile belowTile = myTile;
		Tile leftTile = myTile;
		Tile rightTile = myTile;

		// change in xcode?
		if (!myTile.atTop)
		{
			// // Log.d("crash","tile is not at the top");
			aboveTile = (Tile) gv.getChildAt(position-boardDim);
			myTile.aboveState = aboveTile.visType; 
		}
		if (!myTile.atBot)
		{
			// // Log.d("crash","tile is not at the bottom");
			belowTile = (Tile) gv.getChildAt(position+boardDim);
			myTile.belowState = belowTile.visType;
		}
		if (!myTile.farRight)
		{
			rightTile = (Tile) gv.getChildAt(position+1);
			myTile.rightState = rightTile.visType;
		}
		if (!myTile.farLeft)
		{

			leftTile = (Tile) gv.getChildAt(position-1);
			myTile.leftState = leftTile.visType;
		}

		Tile[] tileArray = {leftTile,rightTile,aboveTile,belowTile};

		return tileArray;
	}
	/*
	 * Reacts to and modifies tiles that are above, below, left, and right. 
	 */
	public int directTiles(Tile myTile, int position)
	{

		// Log.d("direct","directTiles");
		Tile tileArray[] = getDirectNeighbors(myTile, position);

		Tile leftTile = tileArray[0];
		Tile rightTile = tileArray[1];
		Tile aboveTile = tileArray[2];
		Tile belowTile = tileArray[3];


		if (myTile.isHint && !myTile.tooClose)
		{
			myTile.setBackgroundResource(myTile.hintImage);
		}
		// surrounded by water? 
		else if (myTile.leftState == 1 &&
				myTile.rightState == 1 &&
				myTile.aboveState == 1 && 
				myTile.belowState == 1)
		{
			// add clicked logic
			myTile.setBackgroundResource(R.drawable.loneship);
			// Log.d("loneship","loneship");
			return 0;
		} 
		else if (myTile.leftState == 1 &&
				myTile.rightState == 1 &&
				myTile.aboveState == 1 && 
				myTile.belowState ==2) // ship below
		{
			if (myTile.clicked == true) shipType(belowTile, position+boardDim);

			myTile.setBackgroundResource(R.drawable.shiptop);			
		}

		// there is a ship tile on right
		else if (myTile.leftState == 1 &&
				myTile.rightState == 2 && // ship on right
				myTile.aboveState == 1 && 
				myTile.belowState ==1)
		{
			if (myTile.clicked == true) shipType(rightTile, position+1); // this doesn't get called if there is a diagonal present. 
			// which is bad, because there might be a ship around even if there IS a diagonal. 
			// what about doing a quick check for surrounding ships via affectDirects

			myTile.setBackgroundResource(R.drawable.shipleft);
		}

		// there is a ship tile on left
		else if (myTile.leftState == 2 && // ship on left
				myTile.rightState == 1 && 
				myTile.aboveState == 1 && 
				myTile.belowState == 1)
		{
			if (myTile.clicked == true) shipType(leftTile, position-1);
			myTile.setBackgroundResource(R.drawable.shipright);
		}

		// there is a ship tile above
		else if (myTile.leftState == 1 &&
				myTile.rightState == 1 &&
				myTile.aboveState == 2 && // ship above
				myTile.belowState ==1)
		{
			if (myTile.clicked == true) shipType(aboveTile, position-boardDim);

			myTile.setBackgroundResource(R.drawable.shipbot);
		}

		// between top & bottom ship tiles
		else if (myTile.leftState == 1 &&
				myTile.rightState == 1 &&
				myTile.aboveState == 2 &&
				myTile.belowState ==2) 
		{
			if (myTile.clicked == true) shipType(aboveTile, position-boardDim);

			if (myTile.clicked == true) shipType(belowTile, position+boardDim);

			myTile.setBackgroundResource(R.drawable.shipmid);
		}

		// between left & right ship tiles
		else if (myTile.leftState ==2 &&
				myTile.rightState == 2 &&
				myTile.aboveState ==1 &&
				myTile.belowState == 1)
		{
			if (myTile.clicked == true) shipType(rightTile, position+1);

			if (myTile.clicked == true) shipType(leftTile, position-1);

			myTile.setBackgroundResource(R.drawable.shipmid); // necessary? 
		}
		else
		{
			myTile.setBackgroundResource(R.drawable.shipgrey);
		}

		if (myTile.clicked == true) affectDirects(myTile, position);

		myTile.clicked = false;
		return 0;
	}

	// sets up a default, striped boardview -- doesn't work yet!

}

/* NEXT UP
 * Figure out how to create an extension of the ImageView class.  DONE!
 * Create the myType and trueType variables.  DONE!
 * 
 * How to move gridview down on the screen. DONE!
 * 
 * 
 * Add additional tiles.
 * Figure out how to set row & column dimensions.
 * Set number of rows and columns dynamically.  
 * Figure out how to call neighboring tiles during the onClick.  Maybe in position? 
 * Add Logic for neighboring tiles. 
 * Add title. 
 * Separate screen. 
 * 
 * Get device width / resize based on device
 * Switch screens. 
 * 
 * Rewatch android tutorial. 
 * 
 * QUESTIONS: 
 * How do you expand the loop? 
 * How do you position the grid? 
 * How do you extend the ImageView class?
 * 
 *TERMS:
 *Activity Class
 *Constructor
 */


/*STOPPED HERE  FINISH UP THE CODE
 * 
 * 
 * - come back to line
 * water tiles
 * truetype logic
 * screen transitions
 * pull in levels from textfile. (where is it stored? 
 * dragging
 * splash screen?
 * timer
 * revisit dimensions
 * screen segues
 * 
 * 
 * resubmit iPhone app with revised hint logic!
 * 
 */

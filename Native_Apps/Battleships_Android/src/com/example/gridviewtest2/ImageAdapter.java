package com.example.gridviewtest2;


import java.io.FileInputStream;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

import android.view.DragEvent;
import android.view.MotionEvent;
import android.view.View.DragShadowBuilder;
import android.view.View.OnDragListener;
import android.view.View.OnTouchListener;

public class ImageAdapter extends BaseAdapter {

	private int Xcounter = -1;
	private int Ycounter = 0;



	//public Tile currentTile;
	private Context mContext; // what is this??

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

	//public Integer [] mThumbIds = {};



	// Constructor!  Looks like it's taking a context variable named "c" as an argument.
	public ImageAdapter(Context c)
	{
		mContext = c;
	}

	@Override
	public int getCount() // returns the length of the image array.  that's easy!!
	{
		// this should ultimately be passed in through settings. 
		int boardDim = MainActivity.boardDim;

		int numTiles = boardDim*boardDim;


		return numTiles;
	}

	@Override // retrieves the item from the array based on an index. 
	public Object getItem(int position)
	{
		return mThumbIds[position];
	}

	@Override  // falset sure what the point is of this. 
	public long getItemId(int position)
	{
		return 0;
	}

	@Override // this function instantiates a grid tile. 
	public View getView(int position, View convertView, ViewGroup parent)
	{
	
		final Tile myTile = new Tile(
				mContext, 
				0, 1, 0, 0, 
				false,false,false,false, // clicked, tooClose, changed, isHint
				0,
				false,false,false,false, // extreme ends of the board (right, left, top, bot)
				0,0,0,0, // neighboring right-left-up-down tiles
				0,0,0,0,  // neighboring diagonal tiles
				false,false,false,false,
				position, // topright, topleft, botright, botleft
				false); 

		myTile.locX = Xcounter;
		myTile.locY = Ycounter;



		checkEdges(myTile);
		checkCorners(myTile);
		// calls the first image in the array, whichi s the empty grid tile.
		myTile.setBackgroundResource(mThumbIds[0]);
		//myTile.setImageResource(R.drawable.error);

		// probably crops the edges so that overflow remains hidden.
		myTile.setScaleType(Tile.ScaleType.CENTER_CROP);

		int screenWidth = MainActivity.screenWidth;

		int tileDim = screenWidth/12;

		// this makes it appear and sets the scale. use for screen responsiveness?Œ
		myTile.setLayoutParams(new GridView.LayoutParams(tileDim,tileDim));

		// sets the padding of an individual grid tile. - left, top, right, bottom
		myTile.setPadding(0, 0, 0, 0);

		
		int ty = myTile.locY;
		int tx = myTile.locX;
		
		if (ty >=0 && tx >=0)
		{
			if (MainActivity.levelMap[ty][tx] != null)
			{
				myTile.trueType = MainActivity.levelMap[ty][tx];
			
				//if (myTile.trueType == 2) Log.d("map","ship"); else Log.d("map","water");
			}
			
		}
		

		areYouHint(myTile);

		updateCounters();
		return myTile;
	}

	public void areYouHint(Tile myTile)
	{
		// check for whether myTile is a hint.
		if (myTile.trueType == 3) // water hint
		{
			Log.d("hint","water hint!");
			waterHint(myTile);
		}
		else if (myTile.trueType == 4) // ship hint
		{
			Log.d("hint","ship hint!");
			shipHint(myTile);

		}
		else
		{
			myTile.isHint = false;
			myTile.setBackgroundResource(R.drawable.gridtile);

			// in Obj. C we add listeners to each tile, but in Java, the touch listening is done from the Main. 
		}

	}	



	public int findHintShape(int row, int col)
	{
		int nodeAbove = 1;
		int nodeBelow = 1;
		int nodeLeft = 1;
		int nodeRight = 1;

		// grab the level map from the Main Activity. 
		Integer [][] Level = MainActivity.levelMap;

		// get the Max index. 
		int maxIndex = MainActivity.boardDim - 1;

		// if we are not on the top edge, define the node as the tile above. 
		if (row > 0) nodeAbove = Level[row-1][col]; 

		// if we are not on the bottom edge, define the node as the tile below. 
		if (row <  maxIndex) nodeBelow = Level[row+1][col];

		// if not left edge, define node as left tile
		if (col > 0)  nodeLeft = Level[row][col-1];

		// if not right edge, define node as right tile. 
		if (col <  maxIndex) nodeRight = Level[row][col+1];


		// figure out surrounding tiles using modulos, since some could be 3 (hint water) or 4 (hint ship).
		// all water
		if (nodeAbove%2 == 1 && nodeBelow%2 == 1 && nodeLeft%2 == 1 && nodeRight%2 ==1 )
		{
			return R.drawable.loneship;
		}

		// ship left & ship right OR ship up & ship down
		else if ((nodeAbove%2 == 0 && nodeBelow%2 == 0) || (nodeLeft%2 == 0 && nodeRight%2 == 0))
		{
			return R.drawable.shipmid;
		}
		else if (nodeAbove%2 == 0) return R.drawable.shipbot;

		else if (nodeBelow%2 == 0) return R.drawable.shiptop;

		else if (nodeRight%2 == 0) return R.drawable.shipleft;

		else if (nodeLeft%2 == 0) return  R.drawable.shipright;

		return R.drawable.shipgrey;
	}


	public void waterHint(Tile myTile)
	{
		//set the true type to water
		myTile.trueType = 1;

		// set the hint tile 
		myTile.isHint = true;

		myTile.visType = 1;
		myTile.hintImage = R.drawable.water;

		myTile.setBackgroundResource(myTile.hintImage);
	}
	public void shipHint(Tile myTile)
	{
		myTile.trueType = 2; // reset the myTile's true type so it corresponds to an actual ship.
		myTile.isHint = true;

		myTile.hintImage = findHintShape(myTile.locY, myTile.locX);

		int hintImage = myTile.hintImage;

		// set the visible type to be 2.  important for setting other ships.
		myTile.visType = 2;

		myTile.setBackgroundResource(hintImage);
	}
	/*public void getLevelData()
	{

		for(int i = 0; i < boardDim; i++)
		{

			for (int j = 0; j < boardDim; j++)
			{
				if (i%2 == 0) trueTypes[i][j] = 2;
				else
					trueTypes[i][j] = 1;
			}
		}


	}*/
	public int checkEdges(Tile myTile)
	{
		int lastTile = MainActivity.boardDim-1;
		int row = myTile.locY;
		int col = myTile.locX;

		if (row <=0)
		{

			myTile.atTop = true;
			myTile.aboveState = 1; // treat edge as water

		} 
		if (row == lastTile)
		{

			myTile.atBot = true;
			myTile.belowState = 1; // treat edge as water

		}
		if (col <= 0)
		{

			myTile.farLeft = true;
			myTile.leftState = 1; // treat edge as water

		}
		if (col == lastTile)
		{

			myTile.farRight = true;
			myTile.rightState = 1; // treat the edge as water
		}
		return 0;
	}
	// determines whether the tile is at a corner.  if true, set the diagonally neighboring tile to zero. 
	// using else because the tile can only be at one corner!!
	public int checkCorners(Tile myTile)
	{
		if (myTile.atTop && myTile.farLeft) 
		{
			myTile.alState = 1;
			myTile.topLeft = true;
		}
		else if (myTile.atTop && myTile.farRight) 
		{
			myTile.arState = 1;
			myTile.topRight = true;
		}
		else if (myTile.atBot && myTile.farLeft) 
		{
			myTile.blState = 1;
			myTile.botLeft = true;
		}
		else if (myTile.atBot && myTile.farRight)
		{
			myTile.brState = 1;
			myTile.botRight = true;
		}

		return 0;
	}
	public int updateCounters()
	{
	

			Xcounter++;

		if (Xcounter > MainActivity.boardDim - 1)
		{
			Xcounter = 0;
			Ycounter +=1;
		}



		return 0;
	}

}



// next up: make a touch event bubble up from the tile.  transfer the one from the main activity class to the tile.  
/*
Next up: (10-2!)

Finish tutorial

Figure out how to:
	modify dimensions of the grid
	modify dimensions of the pics
	store more arrays
	add a title on the top
	switch screens


TERMS TO LOOK UP: 
	stretchmode
	BaseAdapter

 */
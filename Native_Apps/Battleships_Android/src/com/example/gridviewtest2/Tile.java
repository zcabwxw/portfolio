package com.example.gridviewtest2;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Point;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.Toast;

public class Tile extends ImageView {
	
	// 4 ints, 4 bools, and a string!
	
	// what is its visible type? 
	public int visType;
	
	// what is its true type?
	public int trueType;
	
	public int locX; 
	
	public int locY;

	// has this been clicked?
	public boolean clicked;
	
	// is it diagonally too close to other tiles? 
	public boolean tooClose;
	
	// has this been changed since the touch started?
	public boolean changed;
	
	// is this a hint? 
	public boolean isHint;
	
	// if a hint, what is the hint image? 
	public int hintImage;
	
	// variables on whether it is on edges. 
	public boolean farRight;
	
	public boolean farLeft;
	
	public boolean atTop;
	
	public boolean atBot;
	
	// states of neighboring up-down-left-right tiles
	public int rightState;
	
	public int leftState;
	
	public int belowState;
	
	public int aboveState;
	
	// states of neighboring diagonal tiles
	public int arState;
	
	public int alState;
	
	public int brState;
	
	public int blState;
	
	// states for whether at corners
	public boolean topLeft;
	
	public boolean topRight;
	
	public boolean botLeft;
	
	public boolean botRight;
	
	public int position;
	
	public boolean touched;
	
	// these variables are endogenous to the tile, so that we can better encapsulate our functions when it is clicked. 
	
	
	
	public Tile (
			Context context,
			int visType, 
			int trueType,
			int locX,
			int locY,
			
			boolean clicked,
			boolean tooClose,
			boolean changed,
			boolean isHint,
			
			int hintImage,
			
			boolean farRight,
			boolean farLeft,
			boolean atTop,
			boolean atBot,
			
			int rightState,
			int leftState,
			int aboveState,
			int belowState,
			
			int arState,
			int alState,
			int brState,
			int blState,
			
			boolean topRight,
			boolean topLeft,
			boolean botRight,
			boolean botLeft,
			
			int position,
			
			boolean touched)
	{
		// is this referring to the parent?
		super (context);
		this.visType = visType;
		this.trueType = trueType;
		this.locX = locX;
		this.locY = locY;
		
		this.clicked = clicked;
		this.tooClose = tooClose;
		this.changed = changed;
		this.isHint = isHint;
		
		this.hintImage = hintImage;
		
		// check for whether it is on the edge of the board. 
		this.farRight = farRight;
		this.farLeft = farLeft;
		this.atTop = atTop;
		this.atBot = atBot;
		
		this.rightState = rightState;
		this.leftState = leftState;
		this.aboveState = aboveState;
		this.belowState = belowState;
		
		this.topRight = topRight;
		this.topLeft = topLeft;
		this.botRight = botRight;
		this.botLeft = botLeft;
		
		this.position = position;
		this.touched = touched;
	}
	public final void tileTouch()
	{
		
	}
}

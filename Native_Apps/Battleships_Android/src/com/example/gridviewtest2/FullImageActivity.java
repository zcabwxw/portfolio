package com.example.gridviewtest2;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.ImageView;

public class FullImageActivity extends Activity {
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		
		// why?
		super.onCreate(savedInstanceState);
		
		setContentView(R.layout.full_image);
		
		// get intent data
		Intent i = getIntent();
		
		int position = i.getExtras().getInt("id");
		
		// instantiate an image frame? 
		ImageAdapter imageAdapter = new ImageAdapter(this);
		
		ImageView imageView = (ImageView) findViewById(R.id.full_image_view);
		
		imageView.setImageResource(imageAdapter.mThumbIds[position]);
		
		
		
	}

}

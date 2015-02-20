package com.example.gridviewtest2;

import com.example.gridviewtest2.*;
import android.os.Bundle;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

import android.preference.PreferenceManager;

import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;
import android.content.Intent;

public class StartScreen extends Activity {

	public static String defaultMessage = "No best time yet";
	
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		setContentView(R.layout.gamestart);

		String i = "10";

		int j = Integer.parseInt(i);

		Log.v("test","integer form: " + j);

		final Button startBtn = (Button) findViewById(R.id.newgame);
		
		final Button clearBtn = (Button) findViewById(R.id.clearbest);

		displayBestTime();

		startBtn.setOnClickListener(new View.OnClickListener () {

			public void onClick(View v)
			{
				Intent myIntent = new Intent(v.getContext(), MySettings.class);

				startActivity(myIntent);
			}

		});
		
		clearBtn.setOnClickListener(new View.OnClickListener () {
			
			public void onClick (View v)
			{
				savePrefs("pr", defaultMessage);
				
				displayBestTime();
			}
		});

	}
	public int displayBestTime()
	{
		
		TextView myText = (TextView) findViewById(R.id.pr);
		
		String bestTime = loadPrefs();
		
		myText.setText(bestTime);
		
		return 0;
	}

	
	public void savePrefs(String key, String value)
	{
		SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(this);
		
		Editor edit = sp.edit();
		
		edit.putString(key, value);
		
		edit.commit();
	}
	public String loadPrefs() {
		SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(this);
		
		String strValue = sp.getString("pr", defaultMessage);
		
		return strValue;
		
	
	}
}

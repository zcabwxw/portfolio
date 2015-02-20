package com.example.gridviewtest2;

import com.example.gridviewtest2.R.id;

import android.os.Bundle;
import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;
import android.content.Intent;

public class MySettings extends Activity {

	private RadioGroup radioGroupDim;
	
	private RadioGroup radioGroupLvl;
	
	private RadioButton chosenLevel;
	
	private RadioButton chosenDim;
	
	private RadioButton r6, r8, r10;
	
	private RadioButton a, b;
	
	private int myDim = 6;
	
	private int myLevel = 0;
	
	private Button startBtn;
	
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		
		setContentView(R.layout.levelsettings);
		
		addListenerOnButton();
	}
	
	public void addListenerOnButton()
	{
		startBtn = (Button) findViewById(R.id.start);
		
		radioGroupDim = (RadioGroup) findViewById(R.id.dimensions);
		
		radioGroupLvl = (RadioGroup) findViewById(R.id.lvl);
		
	    r6 = (RadioButton) findViewById(R.id.dim6);
		
		r8 = (RadioButton) findViewById(R.id.dim8);
		
		r10 = (RadioButton) findViewById(R.id.dim10);
		
		a = (RadioButton) findViewById(R.id.lvl_a);
		
		b = (RadioButton) findViewById(R.id.lvl_b);
		
		a.setChecked(true);
		
		r6.setChecked(true);
		
		startBtn.setOnClickListener(new View.OnClickListener () {

			public void onClick(View v)
			{
				/*
				 * Get checked radio button id's
				 */
				int dimId =  radioGroupDim.getCheckedRadioButtonId();
				
				int lvlId = radioGroupLvl.getCheckedRadioButtonId();
				
				/*
				 *  Find the selected radio buttons
				 */
			
				chosenDim = (RadioButton) findViewById(dimId);
				
				chosenLevel = (RadioButton) findViewById(lvlId);
				
		
				/*
				 * Dimensions
				 */
				if (chosenDim== r6) myDim = 6;
				
				else if (chosenDim==r8) myDim = 8;
				
				else if (chosenDim==r10) myDim = 10;
				
				/*
				 * Level
				 */
				
				if (chosenLevel == a) myLevel = 1;
				
				else if (chosenLevel == b) myLevel = 2;
				
				/*
				 * Pass values to the Main Activity class. 
				 */
				
			    MainActivity.boardDim = myDim;
			    
			    MainActivity.enteredBoardNumber = myLevel;
			    
			    /*
			     * Let's get outta here 
			     */
			    
				Intent myIntent = new Intent(v.getContext(), MainActivity.class);
				
				startActivity(myIntent);
			}

		});
		

	}

	
	
	
	
	
}

/*********************************************
 * OPL 12.3 Model
 * Author: nicolas
 * Creation Date: Mar 28, 2012 at 5:24:21 PM
 *********************************************/


//MODEL FILE:
using CP;

//for simplicity time unit is one hour

dvar interval sleep in 0..1 size 8; 	//8 hours of sleep beginning at time 0 or 12am
stepFunction F = stepwise(0—>8; 100–>12; 0–>13; 100–>21); 

//this function allows specific drugs to be taken during meal times
stepFunction Meals = stepwise(0—>8; 100–>9; 0–>12; 100–>13; 100–>17; 100–>18; 0–>24; ); 

//taking medications
dvar interval drug1 optional size .25 intensity F;      //15 minute
dvar interval drug2a optional size .25 intensity Meals;     //2 instances of drug 2 (take twice per day during mealtimes) 
dvar interval drug2b optional size .25 intensity Meals;
dvar interval drug3a optional size .25;   //(3 times per day)
dvar interval drug3b optional size .25 intensity F;
dvar interval drug3c optional size .25 intensity F;

//same drugs are taken in sequence
dvar sequence d2 in drug2a drug2b [2];
dvar sequence d3 in drug3a drug3b drug3c [3];

//set up wait times for overlap constraint
tuple triplet { int id1; int id2; int value; }; 
{triplet} d2wait = { <i,j,ftoi(abs(i-j))> | i in d2, j in d2, 2 }; //should not be taken more often than every 2 hours.
{triplet} d3wait = { <i,j,ftoi(abs(i-j))> | i in d3, j in d3, 3 }; //should not be taken more often than every 3 hours. 

subject to {
	//constrain start times of pills
	endBeforeStart(sleep, drug1);
	endBeforeStart(sleep, drug2a);
	endBeforeStart(sleep, drug3a);

	cumulFunction f = step(0,1);       //one interval or drug at a time

	//pill waiting and overlap constraint
	noOverlap(d2,  [,d2wait];
	noOverlap(d3,  [,d3wait];
}

execute {
var f = cp.factory;
cp.setSearchPhases()
}


/*********************************************
 * OPL 12.3 Model
 * Author: nicolas
 * Creation Date: Mar 28, 2012 at 5:24:21 PM
 *********************************************/

{string} Weekdays = ...;  
//MODEL FILE:  
tuple drug {
  key string name;
  int priority;
  int PerWeek;
  int PerDay;
  float timeInterval;
  // 0 = empty stomach, 1 = take with meal, 2 = doesn't matter 
  int meal; 
}

tuple block {
  int id;
  string day;
  float start;
  float end;
  int meal; 
}

tuple drugPair {
  drug d1;
  drug d2;
}  

{drug} Drugs = ...;
{block} Blocks = ...;
{drugPair} DrugIncompat
	with d1 in Drugs, d2 in Drugs = ...;
int RequiredAssignments[Drugs][Blocks] = ...;
int MaxDrugsPerBlock = ...;

float AbsStartTime[b in Blocks]= b.start + ord(Weekdays, b.day)*24; 
float AbsEndTime[b in Blocks]= b.end + ord(Weekdays,b.day)*24 +(( b.start > b.end )?24:0);

int incompatBlocks[d in Drugs][b1 in Blocks][b2 in Blocks] = ((d.timeInterval <= abs(AbsEndTime[b2] - AbsStartTime[b1])) ? 0 : 1); 

dvar int DrugAssignments[Drugs][Blocks] in 0..1;

//goal: schedule as many drugs as possible
maximize
  sum(d in Drugs)
    sum( b in Blocks )
    	(d.priority * DrugAssignments[d][b]); 

subject to {
  //time interval constraint
  forall( d in Drugs)
  forall( b in Blocks)
    sum( b2 in Blocks : incompatBlocks[d][b][b2] ==1)
      DrugAssignments[d][b2] <=1;
  
  //respect Drug Incompatibility 
  forall( <d1, d2> in DrugIncompat , b in Blocks )
    //ctIncompatibilityConstraint:
    DrugAssignments[d1][b] + DrugAssignments[d2][b] <=1;
  
  //respect Max Drugs Per Block constraint
  forall( b in Blocks)
    sum(d in Drugs)
      DrugAssignments[d][b] <= MaxDrugsPerBlock;
  
  //respect per day constraint
  forall(d in Drugs, day in Weekdays){
 	//ctPerDayConstraint:  
 		sum(  b in Blocks : b.day == day)
	DrugAssignments[d][b] <= d.PerDay; 
	
//	ctCouldNotScheduleMaxDrugPerDayOn:
//		sum(b in Blocks : b.day == day)
//	DrugAssignments[d][b] == d.PerDay; 
  }   
  
    //respect per week constraint
  forall(d in Drugs){
 	//ctPerWeekConstraint:  
 		sum(  b in Blocks )
	DrugAssignments[d][b] <= d.PerWeek; 
  }   
    
  
  //respect meal constraint
  forall(d in Drugs, b in Blocks : b.meal == 1) {
    DrugAssignments[d][b]* d.meal >= 1 ||  DrugAssignments[d][b] == 0;
  }
   forall(d in Drugs, b in Blocks : b.meal == 0) {
    DrugAssignments[d][b]* d.meal == 0 || DrugAssignments[d][b]* d.meal == 2 || DrugAssignments[d][b] == 0;
  }
  
   // respect required assignments
     forall( d in Drugs, b in Blocks : RequiredAssignments[d][b] == 1 ){
       ctRequiredAssignmentConstraints:
         DrugAssignments[d][b] == 1;        
       }
       
   //respect disallowing assignments
        // respect required assignments
     forall( d in Drugs, b in Blocks : RequiredAssignments[d][b] == 2 ){
       ctRequiredNonAssignmentConstraints:
         DrugAssignments[d][b] == 0;        
       }
       
}
/*********************************************
 * OPL 12.3 Model
 * Author: nicolas
 * Creation Date: Mar 28, 2012 at 5:24:21 PM
 *********************************************/

{string} Weekdays = ...;  
{string} Months = ...;

//MODEL FILE:  
tuple drug {
  key string name;
  int priority;
  int maxPerDay;
  float timeInterval;
  // 0 = empty stomach, 1 = take with meal, 2 = doesn't matter 
  int meal; 
}

tuple block {
  key int id;
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

dvar int DrugAssignments[Drugs][Blocks] in 0..1;

//goal: schedule as many drugs as possible
maximize
  sum(d in Drugs)
    sum( b in Blocks )
    	(d.priority * DrugAssignments[d][b]); 

subject to {
  //time interval constraint
  /*
  forall(d in Drugs, b in Blocks) {
    forall(others in Blocks : others != b){
    if (abs(b.start - others.start) <= d.timeInterval){
      DrugAssignments[d][others] == 0;
  }  
}  
} 
  forall(d in Drugs, b in Blocks, c in Blocks :c.start < (b.start + d.timeInterval) && c.id != b.id){
     ctTimeIntervalConstraints:
     DrugAssignments[d][b] + DrugAssignments[d][c] <= 1;          
  } 
  */
  //respect Drug Incompatibility 
  
  forall( <d1, d2> in DrugIncompat , b in Blocks )
    ctIncompatibilityConstraint:
    DrugAssignments[d1][b] + DrugAssignments[d2][b] <=1;
  
  //respect per day constraint
  forall(d in Drugs){
 	//ctPerDayConstraint:  
 		sum( b in Blocks)
	DrugAssignments[d][b] <= d.maxPerDay; 
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
}
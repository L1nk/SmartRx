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
  float timeInterval;
  // 0 = empty stomach, 1 = take with meal, 2 = doesn't matter 
  int meal; 
}

tuple block {
  float start;
  float end;
  int meal; 
}

{drug} Drugs = ...;
{block} Blocks = ...;

dvar int DrugAssignments[Drugs][Blocks] in 0..1;

//goal: schedule as many drugs as possible
maximize
  sum(d in Drugs, b in Blocks)
    DrugAssignments[d][b];
    
subject to {
  //time interval constraint
  forall(d in Drugs, b in Blocks, others in Blocks : others != b) {
    if (abs(b.start - others.start) <= d.timeInterval){
      DrugAssignments[d][b] == 0;
  }  
}  
  //respect meal constraint
  forall(d in Drugs, b in Blocks : b.meal == 1) {
    DrugAssignments[d][b]* d.meal >= 1;
  }
   forall(d in Drugs, b in Blocks : b.meal == 0) {
    DrugAssignments[d][b]* d.meal == 1;
  }         
}
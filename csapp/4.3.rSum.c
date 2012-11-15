#include <stdio.h>

int rSum(int* start,int count){
  if(count<=0)return 0;
  return *start + rSum(start+1,count-1);
}
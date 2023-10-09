#!/bin/bash

pid=$(jcmd | grep apache | awk '{print $1}')

min_space=$(jstat -gcmetacapacity  $pid | awk '{print($1)}')
max_space=$(jstat -gcmetacapacity  $pid | awk '{print($2)}')
cur_space=$(jstat -gcmetacapacity  $pid | awk '{print($3)}')
usage=$(jstat -gcold  $pid | awk '{print($3)}')
usage_perc=$(jstat -gcutil $pid | awk '{print($5)}')

echo "Max space: $min_space"
echo "Min space: $max_space"
echo "Current space: $cur_space"
echo "Used space: $usage"
echo "Percentage used: $usage_perc"
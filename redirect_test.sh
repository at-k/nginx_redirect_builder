#!/bin/sh

cnt=0
sum=0

tgt_check_list=st-list_translate.csv

while read line; do
	if [ $cnt -lt 1 -a $sum -gt 0 ]; then
		d=$(echo $line | cut -d, -f1)
		s=$(echo $line | cut -d, -f2)

		if [ $s = "-" ]; then
			continue
		fi

		r=$(curl -I "$s" 2> /dev/null | grep location | cut -d" " -f2 | sed 's/.$//' | tail -1)

		if [ "$d" != "$r" ]; then
			e=$(echo $r | tail -c 2)
			if [ $e != "/" ]; then
				echo "error: $sum"
				echo "src: $s"
				echo "dst: $d"
				echo "res: $r"
				exit
			fi
		fi
	fi

	cnt=$[$cnt + 1]
	sum=$[$sum + 1]

	if [ $cnt -ge 10 ]; then
		echo $sum
		cnt=0
	fi
done < ${tgt_check_list}

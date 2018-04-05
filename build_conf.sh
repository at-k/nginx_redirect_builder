#!/bin/sh
#
#
# 遅い、いい加減シェルの限界か

tgt_list_file=list_translate.csv
#tgt_list_file=hoge.csv

echo > redirect_tmp
echo > get_type_tmp

while read line; do
	src=$(echo $line | cut -d, -f2)
	dst=$(echo $line | cut -d, -f1)
	src_param=""
	dst_param=""
	dst_dir=""

	src_param=$(echo $src | cut -d\? -f2 -s)
	if [ ! -z $src_param ]; then
		src_ptype=$(echo $src_param | cut -d= -f1 -s)
		src_param=$(echo $src_param | cut -d= -f2 -s)
		src_tmp=$(echo $src | cut -d/ -f4- -s | cut -d\? -f1 -s)
		dst_param=$(basename $(echo $dst))
		dst_dir=$(dirname $(echo $dst))
	else
		src_tmp=$(echo $src | cut -d/ -f4- )
		src_param=""
		dst_dir=$dst
	fi
	#echo $src
	#echo $dst_dir
	#echo $src_tmp
	if [ ! -z "$src_tmp" -a "$src_tmp" != "-"]; then
		echo "location = /$src_tmp { include conf.d/get_type; rewrite ^(.*)$ $dst_dir\$type?;}" >> redirect_tmp
	fi

	if [ ! -z "$src_param" ]; then
		echo "if ( \$arg_$src_ptype = \"$src_param\" ) { set \$type \"/$dst_param\"; }" >> get_type_tmp
#		url_enc=$(echo $src_param | nkf -WwMQ | tr = % | tr -d '\n')
		url_enc=$(echo $src_param | nkf -WwMQ | tr -d '\n' | sed -e 's/==/=/' -e 's/=/%/g')
		echo "if ( \$arg_$src_ptype = $url_enc ) { set \$type \"/$dst_param\"; }" >> get_type_tmp
#		printf %s%q%s "if ( \$arg_$src_ptype = " "$url_enc" " ) { set \$type \"/$dst_param\"; }" >> get_type_tmp
	fi

done < $tgt_list_file

echo 'set $type "";' > get_type
sort -t" " -k5 get_type_tmp | uniq | sort -t" " -k10 >> get_type
sort -t" " -k3 redirect_tmp | uniq > redirect


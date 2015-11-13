# Author: Sing-Han Chen (singhan.chen AT gmail DOT com)
# Date:   11/13/2015
# This script is released under WTFPL Version 2 (http://www.wtfpl.net/)

echo "===================================================================="
echo "=          WELCOME! This is the string match tool                  ="
echo "===================================================================="

SEARCH_FOLDERS_SET="./* ./script/* ./css/* ../httpd/"
MATCHED_STR_LOG="output.log"
NOT_MATCHED_STR_LOG="output_unused.log"

if [ -z "$1" ]; then
	echo "Usage: string_match.sh [file_of_string_source] [(optional) start tag]";
	exit;
fi

if [ ! -e "$1" ]; then
	echo "WARRING: cannot find $1";
	echo "Usage: string_match.sh [file_of_string_source] [(optional) start tag]";
	exit;
fi

if [ -z "$2" ]; then
	tmp_line=$(head -n 1 "$1");
	start_str_tag=${tmp_line%%=*};

	echo "You are not setting start to search tag.";
	echo "We are going to search from the first string tag in your file.";
	exit;
else
	start_str_tag=$2;
	echo "You have input a tag to begin this search!";
fi
echo "The first tag we are looking for will be \"$start_str_tag\"";
echo ""

if [ $MATCHED_STR_LOG ]; then
	echo "WARRING: $MATCHED_STR_LOG is exist, file will be overwrite.";
	echo "Enter 'stop' to cancel this script (press enter to continue)";
	read -r key;
	if [ "$key" == "stop" ]; then 
		echo "User stopped this script"
		exit;
	fi
	rm $MATCHED_STR_LOG;
fi

if [ $NOT_MATCHED_STR_LOG ]; then
	echo "WARRING: $NOT_MATCHED_STR_LOG is exist, file will be overwrite.";
	echo "Enter 'stop' to cancel this script (press enter to continue)";
	read -r key;
	if [ "$key" == "stop" ]; then 
		echo "User stopped this script"
		exit;
	fi
	rm $NOT_MATCHED_STR_LOG;
fi

echo "====== Start to match the strings from [$1] ========"
matched_cnt=0;
not_matched_cnt=0;
start_flag='n'
start_time=$(date -u +"%s")
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == $start_str_tag* ]]; then
		start_flag="y";
	fi
	if [[ $start_flag == "y" ]]; then
#	    echo "Text read from file: $line";
		string_tag=${line%%=*};
#		echo $string_tag;
		if grep -q "\"$string_tag\"" $SEARCH_FOLDERS_SET;
		then
			echo -ne "\r\033[K (Searching $((matched_cnt+not_matched_cnt))) ";
			echo -ne "[$string_tag] hit!\r";
			echo "$line" >> $MATCHED_STR_LOG;
			matched_cnt=$((matched_cnt + 1));
		else
			echo -ne "\r\033[K (Searching $((matched_cnt+not_matched_cnt))) ";
			echo -ne "[$string_tag] is an unused string\r";
			echo "$line" >> $NOT_MATCHED_STR_LOG;
			not_matched_cnt=$((not_matched_cnt + 1));
		fi
	fi
done < "$1"
echo -ne "\r\033[K\n"
end_time=$(date -u +"%s")
diff=$((end_time-start_time))

echo "====== Completed!! ========"
echo "Statistic:"
echo "  string matched count: $matched_cnt"
echo "  string not matched count: $not_matched_cnt"
echo "  time spent on searching: $(($diff / 60)) min $(($diff % 60)) sec"
echo "Ouput file:"
echo "  matched string log: $MATCHED_STR_LOG"
echo "  not matched string log: $NOT_MATCHED_STR_LOG"


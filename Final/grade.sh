#!/usr/bin/env bash

scans_dir="./scans"
csv_file="./grades.csv"

single_student_actions() {
	pdf="$1"
	csv="$2"
	page=3

	student=$(echo "$pdf" | awk -F'.' '{print $1}')
	zathura "$pdf" -P "$page"
	read -p "Part2: Algorithm identified (out of 1): " algorithm
	read -p "Part2: Physical problem identified (out of 1): " physics
	read -p "Part2: Correctness of interpretation (out of 2): " correctness
	read -p "Part2: Clarity (out of 1): " clarity
	read -p "Part3Q4: Student chose Q4? (y or nothing): " part3

	if [[ "$algorithm" -eq "" ]]; then
	    algorithm=0
	fi
	if [[ "$physics" -eq "" ]]; then
	    physics=0
	fi
	if [[ "$correctness" -eq "" ]]; then
	    correctness=0
	fi
	if [[ "$clarity" -eq "" ]]; then
	    clarity=0
	fi

	if [[ "$part3" -eq "" ]]; then
	    part3="n"
	fi

    string="$student,$algorithm,$physics,$correctness,$clarity,$part3"
	echo "$string" >> "$csv"
	echo "Printed $string into $csv"
}

overwrite_or_continue() {
    csv_file="$1"
	if [[ -f "$csv_file" ]]; then
		read -p "File $csv_file was found. Overwrite (o) or continue (c)? " overwrite_vs_continue
		if [ "$overwrite_vs_continue" = "o" ]; then
		    echo "Overwriting the csv file"
			students_marked=-1
		elif [ "$overwrite_vs_continue" = "c" ]; then
			num_csv_lines=$(wc -l "$csv_file" | awk '{print $1}')
			if [ "$num_csv_lines" = "1" ]; then
				echo "No students marked. Overwriting"
		        students_marked=-1
			else
			    students_marked=$((num_csv_lines - 1))
	            echo "Students marked: $students_marked"
			fi
		else
			echo "Provided undeclared option: $overwrite_or_continue. Only allowed options are: o, c."
			exit 1
		fi
	else
		students_marked=-1
		echo "No csv file found, so no need to overwrite"
	fi
}


loop_through_students() {
	directory=$(realpath "$1" )
	csv_file=$( realpath "$2" )

	overwrite_or_continue "$csv_file"
	if [[ "$students_marked" -eq -1 ]]; then
	    setup_csv_file "$csv_file"
	fi

	(
    	cd "$directory" || { echo "Directory $directory not found" ; exit 1; }
    
		i=0
    	pdfs_list=$(ls -1)
        for pdf in $pdfs_list; do
			i=$((i + 1))
			echo "i=$i"
			if [[ i -gt $students_marked ]]; then
			    echo "Working i=$i"
			    single_student_actions "$pdf" "$csv_file"
			fi
        done
    )
}

setup_csv_file() { 
	csv_file="$1"
	csv_columns="Name,P2_Algorithm,P2_Physics,P2_Correctness,P2_Clarity,P3Q4"
	echo "$csv_columns" > "$csv_file"
}

loop_through_students "$scans_dir" "$csv_file"

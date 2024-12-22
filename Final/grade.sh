#!/usr/bin/env bash

scans_dir="./scans"
csv_file="./grades.csv"

single_student_actions() {
	pdf="$1"
	csv="$2"

	student=$(echo "$pdf" | awk -F'.' '{print $1}')
	zathura "$pdf"
	read -p "PartII: Algorithm identified (out of 1)\n" algorithm
	read -p "PartII: Physical problem identified (out of 1)\n" physics
	read -p "PartII: Correctness of interpretation (out of 2)\n" correctness
	read -p "PartII: Clarity (out of 1)\n" clarity
	read -p "PartIV: Student chose Q3? (y or nothing)\n" part4

    string="$student,$algorithm,$physics,$correctness,$clarity,$part4"
	echo "$string" >> "$csv"
	echo "Printed $string into $csv"
}

loop_through_students() {
	directory=$( realpath "$1" )
	csv_file=$( realpath "$2" )
	setup_csv_file "$csv_file"
	(
    	cd "$directory" || { echo "Directory $directory not found" ; exit 1; }
    
    	pdfs_list=$(ls -1)
        for pdf in $pdfs_list; do
			single_student_actions "$pdf" "$csv_file"
        done
    )
}

setup_csv_file() { 
	csv_file="$1"
	csv_columns="Name,P2_Algorithm,P2_Physics,P2_Correctness,P2_Clarity"
	echo "$csv_columns" > "$csv_file"
}

loop_through_students "$scans_dir" "$csv_file"

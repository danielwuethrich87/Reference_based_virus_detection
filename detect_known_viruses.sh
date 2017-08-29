#!/bin/bash

export working_dir=$PWD
export cores=$5
export reference_db=$4
export reads_R2=$3
export reads_R1=$2
export sample_id=$1
export software_location=$(dirname $0)


echo
echo "Input:"
echo


echo sample_id:$sample_id
echo read_file_R1:$reads_R1
echo read_file_R2:$reads_R2
echo reference_db:$reference_db
echo cores:$cores


echo
echo "Checking software ..."
echo

is_command_installed () {
if which $1 &>/dev/null; then
    echo "$1 is installed in:" $(which $1)
else
    echo
    echo "ERROR: $1 not found."
    echo
    exit
fi
}



is_command_installed python
is_command_installed samtools
is_command_installed bowtie2

echo

if [ -r "$reads_R1" ] && [ -r "$reads_R2" ] && [ -n "$sample_id" ] && [ -r "$reference_db" ] && [ "$cores" -eq "$cores" ]

then

#actual analysis---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#---Mapping---

mkdir -p "$working_dir"/results/"$sample_id"/mapping

bowtie2 --no-unal --sensitive  -p "$cores" -x "$reference_db" -1 "$reads_R1" -2 "$reads_R2" -S "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sam 2> "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_mapping_Info.txt

samtools sort -@ "$cores" -T "$working_dir"/results/"$sample_id"/mapping/temp_sort -o "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sorted.bam "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sam
samtools rmdup "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sorted.bam "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sorted.removed_duplicates.bam
samtools index "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sorted.removed_duplicates.bam
samtools idxstats "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sorted.removed_duplicates.bam > "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sorted.removed_duplicates.idxstats
samtools depth -aa "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sorted.removed_duplicates.bam > "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_read_depth.tab

rm "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sam
rm "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sorted.bam

#---Get covered viruses---

mkdir -p "$working_dir"/results/"$sample_id"/coverage_analysis

awk '{if ($3 != 0) print}' "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_read_depth.tab   > "$working_dir"/results/"$sample_id"/coverage_analysis/"$sample_id"_non_zero_positions.tab

python "$software_location"/software/get_covered.py  "$reference_db" "$sample_id" "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sorted.removed_duplicates.idxstats  "$working_dir"/results/"$sample_id"/coverage_analysis/"$sample_id"_non_zero_positions.tab > "$working_dir"/results/"$sample_id"/coverage_analysis/"$sample_id".candidates.tab


to_investigate_genomes=$(
python << END
import os
input_file = [n for n in open("$working_dir/results/$sample_id/coverage_analysis/$sample_id.candidates.tab",'r').read().replace("\r","").split("\n") if len(n)>0]
candidates=""
for line in input_file:
	candidates+=" "+line.split("::")[1].split(" ")[0]
print candidates
END
2>&1) 

mkdir -p "$working_dir"/results/"$sample_id"/coverage_analysis/virus_alingments
mkdir -p "$working_dir"/results/"$sample_id"/result

echo "Sample	Fraction covered	mean read depth	median read depth	number of reads	Length of Ref sequence	BP covered of Ref sequence	T-test	Ref ID" > "$working_dir"/results/"$sample_id"/result/"$sample_id"_virus_evidence.tab



for virus in $to_investigate_genomes
do

samtools view  "$working_dir"/results/"$sample_id"/mapping/"$sample_id"_aligment.sorted.removed_duplicates.bam "$virus" -b -o "$working_dir"/results/"$sample_id"/coverage_analysis/virus_alingments/"$sample_id"_"$virus"_aligment.sorted.removed_duplicates.bam

samtools view -h -o "$working_dir"/results/"$sample_id"/coverage_analysis/virus_alingments/"$sample_id"_"$virus"_aligment.sorted.removed_duplicates.sam "$working_dir"/results/"$sample_id"/coverage_analysis/virus_alingments/"$sample_id"_"$virus"_aligment.sorted.removed_duplicates.bam

python "$software_location"/software/analyse_read_distribution.py "$working_dir"/results/"$sample_id"/coverage_analysis/virus_alingments/"$sample_id"_"$virus"_aligment.sorted.removed_duplicates.sam "$working_dir"/results/"$sample_id"/coverage_analysis/"$sample_id".candidates.tab "$virus" >> "$working_dir"/results/"$sample_id"/result/"$sample_id"_virus_evidence.tab

done
#actual analysis---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

else

echo " "
echo "ERROR: Incorrect input!"
echo "Virus detection pipeline version 0.1 by Daniel Wüthrich (danielwue@hotmail.com)"
echo " "
echo "Usage: "
echo "  sh bacteria_assembly.sh <Sample_ID> <Reads_R1> <Reads_R2> <reference_db> <Number_of_cores>"
echo " "
echo "  <Sample_ID>               Unique identifier for the sample"
echo "  <Reads_R1>                Foreward read file"
echo "  <Reads_R2>                Reversed read file"
echo "  <reference_db>            Nucleatide database"
echo "  <Number_of_cores>         number of parallel threads to run (int)"
echo " "

if ! [ -n "$sample_id" ];then
echo Incorrect input: "$sample_id"
fi
if ! [ -r "$reads_R1" ];then
echo File not found: "$reads_R1"
fi
if ! [ -r "$reads_R2" ];then
echo File not found: "$reads_R2"
fi
if ! [ "$cores" -eq "$cores" ] ;then
echo Incorrect input: "$cores"
fi
if ! [ -r "$genus" ];then
echo File not found: "$reference_db" 
fi


fi


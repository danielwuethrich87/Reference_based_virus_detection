Reference based virus detection
=======================

This pipeline is remapping reads to the reference genomes from Viruses. Also alternative databases can be used like antibiotica resistances.<br />

Steps:<br />
-Remapping reads against nucleotide database<br />
-Selecting genomes covered with reads<br />
-Testing the distribution of the reads on the found sequences<br />

#Requirements:

-Linux 64 bit system<br />

-python (version 2.7)<br />
-samtools (version 1.3)<br />
-bowtie2 (version 2.3.0)<br />

#Installation:

wget https://github.com/danielwuethrich87/Reference_based_virus_detection/archive/master.zip<br />
unzip master.zip<br />
cd Reference_based_virus_detection-master<br />
sh get_dbs.sh<br />

#Usage:

sh bacteria_assembly.sh <Sample_ID> <Reads_R1> <Reads_R2> <reference_db> <Number_of_cores> <br />

<Sample_ID>               Unique identifier for the sample<br />
<Reads_R1>                Foreward read file<br />
<Reads_R2>                Reversed read file<br />
<reference_db>            Nucleatide database<br />
<Number_of_cores>         number of parallel threads to run (int)<br />


#example:


#!/bin/sh<br />
#$ -q all.q<br />
#$ -e $JOB_ID.cov.err<br />
#$ -o $JOB_ID.cov.out<br />
#$ -cwd #executes from the current directory and safes the ouputfiles there<br />
#$ -pe smp 24<br />

module add UHTS/Analysis/samtools/1.3;<br />
module add UHTS/Aligner/bowtie2/2.3.0;<br />

for i in CF1<br />

do<br />

sh /home/dwuethrich/Application/known_virus_detection/detect_known_viruses.sh "$i" /data/projects/p077_seuberlich_virus_2nd/reads_20150103/Project_Neurocenter_TS/Sample_23871a/23871a_GTGGCC_L003_R1_000.fastq.gz /data/projects/p077_seuberlich_virus_2nd/reads_20150103/Project_Neurocenter_TS/Sample_23871a/23871a_GTGGCC_L003_R2_000.fastq.gz /home/dwuethrich/Application/known_virus_detection/databases/megares_database_v1.01.fasta "$NSLOTS"<br />



done<br />


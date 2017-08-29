from scipy import stats
import os
import sys
import numpy as np

inputOptions = sys.argv[1:]

#usage: python get_covered.py ../../alignment/genomes/viral.1.1.genomic.fna strain


def main():

	input_file = [n for n in open(inputOptions[0],'r').read().replace("\r","").split("\n") if len(n)>0]
	starts={}
	seq_length={}
	genome=""
	read_lengths=[]
	for line in input_file:
		if line[0:1]!="@":
			flag= "000000000000"[len(str(bin(int(line.split("\t")[1]))[2:])):12]+str(bin(int(line.split("\t")[1]))[2:])
			read_lengths.append(len(line.split("\t")[9]))	

			if flag[7:8]=="0":
				starts[int(line.split("\t")[3])]=1

			if genome!="":
				assert genome == line.split("\t")[2], "more than one genome is reference"
			genome=line.split("\t")[2]

		if line[0:3]=="@SQ":
			seq_length[line.split("SN:")[1].split("\t")[0]]=int(line.split("LN:")[1])
	counter=0	
	distances=list()

	for start in starts.keys():
		if counter>0:
		
			distances.append(start-last)		

		last=start
		counter+=1

	if len(starts.keys()) != 0:
		mean_expected=float(seq_length[genome]-np.mean(read_lengths))/float(len(starts.keys()))

		p_value = stats.ttest_1samp(distances,mean_expected)[1]
	else:
		p_value = "nan"
	
	info_file = [n for n in open(inputOptions[1],'r').read().replace("\r","").split("\n") if len(n)>0]
	lines={}
	for line in info_file:
		lines[line.split("::")[1].split(" ")[0]]=line

	k=str(inputOptions[2])

	print lines[k].split("::")[0]+str(p_value)+"\t"+lines[k].split("::")[1]

main()

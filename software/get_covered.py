#!/usr/bin/env python

import numpy as np
import subprocess
import sys
import os
import sys
import math

inputOptions = sys.argv[1:]

#usage: python get_covered.py ../../alignment/genomes/viral.1.1.genomic.fna strain


def main():

	sequences=read_fasta(inputOptions[0])
	covered=read_cov(inputOptions[3])
	sequences_2_mapped_reads=read_idxstats(inputOptions[2])
	all_hits=filter_covered(sequences[0],sequences[1], covered, inputOptions[1],sequences_2_mapped_reads)
	for hit in sorted(all_hits, reverse=True):
		print hit
			
def filter_covered(sequences,info, covered, strain,sequences_2_mapped_reads):
	all_hits=list()
	for name in sequences_2_mapped_reads.keys():
		if sequences_2_mapped_reads[name] > 0:

			if (float(len(covered[name]))/float(len(sequences[name])))>=0.00:
				all_hits.append(strain+"\t"+str(round((float(len(covered[name]))/float(len(sequences[name]))),4))+"\t"+str(round((np.mean(covered[name])),2))+"\t"+str(round((np.median(covered[name])),2))+"\t"+str(sequences_2_mapped_reads[name])+"\t"+str(len(sequences[name]))+"\t"+str(len(covered[name]))+"\t::"+info[name])

	return all_hits


def read_idxstats(idxstats_file_name):

	idxstats_file = [n for n in open(idxstats_file_name,'r').read().replace("\r","").split("\n") if len(n)>0]
	
	sequences_2_mapped_reads={}

	for line in idxstats_file:
		sequences_2_mapped_reads[line.split("\t")[0]]=int(line.split("\t")[2])

	return sequences_2_mapped_reads

def read_fasta(fasta_file_name):
	fasta_file = [n for n in open(fasta_file_name,'r').read().replace("\r","").split("\n") if len(n)>0]
	
	sequences={}
	info={}
	for line in fasta_file:
		if line[0:1]==">":
			name = line.split(" ")[0][1:]
			sequences[name]=""
			info[name]=line[1:]
		else:
			sequences[name]+=line

	return sequences,info


def read_cov(cov_file_name):	
	covered={}
	with open(cov_file_name,'r') as f:

    		for line in f:

			seq=line.split("\t")[0]
			if (seq in covered.keys()) == bool(0):
				covered[seq]=list()

			coverage=int(line.split("\t")[2])
			if int(coverage)>0:
				covered[seq].append(coverage)
	
	return covered

	


		




main()

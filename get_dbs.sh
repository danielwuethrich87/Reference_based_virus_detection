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


is_command_installed bowtie2


mkdir databases
cd databases

echo
echo Dowloading databases ...
echo

wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
wget https://megares.meglab.org/download/megares_v1.01/megares_database_v1.01.fasta

echo
echo Unpacking databases ...
echo

gunzip viral.1.1.genomic.fna.gz

echo
echo Preparing databases ...
echo

bowtie2-build viral.1.1.genomic.fna viral.1.1.genomic.fna
bowtie2-build megares_database_v1.01.fasta megares_database_v1.01.fasta

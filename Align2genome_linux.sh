read "?What is the data directory? This should be a directory which contains multiple subdirectories (one or two per sample) which in turn contain .fastq.gz files." dataDir;
read "?What is the desired output directory? " outputDir;
read "?What is the path to the directory containing your STAR-created reference genome? " genomeDir;
datestr=$(date +"%Y_%m%d");
for subdir in $dataDir/*; do
echo '\n'
cd $subdir;
fastqfiles=$(find . -maxdepth 1 -name '*.fastq.gz');
if [ -z "$fastqfiles" ]; 
then
	echo $subdir:t has no fastq files in the first level down
else
	echo processing fastqfiles from $subdir:t
	STAR --genomeDir $genomeDir --runThreadN 16 -- readFilesIn *.fastq.gz \
	--readFilesCommand gunzip -c --outFileNamePrefix $outputDir/STAR_"$(cut -d'.' -f1 <<<"$subdir:t")"_$datestr/ \
	--outSAMtype BAM Unsorted;
fi
done;
unset datestr;
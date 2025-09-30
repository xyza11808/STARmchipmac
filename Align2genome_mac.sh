#!/bin/bash

# A shebang line is necessary to tell the system which interpreter to use.
# It ensures the script runs consistently regardless of the user's default shell.

# Prompt for user input using 'read -p'. This is standard in bash/zsh.
read -p "What is the data directory? This should be a directory which contains multiple subdirectories (one or two per sample) which in turn contain .fastq.gz files: " dataDir
read -p "What is the desired output directory? " outputDir
read -p "What is the path to the directory containing your STAR-created reference genome? " genomeDir

# Check if the output directory exists. If not, create it.
if [ ! -d "$outputDir" ]; then
    echo "Output directory not found. Creating $outputDir..."
    mkdir -p "$outputDir"
fi

datestr=$(date +"%Y_%m%d")

# Iterate through subdirectories. Using 'find' is more robust than a simple glob.
# The '-mindepth 1 -maxdepth 1' options ensure only immediate subdirectories are processed.
find "$dataDir" -mindepth 1 -maxdepth 1 -type d | while read -r subdir; do
    echo ""
    # Get the basename of the subdirectory path
    subdir_basename=$(basename "$subdir")
    
    # Use find to check for .fastq.gz files without changing the directory.
    # This avoids issues with 'cd' inside a loop.
    fastqfiles=$(find "$subdir" -maxdepth 1 -name '*.fastq.gz')
    
    if [ -z "$fastqfiles" ]; then
        echo "No fastq files found in $subdir_basename"
    else
        echo "Processing fastq files from $subdir_basename"
        
        # Create a sample-specific output directory
        output_prefix="$outputDir/STAR_${subdir_basename}_${datestr}/"
        mkdir -p "$output_prefix"
        
        # Run STAR with the necessary parameters.
        # Use a subshell to avoid issues with globbing in the main script.
        (
            cd "$subdir" || exit
            /Users/yu/RNAseq/STAR/bin/MacOSX_x86_64/STAR \
                --genomeDir "$genomeDir" \
                --runThreadN 10 \
                --readFilesIn *.fastq.gz \
                --readFilesCommand gunzip -c \
                --outFileNamePrefix "${output_prefix}/" \
                --outSAMtype BAM Unsorted
        )
    fi
done

echo "Script finished."

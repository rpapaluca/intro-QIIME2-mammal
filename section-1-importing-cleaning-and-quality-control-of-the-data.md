---
title: 'Section 1: Importing, cleaning and quality control of the data'
teaching: 100
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How do you import paired-end FASTQ files into QIIME2 using the CasavaOneEight format?
- Why is it important to remove primers before denoising, and how is this done?
- How can you assess sequence quality in QIIME2, and what features of the quality plots help guide truncation parameters?
- What is the purpose of the dada2 denoise-paired command, and what are some key parameters that influence its output?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Import demultiplexed, paired ended sequencing data into QIIME2 using the appropriate format and command structure
- Explain why primer removal is necessary before denoising and apply cutadapt command with appropriate primer sequences and trimming parameters
- Generate and interpret sequence quality viusalisations from qiime demux summarise to determine suitable truncation lengths, based on quality score drop offs
- Summarise the function of DADA2 in QIIME2 and perform denoising of paired-end sequences using the DADA2 plugin, adjusting key parameters like truncation length and pooling method based on quality data.  

::::::::::::::::::::::::::::::::::::::::::::::::

## Import Data

These [samples](https://www.melbournebioinformatics.org.au/tutorials/tutorials/qiime2_mammal/qiime2_mammal/#the-study) were sequenced on a single Illumina MiSeq run using v3 (2 × 300 bp) reagents at the Walter and Eliza Hall Institute (WEHI), Melbourne, Australia. Data from WEHI came as paired-end, demultiplexed, unzipped *.fastq files with adapters still attached. Following the [QIIME2 importing tutorial](https://docs.qiime2.org/2023.9/tutorials/importing/), this is the Casava One Eight format. The files have been renamed to satisfy the Casava format as SampleID_FWDXX-REVXX_L001_R[1 or 2]_001.fastq e.g. CTRLA_Fwd04-Rev25_L001_R1_001.fastq.gz. The files were then zipped (.gzip).

Here, the data files (two per sample i.e. forward and reverse reads R1 and R2 respectively) will be imported and exported as a single QIIME 2 artefact file. These samples are already demultiplexed (i.e. sequences from each sample have been written to separate files), so a metadata file is not initially required.

::: Note
To check the input syntax for any QIIME2 command, enter the command, followed by --help e.g. qiime tools import --help
:::

Start by making a new directory analysis to store all the output files from this tutorial. In addition, we will create a subdirectory called seqs to store the exported sequences.

``` bash
cd
mkdir -p analysis/seqs
```

Run the command to import the raw data located in the directory raw_data and export it to a single QIIME 2 artefact file, combined.qza.

``` bash
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path raw_data \
--input-format CasavaOneEightSingleLanePerSampleDirFmt \
--output-path analysis/seqs/combined.qza
```

##Remove Primers
These sequences still have the primers attached - they need to be removed (using cutadapt) before denoising. 

For this experiment, amplicons were amplified following the Earth Microbiome protocol with 515F (Caporaso)– 806R (Caporaso) primers targeting the v4 region of the 16S rRNA gene. The reads came back from the sequencer with primers attached, which are removed before denoising using cutadapt (v4.5 with python v3.8.15). 

With cutadapt, the sequence specified and all bases prior are trimmed; most sequences were trimmed at ~50 base pairs (bp). An error rate of 0.15 was used to maximize the number of reads that the primers were removed from while excluding nonspecific cutting. Any untrimmed read was discarded.

``` bash
qiime cutadapt trim-paired \
--i-demultiplexed-sequences analysis/seqs/combined.qza \
--p-front-f GTGCCAGCMGCCGCGGTAA \
--p-front-r GGACTACHVGGGTWTCTAAT \
--p-discard-untrimmed \
--p-error-rate 0.15 \
--output-dir analysis/seqs_trimmed \
--verbose
```

::: Tips for Your Own Samples and Analyses
- Remember to ask you sequencing facility if the raw data you get has the primers attached - they may have already been removed.
- The primers specified (515F (Caporaso)– 806R (Caporaso) targeting the v4 region of the bacterial 16S rRNA gene) correspond to this specific experiment - they will likely not work for your own data analyses.
- The error rate parameter, --p-error-rate, will likely need to be adjusted for your own sample data to get 100% (or close to it) of reads trimmed.
:::

## Create and interpret sequence quality data

After trimming adapters and primers, it's important to check the overall quality of the sequence data before proceeding to denoising. This step helps you make informed choices about where to trim or truncate your reads and whether any samples should be excluded from analysis.

To do this, we will generate a summary visualization of the demultiplexed and trimmed data using QIIME2.

Create a subdirectory in analysis called visualisations to store all files that we will visualise in one place

``` bash
mkdir analysis/visualisations
```
``` bash
qiime demux summarize \
--i-data analysis/seqs_trimmed/trimmed_sequences.qza \
--o-visualization analysis/visualisations/trimmed_sequences.qzv
```

Copy the analysis/visualisations/trimmed_sequences.qzv file to your local computer and view it using [QIIME 2 View](https://view.qiime2.org/).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Read Quality and Demux Output
Click [here](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Fm484d0ukdn9n7a2gdw7hh%2Ftrimmed_sequences.qzv%3Frlkey%3Dta8bbyyuz6ucpyn4jymx78bp2%26dl%3D1) to view the trimmed_sequence.qzv file in QIIME 2 View. 

- Make sure to switch between the “Overview” and “Interactive Quality Plot” tabs in the top left hand corner. 
- Click and drag on the plot to zoom in. Double click to zoom back out to full size. 
- Hover over a box to see the parametric seven-number summary of the quality scores at the corresponding position.
::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Things To Look Out For In Quality Data

- Where does the median quality drop below 35?
Look at the per-base sequence quality plots for forward (R1) and reverse (R2) reads. Identify the base pair position where the median quality score begins to sharply decline. This informs your choices for --p-trunc-len-f and --p-trunc-len-r in the next step.

- Are there any samples with very low read counts?
Under the Interactive Sample Detail tab, check for samples with fewer than 1000 reads. These may not provide reliable data and might need to be excluded later in R or at the diversity filtering stage.

- Overall quality trends across reads
It's normal for reverse reads (R2) to have lower quality toward the end. This may influence your decision to truncate them earlier than forward reads.
::::::::::::::::::::::::::::::::::::::::::::::::::

## Denoising the data
Trimmed sequences are now quality assessed using the dada2 plugin within QIIME2. dada2 denoises data by modelling and correcting Illumina-sequenced amplicon errors, and infers exact amplicon sequence variants (ASVs), resolving differences of as little as 1 nucleotide. Its workflow consists of filtering, de-replication, reference‐free chimera detection, and paired‐end reads merging, resulting in a feature or ASV table.

::: Note
This step may long time to run (i.e. hours), depending on files sizes and computational power.
:::

::::::::::::::::::::::::::::::::::::: challenge

## Check Your Quality Assessment Understanding

Q: Based on your assessment of the quality plots from the trimmed_sequences.qzv file generated in the previous step, what values would you select for p-trunc-len-f and p-trunc-len-r in the command below? Hint: Look for the position where the median quality score drops below 35 for both forward and reverse reads?

:::::::::::::::: solution

A: For version qiime2.2023.9 (other QIIME2 versions may slightly differ), open trimmed_sequences.qzv file in QIIME2 view and select the  “Interactive Quality Plot” tab. Zoom in on the quality plots to determine the base pair position where the median quality drops below 35:
- Forward reads: ~253 bp
- Reverse reads: ~208 bp

While these are the technical thresholds, it's often better to truncate more conservatively to improve quality and merging success. In this workshop, we use:
- p-trunc-len-f 213
- p-trunc-len-r 168

This trims an extra ~40 bp to ensure high-quality sequences are retained.

Try experimenting with different truncation values and compare the DADA2 denoising stats to see how your choice affects read retention and quality.

:::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::

In the following command, a pooling method of ‘pseudo’ is selected. With the pseudo-pooling method, samples are denoised independently once, ASVs detected in at least 2 samples are recorded, and samples are denoised independently a second time, but this time with prior knowledge of the recorded ASVs and thus higher sensitivity to those ASVs. This is better than the default of ‘independent’ (where samples are denoised independently) when you expect samples in the run to have similar ASVs overall.

::: Note - Workshop Participants Only
Due to computational limitations in a workshop setting, this command will be run staggered (by co-ordinating with other users on the Nectar Instance you are logged in to), with no more than two users per Instance running the command at the same time.
:::

The specified output directory must not pre-exist.

``` bash
qiime dada2 denoise-paired \
--i-demultiplexed-seqs analysis/seqs_trimmed/trimmed_sequences.qza \
--p-trunc-len-f xx \
--p-trunc-len-r xx \
--p-n-threads 0 \
--p-pooling-method 'pseudo' \
--output-dir analysis/dada2out \
--verbose
```

## Generate Summary Files
A [metadata file](https://docs.qiime2.org/2023.9/tutorials/metadata/) is required which provides the key to gaining biological insight from your data. The file echidna_metadata.tsv is provided in the home directory of your Nectar instance. This spreadsheet has already been verified using the plugin for Google Sheets, [keemei](https://keemei.qiime2.org/).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Things To Look Out For In Summary Data

- How many features (ASVs) were generated? Are the communities high or low diversity?

- Do BLAST searches of the representative sequences make sense? Are the features what you would expect e.g. marine or terrestrial?

- Have a large number (e.g. >50%) of sequences been lost during denoising/filtering? If so, the settings might be too stringent.

::::::::::::::::::::::::::::::::::::::::::::::::::

``` bash
qiime metadata tabulate \
--m-input-file analysis/dada2out/denoising_stats.qza \
--o-visualization analysis/visualisations/16s_denoising_stats.qzv \
--verbose
```

Copy analysis/visualisations/16s_denoising_stats.qzv to your local computer and view in QIIME 2 View (q2view).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Denoising Stats and Visualisation 
Click [here](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Fhwpyu01wm0ubb82wbb1dt%2F16s_denoising_stats.qzv%3Frlkey%3Dkuc0zfuozlpzr0c49sxhr96m7%26dl%3D1) to view the 16s_denoising_stats.qzv file in QIIME 2 View.
::::::::::::::::::::::::::::::::::::::::::::::::::

```bash
qiime feature-table summarize \
--i-table analysis/dada2out/table.qza \
--m-sample-metadata-file echidna_metadata.tsv \
--o-visualization analysis/visualisations/16s_table.qzv \
--verbose
```
Copy analysis/visualisations/16s_table.qzv to your local computer and view in QIIME 2 View (q2view).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Feature/ASV Summary and Visualisation 
Click [here](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Fhkvk2yqpnm4w9oy64maf3%2F16s_table.qzv%3Frlkey%3Dtm368u59rexzgdwpm9m6l11l1%26dl%3D1) to view the 16s_table.qzv file in QIIME 2 View.

Make sure to switch between the “Overview” and “Feature Detail” tabs in the top left hand corner.
::::::::::::::::::::::::::::::::::::::::::::::::::

```bash
qiime feature-table tabulate-seqs \
--i-data analysis/dada2out/representative_sequences.qza \
--o-visualization analysis/visualisations/16s_representative_seqs.qzv \
--verbose
```
Copy analysis/visualisations/16s_representative_seqs.qzv to your local computer and view in QIIME 2 View (q2view).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Representative Sequences and Visualisation 
Click [here](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2F2uesky0zntkapxhlr58gu%2F16s_representative_seqs.qzv%3Frlkey%3Dakmmi05wpcwommjuytgub2grk%26dl%3D1) to view the 16s_representative_seqs.qzv file in QIIME 2 View.
::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: keypoints 

- Use `.md` files for episodes when you want static content
- Use `.Rmd` files for episodes when you need to generate output
- Run `sandpaper::check_lesson()` to identify any issues with your lesson
- Run `sandpaper::build_lesson()` to preview your lesson locally

::::::::::::::::::::::::::::::::::::::::::::::::


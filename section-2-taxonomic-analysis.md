---
title: 'Section 2: Taxonomic Analysis'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- What factors influence the choice of reference database and classifier for taxonomic assignment in QIIME2?
- Why is it important to match the classifier to the specific 16S rRNA region targeted in your data?
- How do you assign taxonomy to ASVs using a pre-trained classifier in QIIME2?
- What is the purpose of filtering out mitochondria and chloroplast reads, and how is this done in QIIME2?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Identify three key factors (e.g., target region, update frequency, field norms) that influence the selection of a taxonomic reference database in QIIME2
- Apply the `qiime feature-classifier classify-sklearn command` with appropriate input files and parameters to assign taxonomy to representative sequences.
- Interpret the output of a .qzv taxonomy file using QIIME2 View to evaluate the accuracy and coverage of taxonomic assignments.
- Apply the `qiime taxa filter-table command` to remove mitochondrial and chloroplast reads, and assess the impact of filtering by comparing pre- and post-filtered feature tables. 

::::::::::::::::::::::::::::::::::::::::::::::::

Once we have high-quality representative sequences from each ASV, the next step is to **identify what organisms** those sequences belong to by comparing them to a reference database. This is known as **taxonomic classification**.

## Assign taxonomy
Here we will classify each identical read or *Amplicon Sequence Variant (ASV)* to the highest resolution based on a database. Common databases for bacteria datasets are [Greengenes](https://greengenes.secondgenome.com/), [SILVA](https://www.arb-silva.de/), [Ribosomal Database Project](https://rdp.cme.msu.edu/), or [Genome Taxonomy Database](https://gtdb.ecogenomic.org/). 

See Porter and Hajibabaei, 2020 for a review of different classifiers for metabarcoding research. 

The classifier chosen is dependent upon:

- Previously published data in a field
- The target region of interest
- The number of reference sequences for your organism in the database and how recently that database was updated.


A classifier has already been trained for you for the V4 region of the bacterial 16S rRNA gene using the SILVA database. The next step will take a while to run. *The output directory cannot previously exist*.

n_jobs = 1 This runs the script using all available cores

::: callout
## Note on Classifiers
The [classifier used here](https://www.dropbox.com/scl/fi/s42p5fif7szzm38swcu0m/silva_138_16s_515-806_classifier.qza?rlkey=ss983qau9rwgztis2gfulhjcz&dl=0) is only appropriate for the specific 16S rRNA region that this data represents. You will need to train your own classifier for your own data. For more information about training your own classifier, see Section 6: Extra Information.
:::

::: callout
## Note - Workshop Participants Only
Due to time limitations in a workshop setting, please do NOT run the `qiime feature-classifier classify-sklearn` command below. You will need to access a pre-computed `classification.qza` file that this command generates by running the following: `cd; mkdir analysis/taxonomy; cp /mnt/shared_data/pre_computed/classification.qza analysis/taxonomy`. If you have accidentally run the command below, ctrl-c will terminate it.
:::

The command below uses a pre-trained SILVA classifier to assign taxonomy to each ASV. This step may take a while to run and can be memory-intensive on large datasets.

``` bash
qiime feature-classifier classify-sklearn \
--i-classifier silva_138_16s_515-806_classifier.qza \
--i-reads analysis/dada2out/representative_sequences.qza \
--p-n-jobs 1 \
--output-dir analysis/taxonomy \
--verbose
```
::: callout
This step often runs out of memory on full datasets. Some options are to change the number of cores you are using (adjust `--p-n-jobs`) or add `--p-reads-per-batch 10000` and try again. The QIIME 2 forum has many threads regarding this issue so always check there was well.
:::

## Generate a viewable summary file of the taxonomic assignments
``` bash
qiime metadata tabulate \
--m-input-file analysis/taxonomy/classification.qza \
--o-visualization analysis/visualisations/taxonomy.qzv \
--verbose
```
Copy `analysis/visualisations/taxonomy.qzv` to your local computer and view in QIIME 2 View (q2view).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Taxonomy Visualisation 
[Click to view the taxonomy.qzv file in QIIME 2 View.](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Fpl5fz8bfv3iraqe7w3ryt%2Ftaxonomy.qzv%3Frlkey%3Dbnury3ua0w002sozo0eudklv7%26dl%3D1)
::::::::::::::::::::::::::::::::::::::::::::::::::

## Filtering

After classification, it’s common to filter out sequences that aren't relevant to the microbial community of interest. In this case, we’ll remove any reads classified as mitochondria or chloroplast, as these typically represent host or plant contamination. 

In this step, unassigned ASVs will be retained, as they may still represent valid but unknown microbial sequences. After filtering, we’ll generate a summary file to check how many features remain and assess the impact of the filtering step.

:::callout
**Note:** According to QIIME developer Nicholas Bokulich, low abundance filtering (i.e. removing ASVs containing very few sequences) is not necessary under the ASV model.
:::

``` bash
qiime taxa filter-table \
--i-table analysis/dada2out/table.qza \
--i-taxonomy analysis/taxonomy/classification.qza  \
--p-exclude Mitochondria,Chloroplast \
--o-filtered-table analysis/taxonomy/16s_table_filtered.qza \
--verbose
```

``` bash
qiime feature-table summarize \
--i-table analysis/taxonomy/16s_table_filtered.qza \
--m-sample-metadata-file echidna_metadata.tsv \
--o-visualization analysis/visualisations/16s_table_filtered.qzv \
--verbose
```

Copy `analysis/visualisations/16s_table_filtered.qzv` to your local computer and view in QIIME 2 View (q2view).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Filtered Reads Visualisation 
[Click to view the 16s_table_filtered.qzv file in QIIME 2 View.](https://view.qiime2.org/visualization/?src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2F9c1m746lxuplmwb79gldo%2F16s_table_filtered.qzv%3Frlkey%3D9iz32202xm36rfac3r7i50wtx%26dl%3D1&type=html)
::::::::::::::::::::::::::::::::::::::::::::::::::

Once your taxonomy has been assigned and filtered, you’ll be ready to explore the composition of microbial communities across your samples.

::::::::::::::::::::::::::::::::::::: keypoints 

- Taxonomic classification requires a region-specific, pre-trained classifier based on your primers and reference database.
- Removing mitochondrial and chloroplast sequences helps refine bacterial community composition and avoid host contamination in your analysis.
::::::::::::::::::::::::::::::::::::::::::::::::


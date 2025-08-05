---
title: 'Extra Information'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- What is the purpose of training your own classifier in QIIME2?
- Why must primer sequences be specified when extracting reference reads for classifier training?
- What QIIME2 commands are used to extract region-specific reads and train a custom classifier?
- In what situations would you need to train a custom classifier instead of using a pre-trained one? 

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain why training a custom classifier is necessary when analyzing marker gene sequences outside of standard target regions.
- Identify the QIIME2 commands required to extract region-specific sequences (extract-reads) and train a classifier (fit-classifier-naive-bayes).
- Recognize the importance of using appropriate forward and reverse primers when building a classifier tailored to your sequencing protocol.
- Describe the overall workflow for training a naive Bayes classifier using the SILVA database for 16S/18S rRNA gene analysis.

::::::::::::::::::::::::::::::::::::::::::::::::

:::callout
**NOTE:** The steps below outline how to train your own classifier for analysing custom datasets. This is **not required** for this workshop, but may be useful for independent projects.
:::

## Training a SILVA v138 Classifier for 16S/18S rRNA Gene Sequences
The [SILVA](https://www.arb-silva.de/) database (v138) can be used to train a classifier for taxonomic assignment of 16S or 18S rRNA marker gene sequences. To do this, you will need:

- Reference sequences (`silva-138-99-seqs.qza`)
- Reference taxonomy (`silva-138-99-tax.qza`)

You can download these artefacts from [SILVA](https://www.arb-silva.de/download/archive/) or through our [Dropbox here](https://www.dropbox.com/s/x8ogeefjknimhkx/classifier_files.zip?dl=0). 

### Step 1: Extract Reads For Your Target Region
You must specify your forward and reverse primer sequences to extract the relevant region from the reference database:
```bash
qiime feature-classifier extract-reads \
--i-sequences silva-138-99-seqs.qza \
--p-f-primer FORWARD_PRIMER_SEQUENCE \
--p-r-primer REVERSE_PRIMER_SEQUENCE \
--o-reads silva_138_marker_gene.qza \
--verbose
```
See the QIIME 2 documentation for recommended primers and further information.

### Step 2: Training the Classifier
The classifier is then trained using a Naive Bayes algorithm using your extracted sequences and taxonomy:
```bash
qiime feature-classifier fit-classifier-naive-bayes \
--i-reference-reads silva_138_marker_gene.qza \
--i-reference-taxonomy silva-138-99-tax.qza \
--o-classifier silva_138_marker_gene_classifier.qza \
--verbose
```
See the [QIIME 2 documentation](https://docs.qiime2.org/2023.9/plugins/available/feature-classifier/fit-classifier-naive-bayes/) for more information. 

This custom-trained classifier can now be used for your own datasets targeting specific 16S/18S regions.

::::::::::::::::::::::::::::::::::::: keypoints 

- You can train a custom classifier using SILVA reference data and your specific primer sequences to improve taxonomic accuracy for your own datasets.
- This step is optional and not required for the workshop, but useful for custom amplicon regions or future projects.

::::::::::::::::::::::::::::::::::::::::::::::::


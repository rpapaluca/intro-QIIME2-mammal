---
title: 'Section 4: Basic visualisations and statistics'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How can you use QIIME2 to visualise the relative abundance of taxa across samples?
- What do rarefaction curves tell you about sequencing depth and sample diversity?
- What’s the difference between alpha and beta diversity, and how are these metrics calculated and interpreted in QIIME2?
- How do you test for statistical differences in diversity or community composition between sample groups using QIIME2 visualisations?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Generate relative abundance bar plots using the qiime taxa barplot command and explore patterns across metadata categories by changing taxonomic levels and sorting options in QIIME 2 View.
- Interpret alpha rarefaction curves to evaluate whether sequencing depth is sufficient to capture microbial community diversity across samples.
- Explain the purpose of core diversity metrics (e.g., Shannon diversity, UniFrac distances), and apply the core-metrics-phylogenetic method to generate interactive visualisations for comparing diversity across samples.
- Assess group-level differences in alpha and beta diversity using appropriate statistical tests (e.g., PERMANOVA), and interpret QIIME2 outputs to draw biological insights from metadata categories.

::::::::::::::::::::::::::::::::::::::::::::::::

## Visualising ASV Relative Abundance

We can create bar charts to compare the relative abundance of ASVs across samples.

```bash
qiime taxa barplot \
--i-table analysis/taxonomy/16s_table_filtered.qza \
--i-taxonomy analysis/taxonomy/classification.qza \
--m-metadata-file echidna_metadata.tsv \
--o-visualization analysis/visualisations/barchart.qzv \
--verbose
```

Copy `analysis/visualisations/barchart.qzv` to your local computer and view in QIIME 2 View (q2view). 

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Taxonomy Barplots  
[Click to view the barchart.qzv file in QIIME 2 View](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2F0r73637tkg60wjbf5s07a%2Fbarchart.qzv%3Frlkey%3Djlx2ctcs9n5rszkun7bgaint1%26dl%3D1) 
::::::::::::::::::::::::::::::::::::::::::::::::::

:::callout
## How to Explore Barplots in QIIME 2 View
Once you’ve opened barchart.qzv in QIIME 2 View, try the following:

- *Change Taxonomic Levels*: Use the “Change Taxonomic Level” dropdown to explore patterns at Level 1 (Phylum), Level 3 (Class), and Level 5 (Family).
- *Sort Samples*: Use the “Sort Samples By” option to group by metadata fields like Sex or Animal.
- *Adjust Visuals*: Increase the “Bar Width” to make differences easier to see across samples.

These visualisations can help you spot differences in microbiome composition across individuals or groups.
:::

## Exploring Sequencing Depth (Rarefaction Curves)
Rarefaction curves help determine whether the samples have been sequenced deeply enough to capture all the community members. 

:::callout
**How to Explore Rarefaction Curves in QIIME2 View**:
- Do the curves plateau? If not, you may not have sequenced deeply enough.
- What sequencing depth corresponds to most curves levelling off?
- Choose a `--p-max-depth value` based on `16s_table_filtered.qzv`. A value near the median frequency works well.
:::

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Further Detail on `-p-max-depth`
The value that you provide for –p-max-depth should be determined by reviewing the “Frequency per sample” information presented in the `16s_table_filtered.qzv` file that was created above. In general, choosing a value that is somewhere around the median frequency seems to work well, but you may want to increase that value if the lines in the resulting rarefaction plot don’t appear to be levelling out, or decrease that value if you seem to be losing many of your samples due to low total frequencies closer to the minimum sampling depth than the maximum sampling depth.
::::::::::::::::::::::::::::::::::::::::::::::::::

```bash
qiime diversity alpha-rarefaction \
--i-table analysis/taxonomy/16s_table_filtered.qza \
--i-phylogeny analysis/tree/16s_rooted_tree.qza \
--p-max-depth 20000 \
--p-min-depth 500 \
--p-steps 40 \
--m-metadata-file echidna_metadata.tsv \
--o-visualization analysis/visualisations/16s_alpha_rarefaction.qzv \
--verbose
```
Copy `analysis/visualisations/16s_alpha_rarefaction.qzv` to your local computer and view in QIIME 2 View (q2view).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Rarefaction Visualisation
[Click to view the 16s_alpha_rarefaction.qzv file in QIIME 2 View](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Fa9tqrizdol82j4f2em7ll%2F16s_alpha_rarefaction.qzv%3Frlkey%3Dilcp14psote78zp7rbjrdlz26%26dl%3D1)

Select “Animal” in the “Sample Metadata Column” and “observed_features” under “Metric”
::::::::::::::::::::::::::::::::::::::::::::::::::

## Core Diversity Metrics (Alpha and Beta Diversity)
### What is Core Diversity Analysis?
QIIME 2’s `q2-diversity` plugin allows us to explore alpha (within-sample) and beta (between-sample) diversity using a range of metrics and visualisation tools. The following is adapted from the Moving Pictures Tutorial. 

The `core-metrics-phylogenetic` pipeline simplifies this by:

- Rarefying the feature table to a fixed sampling depth.
- Calculating several diversity metrics.
- Generating PCoA plots for beta diversity using Emperor.

**Alpha diversity metrics (within samples):**

- *Observed OTUs*: a qualitative measure of community richness
- *Shannon’s index*: a quantitative measure of community richness
- *Faith’s Phylogenetic Diversity*: a qualitative measure of community richness that considers phylogenetic relatedness
- *Evenness (Pielou’s)*: measure of community evenness 

**Beta diversity metrics (between samples):**

- *Jaccard distance*: Qualitative measure of community dissimilarity, based on absence/presence
- *Bray–Curtis distance*: Quantitative measure of community dissimilarity, based on abundance
- *Unweighted UniFrac*: Qualitative measure of community dissimilarity, includes phylogenetic relationships between features
- *Weighted UniFrac*: Quantitative measure of community dissimilarity, includes phylogenetic relationships between features

**Choosing your sampling depth**

Most diversity metrics are sensitive to sampling depth, so QIIME 2 standardizes counts by randomly subsampling the counts from each sample to the value provided for this parameter. This is passed using `--p-sampling-depth`.

For example, if `--p-sampling-depth 500` is provided, this step will subsample the counts in each sample without replacement, so that each sample in the resulting table has a total count of 500. If the total count for any sample(s) are smaller than this value, those samples will be excluded from the diversity analysis.

Choosing this value is tricky. To do so, keep in mind the following: 

- Review the “Frequency per sample” in `16s_table_filtered.qzv` created previously
- Pick a depth that retains most samples while still being high enough to capture diversity.
- It’s okay to omit extraction blanks or PCR negatives.

### Calculating Core Diversity Metrics
Once you've determined an appropriate depth, you can run the following command to generate a full suite of diversity metrics:
``` bash 
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny analysis/tree/16s_rooted_tree.qza \
  --i-table analysis/taxonomy/16s_table_filtered.qza \
  --p-sampling-depth 7316 \
  --m-metadata-file echidna_metadata.tsv \
  --output-dir analysis/diversity_metrics
  ```
Copy the `.qzv` files created from the above command into the `visualisations` subdirectory. 
``` bash
cp analysis/diversity_metrics/*.qzv analysis/visualisations
```
To view the differences between sample composition using unweighted UniFrac in ordination space, copy `analysis/visualisations/unweighted_unifrac_emperor.qzv` to your local computer and view in QIIME 2 View (q2view).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Unweighted UniFrac Emperor Ordination
[Click to view the unweighted_unifrac_emperor.qzv file in QIIME 2 View](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Fpsqxp4hfgvrzpeta687lk%2Funweighted_unifrac_emperor.qzv%3Frlkey%3Dujflsjcjx5qjl2z9vc61072pi%26dl%3D1)

On q2view, select the “Color” tab, choose “Animal” under the “Select a Color Category” dropdown menu, then select the “Shape” tab and choose “Sex” under the “Select a Shape Category” dropdown menu.
::::::::::::::::::::::::::::::::::::::::::::::::::

## Testing for Group Differences
Next, we'll test for association between categorical metadata columns and alpha diversity data. We'll do that here for observed ASVs and evenness metrics.

```bash
qiime diversity alpha-group-significance \
  --i-alpha-diversity analysis/diversity_metrics/observed_features_vector.qza \
  --m-metadata-file echidna_metadata.tsv \
  --o-visualization analysis/visualisations/observed_features-significance.qzv
```

Copy `analysis/visualisations/observed_features-significance.qzv` to your local computer and view in QIIME 2 View (q2view).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Observed Diversity Output
[Click to view the observed_features-significance.qzv file in QIIME 2 View.](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Ftn3r31tk3s04pv19cb0ig%2Fobserved_features-significance.qzv%3Frlkey%3D0qmb7fezh6am8drib39qn629h%26dl%3D1)

Select “Animal” under the “Column” dropdown menu.
::::::::::::::::::::::::::::::::::::::::::::::::::

```bash
qiime diversity alpha-group-significance \
  --i-alpha-diversity analysis/diversity_metrics/evenness_vector.qza \
  --m-metadata-file echidna_metadata.tsv \
  --o-visualization analysis/visualisations/evenness-group-significance.qzv
```

Copy `analysis/visualisations/evenness-group-significance.qzv` to your local computer and view in QIIME 2 View (q2view).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Evenness Output
[Click to view the evenness-group-significance.qzv file in QIIME 2 View.](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Foi8wbq9x4uztgkjv422gd%2Fevenness-group-significance.qzv%3Frlkey%3Dlvmydv7kkuotbtz2cilztyss7%26dl%3D1)

Select “Animal” under the “Column” dropdown menu.
::::::::::::::::::::::::::::::::::::::::::::::::::

Finally, we’ll analyse sample composition in the context of categorical metadata using a permutational multivariate analysis of variance (PERMANOVA, first described in Anderson (2001)) test using the `beta-group-significance` command. 

The following commands will test whether distances between samples within a group are more similar to each other then they are to samples from the other groups. If you call this command with the `--p-pairwise parameter`, as we’ll do here, it will also perform pairwise tests that will allow you to determine which specific pairs of groups differ from one another, if any. 

This command can be slow to run, especially when passing `--p-pairwise`, since it is based on permutation tests. So, unlike the previous commands, we’ll run beta-group-significance on specific columns of metadata that we’re interested in exploring, rather than all metadata columns to which it is applicable. 

Here we’ll apply this to our unweighted UniFrac distances, using two sample metadata columns (Gender and Animal), as follows.

```bash
qiime diversity beta-group-significance \
  --i-distance-matrix analysis/diversity_metrics/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file echidna_metadata.tsv \
  --m-metadata-column Sex \
  --o-visualization analysis/visualisations/unweighted-unifrac-gender-significance.qzv \
  --p-pairwise
  ```
Copy `analysis/visualisations/unweighted-unifrac-gender-significance.qzv` to your local computer and view in QIIME 2 View (q2view).  

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Gender Significance Output
[Click to view the unweighted-unifrac-gender-significance.qzv file in QIIME 2 View.](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Fo8jzhit0mgs2w13i5mzno%2Funweighted-unifrac-gender-significance.qzv%3Frlkey%3Di4pddpyo9cosz7tg2dk8nr2zr%26dl%3D1)
::::::::::::::::::::::::::::::::::::::::::::::::::

```bash
qiime diversity beta-group-significance \
  --i-distance-matrix analysis/diversity_metrics/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file echidna_metadata.tsv \
  --m-metadata-column Animal \
  --o-visualization analysis/visualisations/unweighted-unifrac-animal-significance.qzv \
  --p-pairwise
```
Copy `analysis/visualisations/unweighted-unifrac-animal-significance.qzv` to your local computer and view in QIIME 2 View (q2view).

::::::::::::::::::::::::::::::::::::::::::::: spoiler
### Check Your Work: Animal Significance Output
[Click to view the unweighted-unifrac-animal-significance.qzv file in QIIME 2 View.](https://view.qiime2.org/visualization/?type=html&src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Fir3xgvn0vdwajx5hw663o%2Funweighted-unifrac-animal-significance.qzv%3Frlkey%3Dcekbzric4xww39b7hlf4x4772%26dl%3D1)
::::::::::::::::::::::::::::::::::::::::::::::::::

## Provenance and Reproducibility

QIIME 2 stores **provenance metadata** in every `.qzv` file it generates. This allows you to track exactly what commands, parameters, and inputs were used to create a result—making your analysis transparent and reproducible.

To explore this, open any `.qzv` file (e.g., unweighted-unifrac-animal-significance.qzv) in QIIME 2 View and select the Provenance tab.

Take note of:

- Which commands were run
- The inputs used
- Any parameters set
- Intermediate files created along the way

This is particularly useful when troubleshooting or writing up your methods.

:::callout
##Note
Click to view the [unweighted-unifrac-animal-significance.qzv provenance file in QIIME 2 View.](https://view.qiime2.org/provenance/?src=https%3A%2F%2Fdl.dropboxusercontent.com%2Fscl%2Ffi%2Fir3xgvn0vdwajx5hw663o%2Funweighted-unifrac-animal-significance.qzv%3Frlkey%3Dcekbzric4xww39b7hlf4x4772%26dl%3D1)
:::

::::::::::::::::::::::::::::::::::::: keypoints

- QIIME2 visualisations allow exploration of microbial composition, diversity, and statistical differences across groups.
- Taxonomic barplots, rarefaction curves, and diversity metrics provide insights into microbial community structure and sampling depth.
- Alpha diversity measures within-sample richness and evenness, while beta diversity measures between-sample dissimilarity.
- Group significance tests help assess whether diversity varies across categories like sex or animal ID.
- Core metrics pipelines simplify the process of generating multiple diversity outputs from a single command.

::::::::::::::::::::::::::::::::::::


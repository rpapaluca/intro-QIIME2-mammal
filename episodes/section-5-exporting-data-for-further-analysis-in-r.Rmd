---
title: 'Section 5 - Exporting data for further analysis in R'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- What file types are required to import QIIME2 outputs into R packages like phyloseq?
- Why do we need to remove header lines from .tsv files before importing into R?
- How can you ensure that taxonomy and ASV tables are in compatible formats and matching order for downstream analysis?
- What are the steps for exporting QIIME2 artefacts into plain text or .tsv formats usable in R?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Describe the purpose of exporting QIIME2 artefacts (ASV table, taxonomy, and tree) for use in external tools like R and phyloseq.
- Convert QIIME2 artefacts into common formats such as .nwk, .biom, and .tsv, and prepare these files for compatibility with downstream R-based analysis.
- Clean and modify exported .tsv files (e.g., remove headers) to ensure proper formatting for import into R packages.
- Recognize the importance of consistent feature ordering across ASV and taxonomy files, and apply basic file-cleaning practices to avoid import errors or misaligned data in R. 

::::::::::::::::::::::::::::::::::::::::::::::::

## Exporting QIIME 2 Data for Use in R
If you plan to conduct further statistical analyses or create custom plots in R, you'll need to export your processed QIIME 2 artefacts into standard file formats.

This section walks you through how to export the **ASV table**, **taxonomy assignments**, and **unrooted tree**, and prepare them for use in R packages such as `phyloseq`.

### Exporting the Unrooted Tree
Export the tree in Newick format (`.nwk`), which is required for downstream use in `phyloseq`

```bash
qiime tools export \
  --input-path analysis/tree/16s_unrooted_tree.qza \
  --output-path analysis/export
```

### Exporting the Feature Table
To begin, export your ASV abundance table (as a `.biom` file).  

```bash
qiime tools export \
  --input-path analysis/taxonomy/16s_table_filtered.qza \
  --output-path analysis/export
```

Following this, we will then convert it to a tab-separated format (.tsv).

```bash
biom convert \
-i analysis/export/feature-table.biom \
-o analysis/export/feature-table.tsv \
--to-tsv
```

### Exporting the Taxonomy Table
Now export your taxonomy classifcations as `.tsv` file.

```bash
qiime tools export \
--input-path analysis/taxonomy/classification.qza \
--output-path analysis/export
```

Some programs (like `phyloseq`) require clean .tsv files without QIIME2-specific headers. Use `sed` to remove them from the `.tsv` files you have generated:
```bash
sed '1d' analysis/export/taxonomy.tsv > analysis/export/taxonomy_noHeader.tsv
sed '1d' analysis/export/feature-table.tsv > analysis/export/feature-table_noHeader.tsv
```

:::callout
**Tip:** Many R-based pipelines expect the order of ASVs to match across tables. It’s good practice to check and clean your taxonomy and ASV tables so they align properly. That is, that the order of your ASVs in the taxonomy table rows to be the same order of ASVs in the columns of your ASV table. 
:::

::::::::::::::::::::::::::::::::::::: keypoints 

- QIIME 2 data (ASV table, taxonomy, and tree) can be exported into standard formats for downstream analysis in R.
- Clean and format `.tsv` and `.nwk` files to ensure compatibility with tools like phyloseq.
- Consistent ASV ordering across files is essential for successful import and downstream analysis.

::::::::::::::::::::::::::::::::::::::::::::::::


---
title: 'Build a phylogenetic tree'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- Why is building a phylogenetic tree important for microbiome analysis?
- What are the main steps involved in generating a phylogenetic tree using QIIME2?
- What does the `qiime phylogeny align-to-tree-mafft-fasttree` command do, and what are its key outputs?
- How can you organise and label the tree output files for easy access in downstream analyses like diversity metrics?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain the purpose of building a phylogenetic tree in microbiome analysis, particularly its role in downstream diversity metrics like UniFrac.
- Describe the key steps involved in generating a phylogenetic tree in QIIME2, including sequence alignment, masking and rooting.
- Construct a rooted phylogenetic tree from representative sequences, by running the `qiime phylogeny align-to-tree-mafft-fasttree` pipeline
- Organise the output files from the phylogenetic tree-building process into a structured directory for use in later analyses. 

::::::::::::::::::::::::::::::::::::::::::::::::

## Why build a phylogenetic tree?

The next step is to construct a phylogenetic tree from the representative ASV sequences. This process involves:

1. **Aligning the representative sequences** using a multiple sequence alignment method.  
2. **Masking uninformative sites** in the alignment (e.g., positions that are too variable or gapped to be meaningful for phylogenetic inference).  
3. **Generating a phylogenetic tree** based on the aligned sequences.  
4. **Applying mid-point rooting** to ensure the tree is properly rooted for downstream analyses.

A phylogenetic tree is essential for analyses that rely on the **evolutionary relationships between community members**, such as **beta-diversity metrics** like **weighted or unweighted UniFrac**, and for visualisations that incorporate these distance measures.

## Create the Tree Directory

Before running the command, create a new directory to store the phylogenetic tree outputs:

``` bash
mkdir analysis/tree
```
## Build the Phylogenetic Tree

We will use the `qiime phylogeny align-to-tree-mafft-fasttree` pipeline, which performs all of the steps above (alignment, masking, tree building, and rooting) in a single command.

:::callout
**Note:** We will use a single thread `(--p-n-threads 1)`, which is the default. This helps ensure that results are reproducible if the command is rerun. 
:::

``` bash
qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences analysis/dada2out/representative_sequences.qza \
--o-alignment analysis/tree/aligned_16s_representative_seqs.qza \
--o-masked-alignment analysis/tree/masked_aligned_16s_representative_seqs.qza \
--o-tree analysis/tree/16s_unrooted_tree.qza \
--o-rooted-tree analysis/tree/16s_rooted_tree.qza \
--p-n-threads 1 \
--verbose
```

::::::::::::::::::::::::::::::::::::: keypoints 

- Phylogenetic trees allow downstream analyses to incorporate evolutionary relationships between organisms in downstream analysis. 
- QIIME2’s `align-to-tree-mafft-fasttree` pipeline builds a rooted phylogenetic tree in a single step from representative sequences.

::::::::::::::::::::::::::::::::::::::::::::::::


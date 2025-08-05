---
title: 'Background'
teaching: 10
exercises: 0
---

:::::::::::::::::::::::::::::::::::::: questions 

- Why might the gut microbiota of male and female echidnas differ, and why is this biologically interesting?
- What are the main features and benefits of using QIIME 2 for microbiome analysis?  

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Describe the biological motivation for studying sex- and individual-based differences in the gut microbiota of the short-beaked echidna.
- Recognize the core capabilities of the QIIME 2 platform and explain how it supports microbiome research

::::::::::::::::::::::::::::::::::::::::::::::::

## The Players

Short-beaked echidna [*Tachyglossus aculeatus*](https://en.wikipedia.org/wiki/Short-beaked_echidna) - a monotreme that has evolved to lay and incubate an egg. We are looking at the gut bacterial communities, or microbiome, of the echidna. There are 38 samples in this dataset (This data is a subset from a larger experiment):

- 5 samples from each individual (3x male and 3x female).
- 8 control samples (DNA extraction blanks (n=5) and PCR blanks (n=3)).


## The Study
Indigenous microbial communities (microbiota) play critical roles in host health. Monotremes, such as the short-beaked echidna, have evolved to lay and incubate an egg. Since both faeces and eggs pass through the cloaca, the faecal microbiota of female echidnas provides an opportunity for vertical transmission of microbes to their offspring as well as maintaining foetus health. Here, we characterise the gut microbiome of female and male short-beaked echidnas from six individuals living in captivity in the Currumbin Wildlife Sanctuary in Queensland. This data is a subset from a larger experiment.

Buthgamuwa I, Fenelon JC, Roser A, Meer H, Johnston SD, Dungan AM (2023) Unraveling the fecal microbiota stability in the short-beaked echidna (*Tachyglossus aculeatus*) across gestation. In review at *MicrobiologyOpen*. Full text on [Research Square](https://www.researchsquare.com/article/rs-3243769/v1). 

## Intro to QIIME 2 Analysis Platform
Quantitative Insights Into Microbial Ecology 2 [QIIME 2™](https://www.nature.com/articles/s41587-019-0209-9) is a next-generation microbiome [bioinformatics platform](https://qiime2.org/) that is extensible, free, open source, and community developed. It allows researchers to:

- Automatically track analyses with decentralised data provenance
- Interactively explore data with beautiful visualisations
- Easily share results without QIIME 2 installed
- Plugin-based system — researchers can add in tools as they wish

## Viewing QIIME2 Visualisations

In order to use QIIME2 View to visualise your files, you will need to use a Google Chrome or Mozilla Firefox web browser (not in private browsing). More information [can be found here](https://view.qiime2.org/).

As this workshop is being run on a remote Nectar Instance, you will need to [download the visual files](https://www.melbournebioinformatics.org.au/tutorials/tutorials/workshop_delivery_mode_info/workshops_nectar/#transferring-files-between-your-computer-and-nectar-instance) (*.qzv) to your local computer and view them in [QIIME2 View](https://view.qiime2.org/).

::: callout
### Note for Self-Installation and Independent Analysis
Alternatively, if you have QIIME2 installed and are running it on your own computer, you can use qiime tools view to view the results from the command line (e.g. qiime tools view filename.qzv). qiime tools view opens a browser window with your visualization loaded in it. When you are done, you can close the browser window and press ctrl-c on the keyboard to terminate the command.
:::



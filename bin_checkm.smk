import os
import glob
eukbam=glob.glob("*_euk.bam")
prokbam=glob.glob("*_prok.bam")
euks=[os.path.basename(f).replace(".bam","") for f in eukbam]
proks=[os.path.basename(f).replace(".bam","") for f in prokbam]
samps = [os.path.basename(f).replace("_euk.bam", "") for f in eukbam]
megadir=[os.path.basename(f).replace("euk.bam","megahit") for f in eukbam]
rule all:
  input:
    expand("{samp}_euk_check/{samp}_summ.tsv",samp=samps),
    expand("{samp}_prok_check/{samp}_summ.tsv",samp=samps),
    expand("{samp}_euk_check/",samp=samps),
    expand("{samp}_prok_check/",samp=samps)
rule metabat:
  input:
    eukbam="{samp}_euk.bam",
    prokbam="{samp}_prok.bam",
    eukfa="{samp}_megahit/eukarya_final.contigs.fa",
    prokfa="{samp}_megahit/prokarya_final.contigs.fa"
  params:
    eukdep="{samp}_euk.depth.txt",
    prokdep="{samp}_prok.depth.txt"
  output:
    eukbin=directory("{samp}_euk_bin"),
    prokbin=directory("{samp}_prok_bin"),
    euklog="logs/{samp}_euk_metabat.log",
    proklog="logs/{samp}_prok_metabat.log"
  shell:
    '''
    jgi_summarize_bam_contig_depths --outputDepth {params.eukdep} --minContigLength 1000 --minContigDepth 1 {input.eukbam} --percentIdentity 50 
    jgi_summarize_bam_contig_depths --outputDepth {params.prokdep} --minContigLength 1000 --minContigDepth 1 {input.prokbam} --percentIdentity 50
    metabat2 -i {input.eukfa} --abdFile {params.eukdep} --outFile {output.eukbin} --numThreads 8 --minContig 1000 &> {output.euklog}
    metabat2 -i {input.prokfa} --abdFile {params.prokdep} --outFile {output.prokbin} --numThreads 8 --minContig 1000 &> {output.proklog}
    '''
rule checkm:
  input:
    eukbins="{samp}_euk_bin/",
    prokbins="{samp}_prok_bin/"
  output:
    eukcheckm=directory("{samp}_euk_check/"),
    prokcheckm=directory("{samp}_prok_check/"),
    euksummary="{samp}_euk_check/{samp}_summ.tsv",
    proksummary="{samp}_prok_check/{samp}_summ.tsv"
  params:
    euktmp=directory("{samp}_euk_tmp"),
    proktmp=directory("{samp}_prok_tmp")
  shell:
    '''
    checkm lineage_wf -t 6 --tab_table -f {output.euksummary} --tmpdir {params.euktmp} {input.eukbins} {output.eukcheckm}
    checkm lineage_wf -t 6 --tab_table -f {output.proksummary} --tmpdir {params.proktmp} {input.prokbins} {output.prokcheckm}
    '''

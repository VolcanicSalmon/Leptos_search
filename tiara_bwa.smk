import os
import glob
acc=glob.glob("*_megahit")
samples = [os.path.basename(f).replace("_megahit", "") for f in acc]
rule all:
  input:
    expand("{sample}_euk.bam",sample=samples),
    expand("{sample}_prok.bam",sample=samples)
rule tiara:
  input:
    assembly="{sample}_megahit/final.contigs.fa",
  output:
    table="{sample}_megahit/{sample}_tiara.csv",
    archaea="{sample}_megahit/archaea_final.contigs.fa",
    bacteria="{sample}_megahit/bacteria_final.contigs.fa",
    eukarya="{sample}_megahit/eukarya_final.contigs.fa",
    prokarya="{sample}_megahit/prokarya_final.contigs.fa",
    mito="{sample}_megahit/mitochondrion_final.contigs.fa",
    plastid="{sample}_megahit/plastid_final.contigs.fa",
    unknown="{sample}_megahit/unknown_final.contigs.fa"
  shell:
    "tiara -i {input.assembly} -o {output.table} --tf all -t 8 -m 800"
rule bwa:
  input:
    eukassembly="{sample}_megahit/eukarya_final.contigs.fa",
    prokassembly="{sample}_megahit/prokarya_final.contigs.fa",
    fw="{sample}_1.dedu.fastq.gz",
    rv="{sample}_2.dedu.fastq.gz"
  output:
    eukbam="{sample}_euk.bam",
    prokbam="{sample}_prok.bam"
  shell:
    """
    bwa index {input.eukassembly}
    bwa index {input.prokassembly}
    bwa mem -t 6 {input.eukassembly} {input.fw} {input.rv} | samtools view -hb -@ 6 - | samtools sort -@ 6 - > {output.eukbam}
    bwa mem -t 6 {input.prokassembly} {input.fw} {input.rv} | samtools view -hb -@ 6 - | samtools sort -@ 6 - > {output.prokbam}
    """


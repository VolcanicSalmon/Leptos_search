pesamples = {
    "G1214": ["7DPI", "V"],
    "NZT4": ["14DPI", "V"]
}

sesamples = ["IPT5"]

# Flatten valid PE (sample, condition) pairs
pe_sample_pairs = [(s, c) for s in pesamples for c in pesamples[s]]

# Rule: All expected outputs
rule all:
  input:
    expand("{pesamp}_{cond}.bam", zip,
           pesamp=[s for s, c in pe_sample_pairs],
           cond=[c for s, c in pe_sample_pairs]) +
    expand("{sesamp}.bam", sesamp=sesamples)

# Rule: Paired-end alignment
rule bwa_pe:
  input:
    fw = "{pesamp}_{cond}_1.fastq.gz",
    rv = "{pesamp}_{cond}_2.fastq.gz",
    ref = "{pesamp}.fasta"
  output:
    pebam = "{pesamp}_{cond}.bam"
  params:
    amb = "{pesamp}.fasta.amb",
    ann = "{pesamp}.fasta.ann",
    bwt = "{pesamp}.fasta.bwt",
    pac = "{pesamp}.fasta.pac",
    sa  = "{pesamp}.fasta.sa"
  shell:
    '''
    module load bwa 
    module load samtools
    bwa index {input.ref}
    bwa mem -t 8 -M {input.ref} {input.fw} {input.rv} | samtools view -Sb - > {output.pebam}
    '''

# Rule: Single-end alignment
rule bwa_se:
  input:
    fw = "{sesamp}.fastq.gz",
    ref = "{sesamp}.fasta"
  output:
    sebam = "{sesamp}.bam"
  params:
    amb = "{sesamp}.fasta.amb",
    ann = "{sesamp}.fasta.ann",
    bwt = "{sesamp}.fasta.bwt",
    pac = "{sesamp}.fasta.pac",
    sa  = "{sesamp}.fasta.sa"
  shell:
    '''
    module load bwa 
    module load samtools
    bwa index {input.ref}
    bwa mem -t 8 -M {input.ref} {input.fw} | samtools view -Sb - > {output.sebam}
    '''

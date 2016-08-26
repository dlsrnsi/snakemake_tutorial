BASE_DIR = "/home/share/dlsrnsi/snakemake_exercise/"
WDIR = BASE_DIR + "tutorial/"
GFF_NAME = "ensGene.gff3"
GFF = BASE_DIR + "ref_hg19/"+GFF_NAME
BowtieIndex = BASE_DIR + "ref_hg19/Bowtie2Index/genome"
LibraryType = "fr-firststrand"

workdir: WDIR

SAMPLES, = glob_wildcards(WDIR+"samples/raw/{sample}_1.fastq.gz")


rule all:
     input: "samples/comparison_result.csv"

rule tophat:
     input: fwd="samples/raw/{sample}_1.fastq.gz", rev="samples/raw/{sample}_2.fastq.gz"
     params: GFF=GFF, BowtieIndex=BowtieIndex, LibraryType=LibraryType
     output: "samples/bam/{sample}.bam"
     shell:""" 
	mkdir -p samples/tophat/{wildcards.sample} 
	tophat -p 10 -o samples/tophat/{wildcards.sample} -G {params.GFF} --library-type {params.LibraryType} {params.BowtieIndex} {input.fwd} {input.rev}  
   	mv samples/tophat/{wildcards.sample}/accepted_hits.bam samples/bam/{wildcards.sample}.bam
	"""

rule cufflinks:
     input: "samples/bam/{sample}.bam"
     params: GFF=GFF
     output: "samples/cufflinks/{sample}/isoforms.fpkm_tracking"
     shell: "cufflinks -p 10 -G {params.GFF} --output-dir samples/cufflinks/{wildcards.sample} {input}"

rule comparison:
     input: expand("samples/cufflinks/{sample}/isoforms.fpkm_tracking", sample=SAMPLES)
     output: "samples/comparison_result.csv"
     run:
       inputs = " ".join(input)
       shell("python comprison.py "+inputs+" {output}")

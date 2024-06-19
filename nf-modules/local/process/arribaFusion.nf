/*
 * Arriba/STAR 
 */

process arribaFusion {
  tag "${meta.sampleName}"
  label 'arriba'
  label 'highCpu'
  label 'extraMem'

  input:
  tuple val(meta), path(sampleRnaBam), path(sampleRnaBamIndex)
  path star_index
  path annotation_gtf 
  path fasta // fasta sib 
  path fastaFai // fasta fai sib
  val layout // PE
  path blacklist_tsv 
  path protein_gff 
  path tmpdir

  output:
  tuple val(meta), path("*_star_arriba.fusions.tsv"), emit: arribaFus

  script:
  """
	samtools collate -@ ${task.cpus} -T ${tmpdir} -u -f -r 1000000 -O ${sampleRnaBam} |  samtools view  - | cut -f 1-11 > ${meta.sampleName}_collate.sam

	awk -F '\t' -v ASSEMBLY_FA=${fasta} -v LAYOUT=${layout} -v STAR_PIPE="${meta.sampleName}_star_realigned.sam" '
	    BEGIN{
	        # get list of contig names from assembly & generate sam header
	        while (getline line < ASSEMBLY_FA)
	            if (line~/^>/) { gsub(/^>|[ \t].*/, "", line); contig=line } else { contigs[contig]+=length(\$0) }
	    }

	    function flag(f) { return (\$2 % (2*f) >= f) }

	    # find reads that need to be realigned
	    function realign() {
	        return (flag(4) || # unmapped
	                !flag(16) && \$6~/^[0-9][0-9]+S/ || # forward strand and preclipped
	                flag(16) && \$6~/[0-9][0-9]S\$/ || # reverse strand and postclipped
	                LAYOUT=="SE" && \$6~/[0-9][0-9]S/ || # single-end and clipped anywhere
	                LAYOUT=="PE" && !flag(2) || # discordant mates
	                !(\$3 in contigs)) # contig not part of assembly
	    }

	    # extract paired-end reads for realignment
	    LAYOUT=="PE" {
	        if (\$1==name1) { # we have encountered both mates
	            if (realign1 || realign()) { print mate1 "\\n" \$0 > STAR_PIPE }
	        } else { # cache mate1
	            mate1=\$0; name1=\$1; realign1=realign()}
	    }
	' ${meta.sampleName}_collate.sam


	STAR \
	    --runThreadN ${task.cpus} \
	    --genomeDir ${star_index} --genomeLoad NoSharedMemory \
	    --readFilesIn ${meta.sampleName}_star_realigned.sam --readFilesType SAM ${layout} \
	    --outStd BAM_Unsorted --outSAMtype BAM Unsorted --outBAMcompression 0 \
	    --outFilterMultimapNmax 50 --peOverlapNbasesMin 10 --alignSplicedMateMapLminOverLmate 0.5 --alignSJstitchMismatchNmax 5 -1 5 5 \
	    --chimSegmentMin 10 --chimOutType WithinBAM HardClip --chimJunctionOverhangMin 10 --chimScoreDropMax 30 --chimScoreJunctionNonGTAG 0 --chimScoreSeparation 1 --chimSegmentReadGapMax 3 --chimMultimapNmax 50 > ${meta.sampleName}_star_arriba.bam

	arriba  -x ${meta.sampleName}_star_arriba.bam \
	        -o ${meta.sampleName}_star_arriba.fusions.tsv \
	        -O ${meta.sampleName}_star_arriba.fusions.discarded.tsv \
	        -a ${fasta} -g ${annotation_gtf} -b ${blacklist_tsv} -p ${protein_gff} 


  """
}






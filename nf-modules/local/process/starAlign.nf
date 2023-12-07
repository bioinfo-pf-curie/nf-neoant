/*
 * STAR reads alignment
 */

process starAlign {
  tag "${meta.sampleName}"
  label 'star'
  label 'highCpu'
  label 'extraMem'

  input:
  tuple val(meta), path(fastqRnaR1), path(fastqRnaR2)
  path star_index
  path annotation_gff

  output:
  tuple val(meta), path("*Aligned.toTranscriptome.out.bam"), emit: transcriptsBam

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  echo "STAR "\$(STAR --version 2>&1) > versions.txt

  STAR --genomeDir ${star_index} \
     --sjdbGTFfile ${annotation_gff} \
     --readFilesIn ${fastqRnaR1} ${fastqRnaR2}  \
     --runThreadN ${task.cpus} \
     --runMode alignReads  --outSAMtype BAM Unsorted  --readFilesCommand zcat --runDirPerm All_RWX \
     --outFileNamePrefix ${meta.sampleName} \
     --outSAMattrRGline ID:${meta.sampleName} SM:${meta.sampleName} LB:Illumina PL:Illumina  \
     --outSAMunmapped Within \
     --quantMode TranscriptomeSAM --outFilterType BySJout --outSAMmultNmax 1 --outFilterMultimapNmax 20 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 --outFilterMismatchNoverLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --outSAMprimaryFlag OneBestScore --outMultimapperOrder Random --outSAMattributes All \
     --outSAMtlen 2
  """
}

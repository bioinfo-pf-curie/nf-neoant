/*
 * Salmon quantification from BAM file
 */

process salmonQuantFromBam {
  tag "${meta.sampleName}"
  label "salmon"
  label "medCpu"
  label "medMem"

  input:
  tuple val(meta), path(sampleRnaTranscriptBam) // Channel [meta], sampleRnaTranscriptBam
  path(transcriptsFasta)
  path(gff)

  output:
  tuple val(meta), path("*rna_counts_tpm.txt"), path("*.rna_counts_transcript_tpm.txt"), emit: tpm

  script:
  def args = task.ext.args ?: ''
   
  """

  salmon quant \\
    --alignments ${sampleRnaTranscriptBam} \\
    --threads ${task.cpus} \\
    --targets ${transcriptsFasta} \\
    --geneMap ${gff} \\
    --libType=A \\
    --gencode \\
    --output . \\
    --quiet

  echo -e "transcript\t${meta.sampleName}" > ${meta.sampleName}.rna_counts_transcript_tpm.txt
  awk '{OFS="\t"}NR>1{print \$1,\$4}' quant.sf  >>  ${meta.sampleName}.rna_counts_transcript_tpm.txt

  echo -e "gene\t${meta.sampleName}" > ${meta.sampleName}.rna_counts_tpm.txt
  awk '{OFS="\t"}NR>1{print \$1,int(\$4 + 0.5)}'  quant.genes.sf  >>  ${meta.sampleName}.rna_counts_tpm.txt
  
  """
}



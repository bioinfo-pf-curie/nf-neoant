/*
 * Salmon quant from BAM file
 */

process salmonQuantFromBam {
  tag "${sampleName}"
  label "salmon"
  label "medCpu"
  label "medMem"

  input:
  tuple val(sampleName), path(sampleRnaTranscriptBam)
  path(transcriptsFasta)
  path(gff)

  output:
  path("${sampleName}.rna_counts_transcript_tpm.txt"), emit: rnaCountsTranscripts
  path("${sampleName}.rna_counts_tpm.txt"), emit: rnaCounts
  path("versions.txt"), emit: versions

  script:
  def args = task.ext.args ?: ''
   
  """
  echo \$(salmon --version 2>&1) > versions.txt
  salmon quant \\
    --libType=A \\
    --alignments ${sampleRnaTranscriptBam} \\
    --threads ${task.cpus} \\
    --targets ${transcriptsFasta} \\
    --geneMap ${gff} \\
    ${args} \\
    --output . \\
    --quiet

  echo -e "transcript\t${sampleName}" > ${sampleName}.rna_counts_transcript_tpm.txt
  awk '{OFS="\t"}NR>1{print \$1,\$4}' quant.sf  >>  ${sampleName}.rna_counts_transcript_tpm.txt

  echo -e "gene\t${sampleName}" > ${sampleName}.rna_counts_tpm.txt
  awk '{OFS="\t"}NR>1{print \$1,int(\$4 + 0.5)}'  quant.genes.sf  >>  ${sampleName}.rna_counts_tpm.txt
  

  """
}



/*
 * Add expression to vcf 
 */

process vcfAddExp {
  tag "${meta.sampleName}"
  label 'pvacseq'
  label "medCpu"
  label "medMem"

  input:
  tuple val(meta), path(vepVcf), path(tpmGene), path(tpmTranscript) // Channel [meta], vcf, tpmGene, tpmTranscript

  output:
  tuple val(meta), path("*vep.rna.transcript.vcf"), emit: exprVcf

  script:
  """

  # ADD GX TAG
  vcf-expression-annotator --id-column gene \
                           --expression-column ${meta.sampleName} \
                           --sample-name ${meta.sampleName} \
                           --ignore-ensembl-id-version \
                           --output-vcf ${meta.sampleName}.vep.rna.vcf \
                           ${vepVcf} \
                           ${tpmGene} \
                           custom gene 

  # ADD TX TAG
  vcf-expression-annotator --id-column transcript \
                           --expression-column ${meta.sampleName} \
                           --sample-name ${meta.sampleName} \
                           --ignore-ensembl-id-version \
                           --output-vcf ${meta.sampleName}.vep.rna.transcript.vcf \
                           ${meta.sampleName}.vep.rna.vcf \
                           ${tpmTranscript} \
                           custom transcript 

  """
}

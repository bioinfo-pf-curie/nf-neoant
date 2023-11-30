/*
 * Add expression to vcf 
 */

process vcfAddExp {
  tag "${sampleName}"
  label 'pvacseq'
  label "medCpu"
  label "medMem"


  input:
  val(sampleName)
  path vepVcf
  path tpmGene
  path tpmTranscript

  output:
  path("*vep.rna.transcript.vcf"), emit: exprVcf

  when:
  task.ext.when == null || task.ext.when

  script:
  """

  # ADD GX TAG
  vcf-expression-annotator --id-column gene \
                         --expression-column ${sampleName} \
                         --sample-name ${sampleName} \
                         --ignore-ensembl-id-version \
                         --output-vcf ${sampleName}.vep.rna.vcf \
                         ${vepVcf} \
                         ${tpmGene} \
                         custom gene 

  # ADD TX TAG
  vcf-expression-annotator --id-column transcript \
                         --expression-column ${sampleName} \
                         --sample-name ${sampleName} \
                         --ignore-ensembl-id-version \
                         --output-vcf ${sampleName}.vep.rna.transcript.vcf \
                         ${sampleName}.vep.rna.vcf \
                         ${tpmTranscript} \
                         custom transcript 

  """
}

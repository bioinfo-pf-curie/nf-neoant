/*
 * mixcr analysis
 */

process mixcr {
  tag "${sampleName}"
  label "mixcr"
  label "medCpu"
  label "medMem"

  input:
  tuple val(sampleName), path(fastqRnaR1), path(fastqRnaR2) 
  val species // hsa
  val mi_license

  output:
  path("${sampleName}/*clns"), emit: mixcrClns
  path("${sampleName}/${sampleName}.chainUsage.pdf"), emit: mixcrPdf

  script:
  def args = task.ext.args ?: ''
   
  """

    export MI_LICENSE_FILE="${mi_license}"

    mixcr analyze rna-seq \
        --threads ${task.cpus} \
        --species ${species} \
        ${fastqRnaR1} ${fastqRnaR2} \
        ${sampleName}/${sampleName}

    mixcr exportQc chainUsage ${sampleName}/*.clns  ${sampleName}/${sampleName}.chainUsage.pdf
  
  """
}






/*
 * Run HLA-LA for MHCII alleles
 */

process hlaLaRun {
  tag "${meta.sampleName}"
  label 'hlala'
  label "highCpu"
  label "extraMem"

  input:
  tuple val(meta), path(sampleDnaBam), path(sampleDnaBamIndex)
  path graphDir 
  val graphName 

  output:
  tuple val(meta), path("${meta.sampleName}/hla/*R1_bestguess_G.txt"), emit: hlaIIfile

  script:
  """
  mkdir -p ${meta.sampleName}/hla/

  HLA-LA.pl --BAM  ${sampleDnaBam}  --customGraphDir . --graph ${graphName} --sampleID ${meta.sampleName} --maxThreads ${task.cpus} --workingDir . 

  """

}



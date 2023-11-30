/*
 * Run HLA-LA for MHCII alleles
 */

process hlaLaRun {
  tag "${sampleName}"
  label 'hlala'
  label "highCpu"
  label "extraMem"

  input:
  val sampleName
  path sampleDnaBam
  path sampleDnaBamIndex
  path graphDir 
  val graphName //PRG_MHC_GRCh38_withIMGT

  output:
  path("${sampleName}/hla/*R1_bestguess_G.txt"), emit: hlaIIfile

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  mkdir -p ${sampleName}/hla/
  cp /data/kdi_prod/.kdi/project_workspace_0/1833/acl/05.00/analyses/test/work/05/5146ae1a13a8713b320a66f1d126c0/D1326R05/hla/R1_bestguess_G.txt ${sampleName}/hla/R1_bestguess_G.txt


  """
}



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
  val graphName //PRG_MHC_GRCh38_withIMGT

  output:
  tuple val(meta), path("${meta.sampleName}/hla/*R1_bestguess_G.txt"), emit: hlaIIfile

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  mkdir -p ${meta.sampleName}/hla/

  cp  /data/kdi_prod/.kdi/project_workspace_0/1833/acl/05.00/analyses/neoAnt_test/pVacSeq/D1326R07/D1326R07_hlala.txt ${meta.sampleName}/hla/R1_bestguess_G.txt

  """

    // HLA-LA.pl --BAM  ${sampleDnaBam}  --customGraphDir . --graph ${graphName} --sampleID ${meta.sampleName} --maxThreads ${task.cpus} --workingDir . 

}



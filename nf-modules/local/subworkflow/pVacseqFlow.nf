/* 
 * pVacseq workflow
 */

// include { hlaIConvert } from '../process/hlaIConvert'
// include { hlaLaRun } from '../process/hlaLaRun'
// include { hlaIIConvert } from '../process/hlaIIConvert'
include { pvacseqRun } from '../process/pvacseqRun'
// include { seq2HLA } from '../process/seq2HLA'

workflow pVacseqFlow {

  take:
  // sp // Channel samplePlan
  // graphDir
  // graphName
  seq2HLAtypes //// sampleName, hlaIfile, hlaIIfile
  annotVcf // Channel sampleName, annotVcf
  algos
  minVafDna
  minVafRna
  minVafNormal
  minCovDna
  minCovRna  
  iedbPath 

  main:

  // sp.map{ it ->
  //       def meta = [sampleName:it[0].sampleName ]
  //       return [meta, it[10]]
  //     }.set{ chHlaIt }

  // hlaIConvert(
  //   chHlaIt // sampleName, hlaIfile
  //   )

  // sp.map{ it ->
  //       def meta = [sampleName:it[0].sampleName ]
  //       return [meta, it[3],it[4]]
  //     }.set{ chHlaLat }

  // hlaLaRun(
  //   chHlaLat, // sampleName, sampleDnaBam, sampleDnaBamIndex
  //   graphDir,
  //   graphName
  //   )

  // hlaIIConvert(
  //   hlaLaRun.out.hlaIIfile // sampleName, hlaIIfile
  //   )

  // chHlat =  hlaIConvert.out.hlaI.join(hlaIIConvert.out.hlaII) // sampleName, hlaIfile, hlaIIfile

  // chVcfHlat =  annotVcf.join(chHlat) // sampleName, hlaIfile, hlaIIfile


  // sp.map{ it ->
  //       def meta = [sampleName:it[0].sampleName ]
  //       return [meta, it[6],it[7]] // sampleName, RNA Fastq1, RNA Fastq2
  //     }.set{ chRNAFastqt } 


  // seq2HLA(
  //   chRNAFastqt // sampleName, RNA Fastq1, RNA Fastq2
  //   )

  chVcfHlat =  annotVcf.join(seq2HLAtypes) // sampleName, annotVcf, hlaIfile, hlaIIfile

  pvacseqRun(
    chVcfHlat, // Channel sampleName, annotVcf , hlaIfile, hlaIIfile
    algos,
    minVafDna,
    minVafRna,
    minVafNormal,
    minCovDna,
    minCovRna,    
    iedbPath 
    )

  //seq2HLA.out.hla.view()

  emit:
  hlafile = seq2HLAtypes
}

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
  seq2HLAtypes //// sampleName, hlaIfile, hlaIIfile
  annotVcf // Channel sampleName, annotVcf
  algos
  minVafDna
  minVafRna
  minVafNormal
  minCovDna
  minCovRna  

  main:

  chVcfHlat =  annotVcf.join(seq2HLAtypes) // sampleName, annotVcf, hlaIfile, hlaIIfile

  pvacseqRun(
    chVcfHlat, // Channel sampleName, annotVcf , hlaIfile, hlaIIfile
    algos,
    minVafDna,
    minVafRna,
    minVafNormal,
    minCovDna,
    minCovRna 
    )

  emit:
  hlafile = seq2HLAtypes
}

/* 
 * pVacseq workflow
 */

include { hlaIConvert } from '../process/hlaIConvert'
include { hlaLaRun } from '../process/hlaLaRun'
include { hlaIIConvert } from '../process/hlaIIConvert'
include { pvacseqRun } from '../process/pvacseqRun'

workflow pVacseqFlow {

  take:
  sp // Channel samplePlan
  graphDir
  graphName
  annotVcf
  algos
  minVafDna
  minVafRna
  minVafNormal
  iedbPath 

  main:
  chVersions = Channel.empty()

  hlaIConvert(
    sp.map{it -> it[1]}, // sampleName
    sp.map{it -> it[12]} // hlaIfile
    )

  hlaLaRun(
    sp.map{it -> it[1]}, // sampleName
    sp.map{it -> it[5]}, // sampleDnaBam
    sp.map{it -> it[6]}, // sampleDnaBamIndex
    graphDir,
    graphName
    )

  hlaIIConvert(
    sp.map{it -> it[1]}, // sampleName
    hlaLaRun.out.hlaIIfile // hlaIIfile
    )

  pvacseqRun(
    sp.map{it -> it[1]}, // sampleName
    sp.map{it -> it[2]}, // normalName
    annotVcf,
    hlaIConvert.out.hlaI,
    hlaIIConvert.out.hlaII,
    algos,
    minVafDna,
    minVafRna,
    minVafNormal,
    iedbPath 
    )

  // chVersions = chVersions.mix(salmonQuantFromBam.out.versions)

  emit:
  hlaIfile = hlaIConvert.out.hlaI
  hlaIIfile = hlaIIConvert.out.hlaII
}

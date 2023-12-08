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
  annotVcf // Channel sampleName, annotVcf
  algos
  minVafDna
  minVafRna
  minVafNormal
  iedbPath 

  main:

  sp.map{ it ->
        def meta = [sampleName:it[0].sampleName ]
        return [meta, it[10]]
      }.set{ chHlaIt }

  hlaIConvert(
    chHlaIt // sampleName, hlaIfile
    )

  sp.map{ it ->
        def meta = [sampleName:it[0].sampleName ]
        return [meta, it[3],it[4]]
      }.set{ chHlaLat }

  hlaLaRun(
    chHlaLat, // sampleName, sampleDnaBam, sampleDnaBamIndex
    graphDir,
    graphName
    )

  hlaIIConvert(
    hlaLaRun.out.hlaIIfile // sampleName, hlaIIfile
    )

  chHlat =  hlaIConvert.out.hlaI.join(hlaIIConvert.out.hlaII) // sampleName, hlaIfile, hlaIIfile

  chVcfHlat =  annotVcf.join(chHlat) // sampleName, hlaIfile, hlaIIfile

  pvacseqRun(
    chVcfHlat, // Channel sampleName, annotVcf , hlaIfile, hlaIIfile
    algos,
    minVafDna,
    minVafRna,
    minVafNormal,
    iedbPath 
    )

  emit:
  hlaIfile = hlaIConvert.out.hlaI
  hlaIIfile = hlaIIConvert.out.hlaII
}

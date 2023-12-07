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
  chVersions = Channel.empty()

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
  // chHlaLat.view()

  hlaLaRun(
    chHlaLat, // sampleName, sampleDnaBam, sampleDnaBamIndex
    graphDir,
    graphName
    )

  hlaIIConvert(
    hlaLaRun.out.hlaIIfile // sampleName, hlaIIfile
    )

  //hlaIIConvert.out.hlaII.view()

  chHlat =  hlaIConvert.out.hlaI.join(hlaIIConvert.out.hlaII) // sampleName, hlaIfile, hlaIIfile
  // chHlat.view()

  // sp.map{ it ->
  //       def meta = [sampleName:it[0].sampleName, normalName:it[0].normalName ]
  //       return [meta]
  //     }.set{ chNormal }

  // chNormal.view()    

  chVcfHlat =  annotVcf.join(chHlat) // sampleName, hlaIfile, hlaIIfile
  //chVcfHlat.view()

  pvacseqRun(
    chVcfHlat, // Channel sampleName, annotVcf , hlaIfile, hlaIIfile
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

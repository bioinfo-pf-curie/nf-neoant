/* 
 * pVacFuse workflow
 */

include { arribaFusion } from '../process/arribaFusion'
include { pvacfuseRun } from '../process/pvacfuseRun'

workflow pVacFuseFlow {

  take:
  sp // Channel samplePlan
  starIndex
  annotation_gtf
  fasta
  fastaFai
  layout
  blacklist_tsv
  protein_gff
  hlaI
  hlaII
  algos
  iedbPath

  main:
  chVersions = Channel.empty()

  arribaFusion(
    sp.map{it -> [it[1],it[10],it[11]]}, // sampleName, sampleRnaBam, sampleRnaBamIndex
    starIndex,
    annotation_gtf,
    fasta,
    fastaFai,
    layout,
    blacklist_tsv,
    protein_gff
  )

  pvacfuseRun(
    sp.map{it -> it[1]}, 
    arribaFusion.out.arribaFus,
    hlaI,
    hlaII,
    algos,
    iedbPath
  )


  // chVersions = chVersions.mix(salmonQuantFromBam.out.versions)

  emit:
  arribaFus = arribaFusion.out.arribaFus

  // versions = chVersions
}

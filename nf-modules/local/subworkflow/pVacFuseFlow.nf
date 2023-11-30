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

  main:
  chVersions = Channel.empty()

  arribaFusion(
    sp.map{it -> [it[1],it[9],it[10]]}, // sampleName, sampleRnaBam, sampleRnaBamIndex
    starIndex,
    annotation_gtf,
    fasta,
    fastaFai,
    layout,
    blacklist_tsv,
    protein_gff
  )

  // pvacfuseRun(
  //   starAlign.out.transcriptsBam,
  //   trsFasta,
  //   gff
  // )

  // chVersions = chVersions.mix(salmonQuantFromBam.out.versions)

  emit:
  arribaFus = arribaFusion.out.arribaFus

  // versions = chVersions
}

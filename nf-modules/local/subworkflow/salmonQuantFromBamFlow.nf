/* 
 * Transcripts Counts workflow
 */

include { starAlign } from '../process/starAlign'
include { salmonQuantFromBam } from '../process/salmonQuantFromBam'

workflow salmonQuantFromBamFlow {

  take:
  sp // Channel samplePlan
  trsFasta // Channel path(transcriptsFasta)
  gtf // Channel path(gtf)
  starIndex
  gff

  main:
  chVersions = Channel.empty()

  starAlign(
    sp.map{it -> [it[1],it[8],it[9]]}, // sampleName, fastqRnaR1, fastqRnaR2
    starIndex,
    gff
  )

  salmonQuantFromBam(
    starAlign.out.transcriptsBam,
    trsFasta,
    gff
  )

  chVersions = chVersions.mix(salmonQuantFromBam.out.versions)

  emit:
  tpmGene = salmonQuantFromBam.out.rnaCounts
  tpmTranscript = salmonQuantFromBam.out.rnaCountsTranscripts

  versions = chVersions
}

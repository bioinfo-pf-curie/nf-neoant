/* 
 * Transcripts Counts workflow
 */

include { starAlign } from '../process/starAlign'
include { salmonQuantFromBam } from '../process/salmonQuantFromBam'

workflow salmonQuantFromBamFlow {

  take:
  sp // Channel meta, fastqRnaR1, fastqRnaR2
  trsFasta // Channel path(transcriptsFasta)
  gtf // Channel path(gtf)
  starIndex
  gff

  main:
  chVersions = Channel.empty()

  starAlign(
    sp,
    starIndex,
    gff
  )

  salmonQuantFromBam(
    starAlign.out.transcriptsBam,
    trsFasta,
    gff
  )

/*  chVersions = chVersions.mix(salmonQuantFromBam.out.versions)
*/
  emit:
  tpm = salmonQuantFromBam.out.tpm // Channel [meta], tpmGene, tpmTranscript

  versions = chVersions
}

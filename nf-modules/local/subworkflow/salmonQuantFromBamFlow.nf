/* 
 * Gene/Transcripts count workflow
 */

include { starAlign } from '../process/starAlign'
include { salmonQuantFromBam } from '../process/salmonQuantFromBam'

workflow salmonQuantFromBamFlow {

  take:
  sp // Channel meta, fastqRnaR1, fastqRnaR2
  trsFasta 
  starIndex
  gff

  main:

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

  emit:
  tpm = salmonQuantFromBam.out.tpm // Channel [meta], tpmGene, tpmTranscript

}

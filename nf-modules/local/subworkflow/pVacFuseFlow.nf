/* 
 * pVacFuse workflow
 */

include { arribaFusion } from '../process/arribaFusion'
include { pvacfuseRun } from '../process/pvacfuseRun'

workflow pVacFuseFlow {

  take:
  rnaBam   // sampleName, RnaBam, RnaBamIndex
  starIndex
  annotation_gtf
  fasta
  fastaFai
  layout
  blacklist_tsv
  protein_gff
  hlat // sampleName, hlaIfile, hlaIIfile
  algos
  tmpdir

  main:

  arribaFusion(
    rnaBam, // sampleName, sampleRnaBam, sampleRnaBamIndex
    starIndex,
    annotation_gtf,
    fasta,
    fastaFai,
    layout,
    blacklist_tsv,
    protein_gff,
    tmpdir
  )

  chFusHlam =  arribaFusion.out.arribaFus.join(hlat) // sampleName, FusionFile, hlaIfile, hlaIIfile
  
  pvacfuseRun(
    chFusHlam,  // sampleName, FusionFile, hlaIfile, hlaIIfile
    algos
  )

  emit:
  arribaFus = arribaFusion.out.arribaFus

}

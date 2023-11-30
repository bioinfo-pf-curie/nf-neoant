/* 
 * VCF annotation workflow
 */

include { vepAnnot } from '../process/vepAnnot'
include { vcfAddExp } from '../process/vcfAddExp'
include { vcfSplit } from '../process/vcfSplit'
include { vcfAddRnaCov } from '../process/vcfAddRnaCov'
include { sortVcf } from '../process/sortVcf'

workflow vcfAnnotFlow {

  take:
  sp // Channel samplePlan
  vep_dir_cache // Channel path(vep_dir_cache)
  fasta
  fastaIndex 
  fastaDict
  vep_plugin_repo
  tpmGene
  tpmTranscript
  vt

  main:
  chVersions = Channel.empty()

  vepAnnot(
    sp.map{it -> [it[1],it[7]]}, // sampleName, vcf
    vep_dir_cache,
    fasta,
    vep_plugin_repo
    )

  vcfAddExp(
    sp.map{it -> it[1]}, // sampleName
    vepAnnot.out.vepVcf,
    tpmGene,
    tpmTranscript
    )

  vcfSplit(
    sp.map{it -> it[1]}, // sampleName
    vcfAddExp.out.exprVcf, //  exprVcf
    vt,
    fasta,
    fastaIndex,
    fastaDict,
    sp.map{it -> it[10]},  // sampleRnaBam
    sp.map{it -> it[11]}  // sampleRnaBamIndex
    )

  vcfAddRnaCov(
    sp.map{it -> it[1]}, // sampleName
    vcfSplit.out.splitSnvVcf,
    vcfSplit.out.splitIndelVcf,
    vcfSplit.out.splitSnvTxt,
    vcfSplit.out.splitIndelTxt
    )

  sortVcf(
    sp.map{it -> it[1]}, // sampleName
    vcfAddRnaCov.out.rnaCovVcf
    )


  chVersions = chVersions.mix(vepAnnot.out.versions)

  emit:
  vepVcf = vepAnnot.out.vepVcf
  exprVcf = vcfAddExp.out.exprVcf
  annotVcf = sortVcf.out.sortedVcf
  
  versions = chVersions
}

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
  sp // Channel meta,vcf, sampleRnaBam, sampleRnaBamIndex
  vep_dir_cache
  fasta
  fastaIndex 
  fastaDict
  vep_plugin_repo
  tpm
  tmpdir

  main:
  chVepVcfTpm = Channel.empty()

  vepAnnot(
    sp.map { it -> [it[0], [it[1]]]}, // sampleName, vcf
    vep_dir_cache,
    fasta,
    vep_plugin_repo
    )

  chVepVcfTpm = vepAnnot.out.vepVcf.join(tpm)

  vcfAddExp(
    chVepVcfTpm
    )

  chSpBam = sp.map { it -> [it[0], it[2], it[3]]}
  chExprVcfRnaBam = vcfAddExp.out.exprVcf.join(chSpBam)

  vcfSplit(
    chExprVcfRnaBam,
    fasta,
    fastaIndex,
    fastaDict
    )

  vcfAddRnaCov(
    vcfSplit.out.splitVcf
    )

  sortVcf(
    vcfAddRnaCov.out.rnaCovVcf,
    tmpdir
    )

  emit:
  vepVcf = vepAnnot.out.vepVcf
  exprVcf = vcfAddExp.out.exprVcf
  annotVcf = sortVcf.out.sortedVcf
}

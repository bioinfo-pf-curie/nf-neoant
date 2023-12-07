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
  vep_dir_cache // Channel path(vep_dir_cache)
  fasta
  fastaIndex 
  fastaDict
  vep_plugin_repo
  tpm
  vt


  main:
  chVersions = Channel.empty()
  chVepVcfTpm = Channel.empty()


  vepAnnot(
    sp.map { it -> [it[0], [it[1]]]}, // sampleName, vcf
    vep_dir_cache,
    fasta,
    vep_plugin_repo
    )

  chVepVcfTpm = vepAnnot.out.vepVcf.join(tpm)
/*  chVepVcfTpm.view()
*/
  vcfAddExp(
    chVepVcfTpm
 /*   tpm
    tpmGene,
    tpmTranscript*/
    )

/*  vcfAddExp.out.exprVcf.view()
*/  
  chSpBam = sp.map { it -> [it[0], it[2], it[3]]}
  chExprVcfRnaBam = vcfAddExp.out.exprVcf.join(chSpBam)
/*  chExprVcfRnaBam.view()
*/

 vcfSplit(
   chExprVcfRnaBam,
    vt,
    fasta,
    fastaIndex,
    fastaDict,
    )

/*  vcfSplit.out.splitVcf.view()
*/
   vcfAddRnaCov(
    vcfSplit.out.splitVcf
    )

/*  vcfAddRnaCov.out.rnaCovVcf.view()
*/
 sortVcf(
    vcfAddRnaCov.out.rnaCovVcf
    )

/*  sortVcf.out.sortedVcf.view()
*/
 /* chVersions = chVersions.mix(vepAnnot.out.versions)
*/
  emit:
  vepVcf = vepAnnot.out.vepVcf
  exprVcf = vcfAddExp.out.exprVcf
  annotVcf = sortVcf.out.sortedVcf
  
  versions = chVersions
}

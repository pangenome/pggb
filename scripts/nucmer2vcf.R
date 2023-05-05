args <- commandArgs()

path_nucmer_var <- args[6]
nameSample <- args[7]
pathRef <- args[8]
nucmer_version <- args[9]
pathOut <- args[10]

if (!require("data.table")){
  install.packages("data.table")
  library("data.table")
}

### Buff_noaln is [BUFF]: the distance from this SNP to the nearest mismatch 
### (end of alignment, indel, SNP, etc) in the same alignment.
### Dist_seqend is [DIST]: the distance from this SNP 
### to the nearest sequence end.
hdShowSnp <- c("Pos_a1", "Allele_a1", "Allele_a2", "Pos_a2",
               "Buff_noaln", "Dist_seqend", "Strand_a1", "Strand_a2",
               "Chrom_a1", "Chrom_a2")


dtNucmer <- fread(path_nucmer_var, header = F, sep = "\t")
colnames(dtNucmer) <- hdShowSnp

dtSNPs <- dtNucmer[Allele_a1 != "." & Allele_a2 != "."]
nR <- nrow(dtSNPs)

headerVcf <- c("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t")

string1 <- "##fileformat=VCFv4.3"
string2 <- paste0("##fileDate=", date())
string3 <- paste0("##source=", nucmer_version)
stringH <- paste0(headerVcf, nameSample)

stringRef <- paste0("##reference=", pathRef)

pathRefFai <- paste0(pathRef, ".fai")
if (file.exists(pathRefFai)) {
  dtFai <- fread(pathRefFai, header = F, sep = "\t")[, c(1, 2)]
  colnames(dtFai) <- c("Chrom_id", "Len_bp")
  stringRef <- paste0(stringRef, '\n', paste0("##contig=<ID=", dtFai$Chrom_id, ",length=", dtFai$Len_bp, ">"))
}

### append the vcf to the corresponding header (with the correct sample name)
cat(string1, string2, string3,
    stringRef,
    stringH,
    file = pathOut, sep = "\n")

if (dim(dtSNPs)[1] > 0) {
  dtVCF <- data.table(dtSNPs$Chrom_a1, dtSNPs$Pos_a1, rep(".", nR),
                      dtSNPs$Allele_a1, dtSNPs$Allele_a2, rep(60, nR),
                      rep(".", nR), # FILTER
                      rep(".", nR), # INFO
                      rep("GT:FRMR:FRMQ:STARTQ:ENDQ", nR), # FORMAT
                      paste("1", dtSNPs$Strand_a1, dtSNPs$Strand_a2,
                            dtSNPs$Pos_a1,
                            dtSNPs$Pos_a2, sep = ":"))
  
  dtVCF <-dtVCF[order(dtVCF$V1, dtVCF$V2),] # Sort by CHROM and POS
  
  fwrite(file = pathOut, append = T, x = dtVCF, quote = F,
         sep = "\t", row.names = F, col.names = F)
}

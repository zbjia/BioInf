library(Biostrings)
library(ape)
library(seqinr)
library(xlsx)

source("Functions.R")

#initializes text file
sink("VHmasteracc.txt")
sink()

accession.num<-paste("KU", seq(602083, 602723,2),sep="")

#pulls sequences from NCBI from a matrix of accesion number strings
for(seq1 in accession.num){
  
  filename=paste(seq1,".fasta",sep = "")
  seqread<- read.GenBank(seq1)
  write.dna(seqread,file=filename, format = "fasta")
  #seqfile<- read.fasta(filename, as.string = TRUE, seqonly = TRUE)
  seqfile<- read.string(filename)
  file.rename(from = paste("~/BioInf/",filename,sep = ""), to = paste("~/BioInf/VH DNA/",filename,sep = ""))
  
  protstr<- translate.fasta(seqfile)
  wprotfile(seq1, protstr, filename)
  file.rename(from = paste("~/BioInf/",filename,sep = ""), to = paste("~/BioInf/VH Prot/",filename,sep = ""))
  
  write(seq1, file = "VHmasteracc.txt", append = TRUE)
}

masteracc.num <- readLines("VHmasteracc.txt")
xlsize=length(masteracc.num)+1 #number of sequences

xlwb <- createWorkbook(type="xlsx")           # create an empty workbook
sheet <- createSheet(xlwb, sheetName="Sheet1")   # create an empty sheet 
rows <- createRow(sheet, rowIndex=1:xlsize)      #rows
cells <- createCell(rows, colIndex=1:xlsize)      #columns

data("BLOSUM80")

for (i in 1:length(masteracc.num)){
  setCellValue(cells[[1+i,1]], masteracc.num[i])
  setCellValue(cells[[1,1+i]], masteracc.num[i])
  for (j in 2:length(masteracc.num)){
    s1=read.string(directory.seq(masteracc.num[i]))
    s2=read.string(directory.seq(masteracc.num[j]))
    localAlign <- pairwiseAlignment(s1,s2, substitutionMatrix=BLOSUM80, gapOpening=-5, gapExtension=-2, scoreOnly=TRUE, type="local")
    setCellValue(cells[[1+i,1+j]], localAlign)
    setCellValue(cells[[1+j,1+i]], localAlign)
  }
}

saveWorkbook(xlwb, "scoresVHProtBLOSUM80.xlsx")
####################################################################################

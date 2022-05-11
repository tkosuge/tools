# tools
## FFintoANN.pl
Converts DDBJ/GenBank type flat file and output as DDBJ annotation and fasta files.
```Shell
perl FFintoANN.pl flatfile.gb
After run the command, you will find "flatfile.gb.ann" & "flatfile.gb.fasta".
```
## ann2table.pl
Converts DDBJ annotation file to tsv. Be sure that the script cannot make COMMON block.
```Shell
perl ann2table.pl AnnotationFile.ann > Output
```
## table2ann.pl
The script has the reverse function of the ann2table.pl. Converts the tsv from ann2table.pl to annotation file. Be sure that the output tsv does not include COMMON block.
```Shell
perl table2ann.pl tsvFile.tsv > Output
```

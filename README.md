# tools
## FFintoANN.pl
Converts DDBJ/GenBank type flat file and output as DDBJ annotation and fasta files.
```Shell
perl FFintoANN.pl flatfile.gb
```
## ann2art.pl
Converts DDBJ annotation file to the file that Artemis can read.
```Shell
perl ann2art.pl AnnotationFile.ann > Output
```
## ann2table.pl
Converts DDBJ annotation file to tsv.
```Shell
perl ann2table.pl AnnotationFile.ann > Output
```
## table2ann.pl
The script has the reverse function of the ann2table.pl. Converts the tsv from ann2table.pl to annotation file. Be sure that the output tsv does not include COMMON block.
```Shell
perl table2ann.pl tsvFile.tsv > Output
```

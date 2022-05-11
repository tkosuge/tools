# tools
## FFintoANN.pl
Converts DDBJ/GenBank type flat file and output as DDBJ annotation and fasta files.
```Shell
perl FFintoANN.pl flatfile.gb
After run the command, you will find "flatfile.gb.ann" & "flatfile.gb.fasta".
```
## ann2table.pl
Converts DDBJ annotation file to tsv. Be sure that the script cannot make COMMON block. When the valuless qualifier is used, the value is expressed as "@@!+!@@".
```Shell
perl ann2table.pl samble.gb.ann > Output
```
## table2ann.pl
The script has the reverse function of the ann2table.pl. Converts the tsv from ann2table.pl to annotation file. Be sure that the output tsv does not include COMMON block.
You should fill "@@!+!@@" in the cell when use the valuless qualifier keys.
```Shell
perl table2ann.pl sample.tsv > Output
```

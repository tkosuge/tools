#!/usr/bin/perl
# ann2art.pl
#
# Convert annotation file to artemis-readable file.
# Usage;
# perl ann2art.pl [annotation file] [sequence file]
# Then, [entry name].art files are produced.
#
# Jul 18, 2008 Tkosuge
#

open (AN,"$ARGV[0]");
open (FA,"$ARGV[1]");

# Create temporary file of olne-line type sequence file;
# @fasta 
while (<FA>) {
if ($_ =~ /^>/) {
     $c++;
     if ($c>1) {
          $_ =~ s/\r\n|\n//;
          $fasta.="\n";
          $fasta.="$_\t";
     }
     if ($c==1) {
          $_ =~ s/\r\n|\n//;
          $fasta.="$_\t";
     }
} else {
     $_ =~ s/\r\n|\n//;
     $_ =~ s/\///g;
     $_ =~ s/ +//g;
     $_ =~ s/\d+//g;
     $fasta.=$_;
}
}
@fasta=split(/\n/,$fasta);


@an=<AN>;
if (($an[0] eq "Entry	Feature	Location	Qualifier	Value\r\n") or ($an[0] eq "Entry	Feature	Location	Qualifier	Value\n")) {
     $s=1;
} else {
     $s=0;
}

for ($i=$s;$i<=$#an;$i++) {
     $an[$i] =~ s/\r\n|\n//;# remove line-feed code
     @aline=split(/\t/,$an[$i]);
     if (($aline[0] ne "COMMON") and ($aline[0] ne "")) {
          $entryname=$aline[0];# obtain entry name
          $centryname++;#        count entry #
          open (ART,">$entryname.art");
#          print $entryname,"\n";
          for ($j=$i;$j<=$#an;$j++) {
               $an[$j] =~ s/\r\n|\n//;# remove line-feed code
               @aline=split(/\t/,$an[$j]);
               if (($aline[0] ne "") and ($aline[0] ne $entryname)) {
                  @sq=grep (/^>$entryname\t/,@fasta);
                  @sequence=split(/\t/,$sq[0]);
                  print ART $sequence[0],"\n";
                  print ART $sequence[1],"\n";
                  close (ART);
                  $i=$j-1;
                  $j=$#an+1;
                  goto ENDFOR1;
               }
               if (($aline[1] != ~/SUBMITTER/i) and ($aline[1] != ~/REFERENCE/i) and ($aline[1] != ~/COMMENT/i) and ($aline[1] != ~/TOPOLOGY/i) and ($aline[1] != ~/DATE/i) and ($aline[1] ne "")) {
                   $feature=$aline[1];# obtain feature
                   $location=$aline[2];# obtain feature's location
                   print ART "     $feature";
                   $mergin=" "x(21-5-length($feature));
                   print ART "$mergin$location\n";
                   if ($aline[3] ne "") {
                        print ART " "x21;
                        print ART "/$aline[3]=".chr(34)."$aline[4]".chr(34)."\n";
                   }
                   for ($k=$j+1;$k<=$#an;$k++) {
                        $an[$k] =~ s/\r\n|\n//;# remove line-feed code
                        @aline=split(/\t/,$an[$k]);
                        
                        if ($aline[1] ne "") {
                            $j=$k-1;
                            $k=$#an+1;
                            goto ENDFOR2;
                        }
                        if ($aline[3] ne "") {
                              print ART " "x21;
                              print ART "/$aline[3]=".chr(34)."$aline[4]".chr(34)."\n"
                        }
                   ENDFOR2:
                   }
               }
          ENDFOR1:
          }
     }
     
}
@sq=grep (/^>$entryname\t/,@fasta);
@sequence=split(/\t/,$sq[0]);
print ART $sequence[0],"\n";
print ART $sequence[1],"\n";
close (ART);

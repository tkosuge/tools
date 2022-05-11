#!/usr/bin/perl
# Jan-31-2007, programmed by tkosuge
# ann2table によってannファイルから変換したtableファイルをannファイルに戻します
# usage 
# perl table2ann.pl [table-ann file] > [outputfile]
#
# tableの先頭では Entry	Feature	Location	Direction	Left	Rightの次に
# Qualifierが始まるようになっていることが必要です
#
# tableでは、translationがexceptionよりも後の項目になるように作成してください
# 
open (FF,$ARGV[0]);

@ff=<FF>;

if ($ff[0]!~ /^Entry\tFeature\tLocation\tDirection\tLeft\tRight/) {
     die "File is invalid!\n";
}
@fq=split(/\t|\r\n$|\n$|\r$/,$ff[0]); #1行目の内容を確保

for ($i=1;$i<=$#ff;$i++) {
     @v=split(/\t|\r\n$|\n$|\r$/,$ff[$i]);#各行の項目を @v に格納
     if ($ff[$i] eq "") {
          die "line $i is null\n";# 空行の時はエラー
     }
     if (($v[0] eq "") or ($v[1] eq "") or ($v[2] eq "")) {
          die "line $i is invalid\n";# entry, feature, locationが空のときはエラー
     }

     if ($i==1) {
          print "$v[0]\t";#$i=1のときにはとにかくエントリ名表示
     } else {
          if (($i>1) and ($v[0] ne $entry)) {
               print "$v[0]\t";# $i>1で、エントリ名が変わっていればエントリ名を表示
          } else {
               print "\t";
          }
     }

     print "$v[1]\t$v[2]";#feature, locationを表示
     $c=3;
     $f_exception=0;
     for ($j=6;$j<=$#v;$j++) {# qualifier, valueを表示
          if (($v[$j] ne "") and ($fq[$j] eq "exception")) {
               $f_exception=1;# exceptionがある場合にはフラグをたてる
          }
          if (($v[$j] ne "") and ($fq[$j] eq "translation") and ($f_exception==0)) {
               $v[$j]="";#exceptionがなければtranslationを表示しないように$v[$j]を空にする
          }
          # valueが空でなく、"@@!+!@@" でもない場合は通常表示
          if (($v[$j] ne "") and ($v[$j] ne "@@!+!@@") and ($v[$j]!~ /^ +$/)) {
               if ($c==3) {
                    print "\t$fq[$j]\t$v[$j]\n";
                    $c=1;
               } else {
                    print "\t\t\t$fq[$j]\t$v[$j]\n";
               }
          }
          # valueが"@@!+!@@" の場合
          if ($v[$j] eq "@@!+!@@") {
               if ($fq[$j] ne "") {# qualifierがあればqualifierのみを表示
                   if ($c==3) {
                        print "\t$fq[$j]\n";
                        $c=1;
                   } else {
                        print "\t\t\t$fq[$j]\n";
                   }
               } else {# qualifierが空なら何も表示しない
                   print "\n";
               }
          }
          
     }
     
     $entry=$v[0];
     $feature=$v[1];
     $location=$v[2];
     


}

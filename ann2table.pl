#!/usr/bin/perl
# annotation fileからfeature, qualifierのテーブルを作成する
# perl ann2table.pl [ann file] > [out file]
# 
# Takehide Kosuge

# 書き出さないqualifierの設定
# SUBMITTERS内のcountryは書き出さないようにしてある
# 
@noqual=qw(Qualifier ab_name author consrtm email fax phone url phext contact zip state city street department 
institute status title year start_page end_page volume journal circular 
type division keyword hold_date);

open (FF,$ARGV[0]);


@ff=<FF>;
for (0..$#ff) {# fileからqualifierを抽出
     @a=split(/\t|\r\n|\n/,$ff[$_]);
     if ($a[1] ne "") {
          $aft=$a[1];
     }
     $qchk=grep(/^$a[3]$/i,@noqual);
     if (($qchk==0) and ($aft!~ /submitter/i)) {
          $v=grep(/^$a[3]$/,@q);
          if ($v==0) {
                push (@q,$a[3]);
          }
     }
}
@q1=sort{$a cmp $b}@q;#qualiferがsortされて格納

# 各qualifierの最大使用数を抽出
@cqmax=();
$aft="";
for (0..$#ff) {
     @a=split(/\t|\r\n|\n/,$ff[$_]);
     if ($a[1] ne "") {
          $aft=$a[1];
     }
          if ($a[1]=~ /[A-Za-z0-9_']/) {
               $c++;
          }
          if ($c==2) {# $cが2になると次のfeatureに移ったと判定
               for (0..$#q1) {
                    # @cqmaxに各qualifierの最大値が格納される
                    if ($cqmax[$_] < $cq[$_]) {
                         $cqmax[$_]=$cq[$_];
                    }
                    $cq[$_]=0;
               }
               $c=1;
          }
          # qualifier の種類ごとに数をカウント
          for ($i=0;$i<=$#q1;$i++) {
               if (($q1[$i] eq $a[3]) and ($aft!~ /submitter/i)) {
                    $cq[$i]++;
                    $i=$#q1+1;# qualifierが見つかればforからでる
               }
          }
}

#ファイルの最終行を判定してqualifier個数を反映させる
for (0..$#q1) {
     # @cqmaxに各qualifierの最大値が格納される
     if ($cqmax[$_] < $cq[$_]) {
          $cqmax[$_]=$cq[$_];
     }
     $cq[$_]=0;
}

#1行目のqualifier行を表示
print"Entry\tFeature\tLocation\tDirection\tLeft\tRight";
@q=();# @qに最大使用数を反映したqualifierリストが入る
for ($i=0;$i<=$#q1;$i++) {
     for (1..$cqmax[$i]) {
          print "\t$q1[$i]";
          push (@q,$q1[$i]);
     }
}
print"\n";

#各featureごとにqualifier内容を書き出す
%qann;
$c=0;
$aft="";
for (0..$#ff) {
     $ff[$_]=~ s/\r\n|\n//g;
     @a=split(/\t/,$ff[$_]);
     if ($a[1] ne "") {
          $aft=$a[1];# featureを格納
     }
     if ($a[0] ne "") {# entry内容を取得
          $entry=$a[0];
     }
     $qchk=grep(/^$a[3]$/i,@noqual);
     if ($qchk==0) {# 10
     if ($a[1]=~ /[A-Za-z0-9_']/) {
          $c++;
          if ($c==2) {# $cが2になると次のfeatureに移ったと判定して表示
               for (0..@q) {
                    print "\t$qann{$_}";
               }
               print "\n";
               %qann=();
               $c=1;
          }
          if (substr($a[2],0,1) eq "c") {
               $direction="-";
          } else {
               $direction="+";
          }
          $location=$a[2];
          $location=~ s/join//g;
          $location=~ s/complement//g;
          $location=~ s/\(//g;
          $location=~ s/\)//g;
          $location=~ s/>//g;
          $location=~ s/<//g;
          @b=split(/\.\.|,/,$location);
          print "$entry\t$aft\t$a[2]\t$direction\t$b[0]\t$b[$#b]";
     }
     # valueを各qualifierごとに@qannに格納
     for ($i=0;$i<=$#q;$i++) {
          if (($q[$i] eq $a[3]) and ($qann{$i} eq "") and ($aft!~ /submitter/i)) {
               if ($a[4] eq "") {
                    $a[4]="@@!+!@@";
               }
               $qann{$i}=$a[4];
               $i=$#q+1;
          }
     }
     
     }# 10
}

# ファイルの最終行を判定して最終featureの内容を書き出し
for (0..@q) {
     print "\t$qann{$_}";
}
print "\n";

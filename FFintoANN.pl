#!/usr/bin/perl
#-----------------------------------------------------
# FFintoANN.pl version 2
# convert flat file into annotation file & fasta file
# 2010-Jan-10 version
#-----------------------------------------------------
#
# programmed by Takehide Kosuge, all rights reserved
# second version: 2010-Jan-15
# first version: 2004-Sep-10
#
# 複数のフラットファイルを含んだファイルの変換にも対応しております
# Usage
# perl FFintoANN.pl [flat file name] [-g] [-c] [-t]
# This command produces two files.
#   Annotation file: [flat file name].ann
#   Fasta file     : [flat file name].fasta
#
# Options
# -g : 'gene' feature is remained in annotatin file.
# -c : 'COMMENT line' is converted into one line by sentence.
# -t : 'translation' qualifier is remained in annotation file.
#
#
$options=$ARGV[1].$ARGV[2].$ARGV[3];
$ffs=$ARGV[0];
open (FF,"<$ffs") or die "$!";
@ftf=<FF>;
$loc=0;#エントリーにカウントを追加するための変数

$annf=$ffs.".ann";# 出力 annotation file名
$fasf=$ffs.".fasta";# 出力 fasta file名
open (ANN,">$annf");
open (FAS,">$fasf");
#Entry	Feature	Location	Qualifier	Valueを出力
print ANN "Entry	Feature	Location	Qualifier	Value\n";

for ($o=0;$o<=$#ftf;$o++) {#13
     if ($ftf[$o]=~ /^LOCUS/) {
          $loc++;
          @file=();
          push (@file,$ftf[$o]);
          $o++;
          until (($ftf[$o]=~ /^LOCUS/) or ($o>$#ftf)) {
               push (@file,$ftf[$o]);
               $o++;
          }
          $o--;
     }


$line=@file;#ファイルの全行数



$i=0;
$c=0;
until ($file[$i]=~ /^FEATURES/) {#2  submitter, contact, 所属情報の表示
## Definitionを格納
if ($file[$i]=~ /^DEFINITION/) {
     $ffdef=$file[$i];
     $ffdef=~ s/^DEFINITION +//;
     $ffdef=~ s/\n|\r\n|\r//;
     $ffdef=~ s/ +$//;
     $i++;
     while ($file[$i]=~ /^            /) {
          $a=$file[$i];
          $a=~ s/\n|\r\n|\r//;
          $a=~ s/ +$//;
          $a=~ s/^ +//;
          if ($ffdef!~ /-$|\/$/) {
               $ffdef=$ffdef." ";
          }
          $ffdef=$ffdef.$a;
          $i++;
     }
     $ffdef=~ s/\.$//;#最後にピリオドがあれば除去
}

#Entry名をLocus行から出力
if ($file[$i]=~ /^LOCUS/) {
   $acc=$file[$i];
   $acc=~ s/^LOCUS +//;
   $acc=~ s/ {3,}.*//;
   $acc=~ s/\n|\r\n|\r//;
   $acc.="_".$loc;
#   $acc=~ s/ .+$//g;# セカンダリアクセッション番号を削除
   print ANN "$acc	SUBMITTER		";#ACCESSION #を表示
}

### keywordの格納
if ($file[$i]=~ /^KEYWORDS/) {
     $keyw=$file[$i];
     $keyw=~ s/^KEYWORDS +//;
     $keyw=~ s/\n|\r\n|\r//;
     $keyw=~ s/ +$//;
     $i++;
     while ($file[$i]=~ /^            /) {
          $a=$file[$i];
          $a=~ s/\n|\r\n|\r//;
          $a=~ s/ +$//;
          $a=~ s/^ +//;
          if ($keyw!~ /-$|\/$|\.$/) {
               $keyw=$keyw." ";
          }
          $keyw=$keyw.$a;
          $i++;
     }
     $keyw=~ s/\.$//;#最後にピリオドがあれば除去
}

#SUBMITTER情報を配列に格納
if ($file[$i]=~ /^  JOURNAL   Submitted/) {#1
   @submitter=();
   $submitter_line=$i;#SUBMITTER行数を格納
   $submitter[0]=$file[$i];
   $submitter[0]=~ s/^  JOURNAL   Submitted.*\) //;
   $submitter[0]=~ s/to the .* databases\.//;
   $submitter[0]=~ s/\n|\r\n|\r//;
   $submitter[0]=~ s/ {1,}$//;;#末尾にスペースがあれば除去
   if ($submitter[0]!~ /-$|\/$/) {#末尾が'-'や'/'でなければスペースをいれる
      $submitter[0]=$submitter[0]." ";
   }
   $i++;
   # ^  JOURNAL   Submittedの次行がContact:の場合contact personを取得した上で所属情報を格納
   if ($file[$i]=~ /^            Contact:/) {
      $contactp=$file[$i];
      $contactp=~ s/\n|\r\n|\n//;
      $contactp=~ s/^ +Contact://;
      $i++;
 
   $j=1;
   while ($file[$i]=~ /^            /) {
         $submitter[$j]=$file[$i];
         $submitter[$j]=~ s/\n|\r\n|\r//;
         $submitter[$j]=~ s/ {1,}$//;#末尾にスペースがあれば除去
         $submitter[$j]=~ s/^            //;#頭のスペースを除去
         if ($submitter[$j]!~ /-$|\/$/) {#末尾が'-'や'/'でなければスペースをいれる
            $submitter[$j]=$submitter[$j]." ";
         }
         $j++;
         $i++;
   }
   } else { # ^  JOURNAL   Submittedの次行がContact:で無い場合はcontact person取得をやめて所属情報を格納
   $contactp="";
   $j=1;
   while ($file[$i]=~ /^            /) {
         $submitter[$j]=$file[$i];
         $submitter[$j]=~ s/\n|\r\n|\r//;
         $submitter[$j]=~ s/ {1,}$//;#末尾にスペースがあれば除去
         $submitter[$j]=~ s/^            //;#頭のスペースを除去
         if ($submitter[$j]!~ /-$|\/$/) {#末尾が'-'や'/'でなければスペースをいれる
            $submitter[$j]=$submitter[$j]." ";
         }
         $j++;
         $i++;
   }
   }
 
   $i--;#while命令で1つ増えているので減らす
   $sub_end[$c]=$i;# 各SUBMITTER情報の最終行数を格納
   
   @subauthor=();#SUBMITTER AUTHORSの内容を行ごとに格納する配列
   #  JOURNAL   Submitted行直前の AUTHORS行を探す
   until ($file[$submitter_line]=~ /^  AUTHORS/) {
         $submitter_line--;
   }
   $sub_start[$c]=$submitter_line-1;# 各SUBMITTER情報のスタート行(REFERENCE行)を格納
   $c++;
   $subauthor[0]=$file[$submitter_line];
   $subauthor[0]=~ s/\n|\r\n|\r//;
   $subauthor[0]=~ s/ {1,}$//;#末尾にスペースがあれば除去
   $subauthor[0]=~ s/^  AUTHORS   //;#冒頭のAUTHORSを除去
   $subauthor[0]=~ s/ and/,/;# andの箇所を置換
   if ($subauthor[0]=~ /,$/) {
      $subauthor[0]=$subauthor[0]." ";#末尾がカンマのときはスペースを加える
   }
   $submitter_line++;
   $j=1;
   while ($file[$submitter_line]=~ /^            /) {
         $subauthor[$j]=$file[$submitter_line];
         $subauthor[$j]=~ s/\n|\r\n|\r//;
         $subauthor[$j]=~ s/ {1,}$//;#末尾にスペースがあれば除去
         $subauthor[$j]=~ s/^ {1,}//;#冒頭のスペースを消去
         $subauthor[$j]=~ s/ and/,/;# andの箇所を置換
         if ($subauthor[$j]=~ /,$/) {
            $subauthor[$j]=$subauthor[$j]." ";#末尾がカンマのときにスペース挿入
         }
   $submitter_line++;
   $j++;
   }

}#1のif文用

$i++;
}#2のuntil用
$ftl=$i;# Feature領域の開始行数


######### SUBMITTER 情報の格納
$a="";
foreach my $value(@subauthor) {#行ごとの内容を連結して$aに保管
      $a=$a.$value;
}
@subauthor=split(/, /,$a);#連結されたAUTHORSの内容を', 'で切り分け各AUTHORとして格納
# Last name-First nameにして@nameに格納
#@name=();
#foreach my $value(@subauthor) {
#      @a=split(/,/,$value);
#      if ($a[1]!~ /\.$/) {#AUTHORの末尾が'.'でない場合は手動で直すよう表示
#          push(@er,"Correction may be needed at SUBMITTER: $a[1] $a[0]");
#      }
#      $a[1]=~ s/\./ /g;
#      push (@name,$a[1].$a[0]);#@nameに表示用SUBMITTERSを格納
#}

#SUBMITTER所属情報の表示
$a="";
foreach my $value(@submitter) {#SUBMITTER所属情報の各行を連結し$aに格納
      $a=$a.$value;
}
$a=~ s/^ +//;# 最初に余計なスペースがあれば除去
$a=~ s/ +$//;# 最後に余計なスペースがあれば除去
$a=~ s/\)$//;# 最後に)があれば除去
@submitter=split(/, |; /,$a);#', ' '; 'で区切って配列化
#@contact=split(/ /,$submitter[0]);#@submitterの最初のindexをcontact personと仮定し格納
#
#eval {grep(/$contact[$#contact]/,@name)};#$contactがSUBMITTERSのいずれかと一致するかをチェック
#if ($@) {
#     $a=0
#     } else {
#     $a=grep(/$contact[$#contact]/,@name);
#}
#if ($a>0) {
#      shift(@submitter);#contactがあればその部分を消去
#      $contactp=join(" ",@contact);# first, last name間にスペースを入れる
#      $contactp=~ s/ $//;
#      print ANN "contact	$contactp\n";#contact personを表示
#      $con1=substr($contact[0],0,1);#contact personのfirst name initialを格納
#      for ($c=1;$c<=$#contact;$c++) {
#           $con1=$con1." ".$contact[$c];# contact personの initial+last nameを格納
#      }
#      $con1=~ s/ $//;
#      $c=0;
#      $cc=0;
#      foreach my $value(@name) {# Submittersの表示
#           if (($value eq $con1) and ($c==0)) {
#                $c=1;# contact personを1度のみの表示にするための変数
#                print ANN "			ab_name	$contactp\n";#authorがcontact pearsonと一致する場合contact personを表示
#           } else {
#                print ANN "			author	$value\n";
#           }
#      }
#} else {#SUBMITTERS内に苗字と同じ名前がない場合はauthorのみ表示

# contact person, ab_name表示
      if ($contactp ne "") {
           print ANN "contact	$contactp\n";#contact personを表示
           foreach my $v(@subauthor) {
                print ANN "			ab_name	$v\n";
           }
      } else {
           print ANN "ab_name	$subauthor[0]\n";
           for ($j=1;$j<=$#subauthor;$j++) {
                print ANN "			ab_name	$subauthor[$j]\n";
           }
      }
#      for ($j=1;$j<=$#name;$j++) {
#          print ANN "			author	$name[$j]\n";
#      }
#}

$j=0;
$eml=-1;#@submitter中のE-mail or Phone or Faxがある位置
foreach my $value(@submitter) {
      if  ($value=~ /\(E-mail|E-mail :|Phone  :|Fax    :/) {
          $eml=$j;
      }
      $j++;
}

#E-mail or Phone or Fax行が存在する場合
if ($eml>=0) {
      $a="";
      if ($eml-5==0) {
            $a=$submitter[$eml-5] } else {
            if ($eml-5>0) {
                  for ($j=0;$j<=$eml-5;$j++) {
                       $a=$a.$submitter[$j].", ";
                  }
            $a=~ s/ $//;
            $a=~ s/,$//;
            } else {
            $a=""
            }
      }
      print ANN "			institute	$a\n";
      if ($eml-4>=0) {
            $a=$submitter[$eml-4] } else {
            $a=""
      }
      print ANN "			department	$a\n";
      if ($eml-3>=0) {
            $a=$submitter[$eml-3] } else {
            $a=""
      }
      print ANN "			street	$a\n";
      if ($eml-2>=0) {
            $a=$submitter[$eml-2] } else {
            $a=""
      }
      print ANN "			city	$a\n";
      my $state=$submitter[$eml-1];
      my $zip=$submitter[$eml-1];
      $state=~ s/ .*$//;
      $zip=~ s/^.* //;
      print ANN "			state	$state\n";
      print ANN "			zip	$zip\n";
      my $country=$submitter[$eml];
      my $email=$submitter[$eml];
      my $phone=$submitter[$eml];
      my $phext=$submitter[$eml];
      my $fax=$submitter[$eml];
      my $url=$submitter[$eml];
      $country=~ s/ \(E-mail.*| E-mail.*| Phone.*| Fax.*| URL.*//;
      $email=~ s/\w+ //;
      $email=~ s/\(E-mail://;
      $email=~ s/.*E-mail ://;
      $email=~ s/ Phone  :.*| Fax    :.*//;
      $phone=~ s/\w+ \(E-mail:.*//;
      $phone=~ s/.*Phone  ://;
      $phone=~ s/ Fax    :.*//;
      $phone=~ s/\(.*//;
      $phext=~ s/\w+ \(E-mail:.*//;
      $phext=~ s/.*Phone  ://;
      $phext=~ s/ Fax    :.*//;
      $phext=~ s/.*ex\.//;
      $phext=~ s/\)//;
      $fax=~ s/\w+ \(E-mail:.*//;
      $fax=~ s/.*Fax    ://;
      $url=~ s/\w+ //;
      $url=~ s/E-mail :.*| Phone  :.*| Fax    :.*//g;
      $url=~ s/URL    ://;

      print ANN "			country	$country\n";
      
      if ($submitter[$eml]=~ /\(E-mail:|E-mail :/) {
           print ANN "			email	$email\n";
      }
      if ($submitter[$eml]=~ /Phone  :/) {
           print ANN "			phone	$phone\n";
      }
      if ($submitter[$eml]=~ /\(ex\./) {
           print ANN "			phext	$phext\n";
      }
      if ($submitter[$eml]=~ /Fax    :/) {
           print ANN "			fax	$fax\n";
      }
      if ($submitter[$eml]=~ /URL    :/) {
           print ANN "			url	$url\n";
      }
      for ($j=$eml+1;$j<=$#submitter;$j++) {
           if ($submitter[$j]=~ /Tel:/) {
                $a=$submitter[$j];
                $a=~ s/Tel://;
                $a=~ s/\(.*//;
                print ANN "			phone	$a\n";
           }
           if ($submitter[$j]=~ /\(ex/) {
               $a=$submitter[$j];
               $a=~ s/.*ex\.//;
               $a=~ s/\)//;
               print ANN "			phext	$a\n";
           }
           if ($submitter[$j]=~ /Fax:/) {
               $a=$submitter[$j];
               $a=~ s/Fax://;
               $a=~ s/\)//;
               print ANN "			fax	$a\n";
           }
           if ($submitter[$j]=~ /URL:/) {
               $a=$submitter[$j];
               $a=~ s/URL://;
               print ANN "			url	$a\n";
           }
      }
}

#E-mail行がない場合は最後の内容をcountry名とみなして各内容を表示
if ($eml<0) {
      print ANN "			country	$submitter[$#submitter]\n";
      my $state=$submitter[$#submitter-1];
      my $zip=$submitter[$#submitter-1];
      $state=~ s/ .*$//;
      $zip=~ s/^.* //;
      print ANN "			zip	$zip\n";
      print ANN "			state	$state\n";
      if ($#submitter-2>=0) {
            $a=$submitter[$#submitter-2] } else {
            $a=""
      }
      print ANN "			city	$a\n";
      if ($#submitter-3>=0) {
            $a=$submitter[$#submitter-3] } else {
            $a=""
      }
      print ANN "			street	$a\n";
      if ($#submitter-4>=0) {
            $a=$submitter[$#submitter-4] } else {
            $a=""
      }
      print ANN "			department	$a\n";
      $a="";
      if ($#submitter-5==0) {
            $a=$submitter[$#submitter-5] } else {
            if ($#submitter-5>0) {
                  push(@er,"Please check submitter information");
                  for ($j=0;$j<=$#submitter-5;$j++) {
                       $a=$a.$submitter[$j].", ";
                  }
            $a=~ s/ $//;
            $a=~ s/,$//;
            } else {
            $a=""
            }
      }
      print ANN "			institute	$a\n";
}

### 論文情報の格納
$i=0;
until ($file[$i]=~ /^FEATURES/) {#3  論文情報の表示
$c=0;
if ($file[$i]=~ /^  AUTHORS/) {#4  REFERENCE AUTHOR行がSUBMITTER情報であれば$c=1を格納
     @refauthor=();
     for ($j=0;$j<=$#sub_start;$j++) {
          if (($sub_start[$j]<=$i) and ($i<=$sub_end[$j])) {
               $c=1;
          }
     }
     if ($c==0) {#5  c=0ならREFERENCE情報を格納
          $refauthor[0]=$file[$i];
          $refauthor[0]=~ s/\n|\r\n|\r//;
          $refauthor[0]=~ s/ {1,}$//;#末尾にスペースがあれば除去
          $refauthor[0]=~ s/^  AUTHORS   //;#冒頭のAUTHORSを除去
          $refauthor[0]=~ s/ and/,/;# andの箇所を置換
          if ($refauthor[0]=~ /,$/) {
              $refauthor[0]=$refauthor[0]." ";#末尾がカンマのときはスペースを加える
          }
          $i++;
          $j=1;
          while ($file[$i]=~ /^            /) {
               $refauthor[$j]=$file[$i];
               $refauthor[$j]=~ s/\n|\r\n|\r//;
               $refauthor[$j]=~ s/ {1,}$//;#末尾にスペースがあれば除去
               $refauthor[$j]=~ s/^ {1,}//;#冒頭のスペースを消去
               $refauthor[$j]=~ s/ and/,/;# andの箇所を置換
               if ($refauthor[$j]=~ /,$/) {
                    $refauthor[$j]=$refauthor[$j]." ";#末尾がカンマのときにスペース挿入
               }
               $i++;
               $j++;
          }

     ######### 論文AUTHOR情報の表示
     $a="";
     $a=join("",@refauthor);#行ごとの内容を連結して$aに保管
     @refauthor=split(/, /,$a);#連結されたAUTHORSの内容を', 'で切り分け各AUTHORとして格納
# Last name-First nameにして@nameに格納
#     @name=();
#     foreach my $value(@refauthor) {
#          @a=split(/,/,$value);
#          if ($a[1]!~ /\.$/) {#AUTHORの末尾が'.'でない場合は手動で直すよう表示
#             push(@er,"Please correct REF AUTHOR: $a[1] $a[0]");
#          }
#          $a[1]=~ s/\./ /g;
#          push (@name,$a[1].$a[0]);#@nameに表示用SUBMITTERSを格納
#     }
#     print ANN "	REFERENCE		author	$name[0]\n";
#     shift(@name);
#     foreach my $value(@name) {
#          print ANN "			author	$value\n";
#     }

#reference author 表示
     print ANN "	REFERENCE		ab_name	$refauthor[0]\n";
     shift(@refauthor);
     foreach my $value(@refauthor) {
          print ANN "			ab_name	$value\n";
     }

     $title="";
     until ($file[$i]=~ /^  JOURNAL/) {# Ref title行を連結
          $a=$file[$i];
          $a=~ s/^  TITLE     //;
          $a=~ s/\n|\r\n|\r//;
          $a=~ s/ {1,}$//;
          $a=~ s/^ {1,}//;
          if ($a!~ /-$|\/$/) {
               $a=$a." ";
          }
          $title=$title.$a;
          $i++;
     }
     $title=~ s/ +$//;#最後にスペースが入ってしまうので削除
     $jn="";# journal領域を格納
     $jn=$file[$i];
     $jn=~ s/^  JOURNAL   //;
     $jn=~ s/\n|\r\n|\r//;
     $jn=~ s/^ +//;
     $jn=~ s/ +$//;
     $jn=~ s/,//;
     $i++;
     while ($file[$i]=~ /^            /) {
          $a=$file[$i];
          $a=~ s/\n|\r\n|\r//;
          $a=~ s/^ +//;
          $a=~ s/ +$//;
          $a=~ s/,//;
          $jn=$jn.$a;
          $i++
     }
     $i--;
     $jo=$jn;
     if ($jn!~ /Unpublished|Published Only in DataBase|In Press/i) {
          print ANN "			status	Published\n";
     }
     if ($jn=~ /Unpublished/i) {# reference statusの表示
#          push(@er,"Reference status of '$jn' is set to 'In Preparation'");
#          print ANN "			status	In Preparation\n";
          print ANN "			status	Unpublished\n";

          $jn=~ s/Unpublished//i;
     }
     if ($jn=~ /Published Only in DataBase/i) {
          print ANN "			status	Published Only in DataBase\n";
          $jn=~ s/Published Only in DataBase//i;

     }
     if ($jn=~ /In Press/i) {
          print ANN "			status	In Press\n";
          $jn=~ s/In Press//i;
     }
     print ANN "			title	$title\n";
     $jn=~ s/^ +//;# ref. status領域が除かれたときの余計なスペースを除去
     $jn=~ s/ +$//;# ref. status領域が除かれたときの余計なスペースを除去
     @a=split(/ /,$jn);
     if ($a[$#a]=~ /\d{4}/) {# yearの表示, @aの最終indexをyearとみなす
          $a[$#a]=~ s/\(|\)//g;
          print ANN "			year	$a[$#a]\n";
          pop(@a);
          } else {
          ($year)=(localtime(time))[5]+1900;
          print ANN "			year	$year\n";
          push(@er,"Cannot find year in Reference: $jo. $year is automatically entered.");
     }
     if ($a[$#a]=~ /^\w+-\w+$/) {# start, end pageの表示
         $a[$#a]=~ s/-/\n			end_page	/;
         print ANN "			start_page	$a[$#a]\n";
         pop(@a);
     } else {
         if ($a[$#a]=~ /^\w+$/) {# start, end page中に'-'がない場合
             print ANN "			start_page	$a[$#a]\n";
             print ANN "			end_page	$a[$#a]\n";
             pop(@a);
          }
     }
     if ($a[$#a]=~ /\(\w+|\w+\)/) {#volume (issue)の表示
          print ANN "			volume	$a[$#a-1] $a[$#a]\n";
          push (@er,"Please verify Reference volume: $a[$#a-1] $a[$#a]");
          pop(@a);
          pop(@a);
     } else {
          if ($a[$#a]=~ /^\w+$/) {#issueがない場合はvolumeのみ表示
               print ANN "			volume	$a[$#a]\n";
               pop(@a);
          }
     }
     if (@a) {
          my $value=join(" ",@a);
          print ANN "			journal	$value\n";
     }
     }#5のif (C=0の時の処理)用
}#4のif用
$i++;
}#3 のunitl用

# topologyの表示
if ($file[0]=~ / {1,}circular{1,}/) {
     print ANN "	TOPOLOGY		circular\n";
}

# division, keywordの表示
if ($file[0]=~ / +EST +/) {
     print ANN "	DIVISION		division	EST\n";
}
if ($file[0]=~ / +HTG +/) {
     print ANN "	DIVISION		division	HTG\n";
}
if ($file[0]=~ / +HTC +/) {
     print ANN "	DIVISION		division	HTC\n";
}
if ($file[0]=~ / +GSS +/) {
     print ANN "	DIVISION		division	GSS\n";
}
if ($file[0]=~ / +STS +/) {
     print ANN "	DIVISION		division	STS\n";
}
if ($file[0]=~ / +CON +/) {
     print ANN "	DIVISION		division	CON\n";
}
if ($keyw ne "") {
     @key=split(/; /,$keyw);
     print ANN "	KEYWORD		keyword	$key[0]\n";
     shift(@key);
     foreach my $value(@key) {
          print ANN "			keyword	$value\n";
     }
}


### COMMENT行の表示 1
if ($options=~ /-c/) {#7 オプション'-c'でCOMMENT内容を文章ごとにマージして表示
$i=0;
until ($file[$i]=~ /^FEATURES/) {#6
      if ($file[$i]=~ /^COMMENT/) {
           @comm=();
           $j=0;
           $comm[$j]=$file[$i];
           $comm[$j]=~ s/^COMMENT     //;
           $comm[$j]=~ s/\n|\r\n|\r//;
           $comm[$j]=~ s/ +$//;
           if (($comm[$j]!~ /-$|\/$|\.$/) and ($comm[$j] ne "") and ($file[$i+1]!~ / +\n/)) {
                $comm[$j]=$comm[$j]." ";
           }
           if ($comm[$j] eq "") {
                $j++;
           }
           if ($comm[$j]=~ /\.$/) {
                $j++;
           }
           
           $i++;
           while ($file[$i]=~ /^            /) {
                $a=$file[$i];
                $a=~ s/^            //;
                $a=~ s/\n|\r\n|\r//;
                $a=~ s/ +$//;
                if (($a!~ /-$|\/$|\.$/) and ($a ne "") and ($file[$i+1]!~ / +\n/)) {
                     $a=$a." ";
                }
                $comm[$j]=$comm[$j].$a;
                if (($a eq "") and ($comm[$j] ne "")) {
                     $j++;
                }
                if (($a eq "") and ($comm[$j] eq "")) {
                     $j++;
                }
                if ($a=~ /\.$/) {
                     $j++;
                }
                $i++;
           }
           $i--;
      $a=grep(/./,@comm);
      if ($a>0) {
           print ANN "	COMMENT		line	$comm[0]\n";
           shift @comm;
           foreach my $value(@comm) {
                print ANN "			line	$value\n";
           }
      }

      }
$i++;


}#6 の until用
}#7 の if用

### COMMENT行の表示 2
if ($options!~ /-c/) {#8 -c オションがなければCOMMENT行をlineごとに表示
$i=0;
until ($file[$i]=~ /^FEATURES/) {#9
      if ($file[$i]=~ /^COMMENT/) {#8
           @comm=();
           $j=0;
           $comm[$j]=$file[$i];
           $comm[$j]=~ s/^COMMENT     //;
           $comm[$j]=~ s/\n|\r\n|\r//;
           $comm[$j]=~ s/ {1,}$//g;
           $i++;
           $j++;
           while ($file[$i]=~ /^            /) {
                $comm[$j]=$file[$i];
                $comm[$j]=~ s/^            //;
                $comm[$j]=~ s/\n|\r\n|\r//;
                $comm[$j]=~ s/ {1,}$//g;
                $i++;
                $j++;
           }
           $i--;
      $a=grep(/./,@comm);
      if ($a>0) {
           print ANN "	COMMENT		line	$comm[0]\n";
           shift @comm;
           foreach my $value(@comm) {
                print ANN "			line	$value\n";
           }
      }

      }
$i++;
}#9のuntil用
}#8のif用

### TPA entryのPRIMARY領域を変換
$i=0;
until ($file[$i]=~ /^FEATURES/) {
     if ($file[$i]=~ /^PRIMARY/) {
          $i++;
          while ($file[$i]=~ /^       /) {
                $a=$file[$i];
                $a=~ s/\n|\r\n|\r//;
                $a=~ s/^ +//;
                @a=split(/ +/,$a);
                $a[0]=~ s/-/\.\./;
                $a[2]=~ s/-/\.\./;
                print ANN "\tPRIMARY_CONTIG\t$a[0]\tentry\t$a[1]\n";
                print ANN "\t\t\tprimary_bases\t$a[2]\n";
                if ($a[3]=~ /^c/) {
                     print ANN "\t\t\tcomplement\n";
                }
          $i++;
          }
          $i--;
     }
     $i++;
}


##### feature領域の取得
for ($i=$ftl;$i<$line;$i++) { #10
if ($file[$i]=~ /^ORIGIN/) {
     $seqline=$i;### 配列の開始位置を格納
     $i=$line;# $iの数を最終行にして for文を終了する
}
if ($file[$i]=~ /^     \w+/) { #11
     $ft=$file[$i];
     $ft=~ s/\n|\r\n|\r//;
     $ft=~ s/^ {1,}//;#最初のスペースを除去
     $ft=~ s/ {1,}$//;#最後にスペースがあれば除去
     if ($file[$i+1]=~ /^                     [A-Za-z<>0-9]/) {#locationが２行以上の場合の処理
          $i++;
          while ($file[$i]=~ /^                     [A-Za-z<>0-9]/) {
                $file[$i]=~ s/^ {1,}//;
                $file[$i]=~ s/ {1,}$//;
                $file[$i]=~ s/\n$|\r\n$|\r$//;
                $ft=$ft.$file[$i];
                $i++;
          }
          $i--;
     }
     $i++;
     @qu=();
     $j=0;
     while ($file[$i]=~ /^ {21}/) {
          $qu[$j]=$file[$i];# qualifier領域の内容を@quに保存
          $qu[$j]=~ s/\n|\r\n|\r//;
          $qu[$j]=~ s/^ {1,}//;#最初のスペースを除去
          $qu[$j]=~ s/ {1,}$//;#最後にスペースがあれば除去
          $qu[$j]=$qu[$j]."\n";# "で区切られる数を数えるため改行をわざと加える
     $j++;
     $i++;
     }
     $i--;
#整形
     $l=0;
     @qv=();
     for ($k=0;$k<$j;$k++) {
        if ($qu[$k]=~ /\/\w+/) {
             $qv[$l]=$qu[$k];
             @a=split(/"/,$qu[$k]);# "で区切られる数をチェック
             $c=@a;
             if ($c==2) {# "が１個含まれている場合複数行に記載があるとみなす
                  $k++;
                  $qv[$l]=~ s/\n|\r\n|\r//;
                  until (($qu[$k]=~ /"$/) or ($k>=$j)) {
                       if ($qv[$l]=~ /^\/translation|\/$|-$/) {#末尾が /, - の場合はスペースを加えないで結合
                            $qu[$k]=~ s/\n|\r\n|\r//;
                            $qv[$l]=$qv[$l].$qu[$k];
                       } else {
                            $qu[$k]=~ s/\n|\r\n|\r//;
                            $qv[$l]=$qv[$l]." ".$qu[$k];
                       }
                       $k++;
                  }
                  if ($qv[$l]=~ /^\/translation|\/$|-$/) {
                       $qv[$l]=$qv[$l].$qu[$k];
                  } else {
                       $qv[$l]=$qv[$l]." ".$qu[$k];
                  }
                   
             }
        $l++;
        }
     }

####  Feature, Qualifierの表示
$ft=~ s/ +/\t/;
$c=0;
if ($ft=~ /^gene/) {# gene feature表示・非表示の処理
     if ($options=~ /-g/) {
          print ANN "	$ft";
          $c=0;
     } else {
          @qv=();
          $c=1;
     }
} else {
     print ANN "	$ft";
}
if ($#qv>-1) {
     $qv[0]=~ s/=/\t/;
     $qv[0]=~ s/"//g;
     $qv[0]=~ s/^\///;
     print ANN "	$qv[0]";
     shift (@qv);
     foreach my $value(@qv) {
          $value=~ s/=/\t/;
          $value=~ s/"//g;
          $value=~ s/^\///;
          if ($value=~ /^translation/) {# translation表示・非表示の処理
               if ($options=~ /-t/) {
                    print ANN "			$value";
               }
          } else {
               print ANN "			$value";
          }
     }
     if ($ft=~ /^source/) {
          print ANN "			ff_definition	$ffdef\n";
     }
} else {
     if ($ft=~ /^source/) { print ANN "	ff_definition	$ffdef"}
     if ($c==0) {print ANN "\n"}
}


}#11のif用
}#10のfor用

### Sequence fastaファイルの作成
print FAS ">$acc\n";
for ($i=$seqline+1;$i<$line;$i++) {#12
     $file[$i]=~ s/[ 0-9]//g;
     $file[$i]=~ s/^ +//g;
     $file[$i]=~ s/^\/\/\n|^\/\/\r\n|^\/\/\r//g;
     $file[$i]=~ s/\n$|\r\n$|\r$//g;
     if ($file[$i] ne "") {print FAS $file[$i],"\n"}
}#12のfor用
print FAS "//\n";

}#13のfor用

close(ANN);
close(FAS);

### warningの表示
foreach my $value(@er) {
     print $value,"\n";
}


#}
#************************************************
#* FFintoANN.pl                                 *
#* version 2.0                                  *
#* 覚書                                         *
#*  プログラム作成者  小菅武英                  *
#************************************************
#
#※FFintoANN.pl とは
#フラットファイルをアノテーションファイルに変換するperlスクリプトです。
#
#※使用方法
#perlを使用できる環境が必要です。フラットファイルはunix改行形式で保存されている
#必要があります。
#
#[コマンド書式]
#perl FFintoANN.pl [flat file name] [-t -g -c]
#
#上記コマンドで
#[flat file name].ann   (annotation file)
#[flat file name].fasta (fasta file)
#が同一ディレクトリに自動作成されます。
#
#
#具体例；
#perl FFintoANN.pl AB100001
#
#perl FFintoANN.pl AB100002 -t -g
#
#perl FFintoANN.pl AB100003 -t- -g -c
# 
#※オプションの説明
#-t : translationクオリファイアとアミノ酸配列をannotation fileに加えます。
#      -t オプションなしではtranslationを加えません。
#-g : geneフィーチャーをannotation fileに記載します。
#      -g オプションなしではannotatin fileからgeneフィーチャーは除かれます。
#-c : ピリオド(.)を文章の終わりと判断し、COMMENT行を文章ごとにマージして表示します。
#      -c オプションなしでは、フラットファイルと同様に改行します。
#
#※その他、注意点
#1.
#GenBank由来のフラットファイルのように、E-mail, tel等がフラットファイル中に記載されて
#いない場合、annotatin file中にはemail, phoneなどが表示されません。
#手動で記入してください。
#
#2.
#annotation fileのReference情報中の'volume'にはissue番号を含めた内容が出力されます。
#
#3.
#annotation fileへの登録者所属情報の表示について;
#フラットファイル内で、Submitterの所属情報の内容がinstitute, department, street, 
#city, state, zip, countryの順に１項目ずつ並んでいる場合のみ annotation fileの
#該当箇所への反映が行えます。
#
#順に１項目ずつ並んでいなければannotatin fileには、ずれた値が表示されます。
#
#4.
#WGS, TPAのフラットファイルではannotation file中にDATATYPEは表示されません。
#
#
#
#
#※warningの内容について,
#手動での修正が明らかな箇所についてはwarningが出力されます。
#
#
#"Please check submitter information"
# ---登録者情報の項目が多い(,で区切られる項目数が多い)場合に表示されます。
# 
# 
#"Cannot find year in Reference: xxxxx. $year is automatically entered."
# ---Referenceの出版年を判定できない場合、コンピューターの内臓時計と同じ年が
#    自動的に記入されます。
# 
#"Please verify Reference volume: xxxxx"
# ---Referenceのvolumeに()が存在する場合に表示されます。
#
#
#
#※履歴
#[2010-Jan-15]
#version 2配布
#ab_naneに対応、reference statusのUnpublishedに対応、email, phone, fax, url の新フォーマットに対応
#
#[2005-Jul-27]
#エントリー名に連続No.を加えて表示するように修正
#(entry名が同一になるのを防ぐため)
#
#[2004-Sep-10]
#version 1.0完成、配布


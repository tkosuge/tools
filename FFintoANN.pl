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
# ʣ���Υե�åȥե������ޤ���ե�������Ѵ��ˤ��б����Ƥ���ޤ�
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
$loc=0;#����ȥ꡼�˥�����Ȥ��ɲä��뤿����ѿ�

$annf=$ffs.".ann";# ���� annotation file̾
$fasf=$ffs.".fasta";# ���� fasta file̾
open (ANN,">$annf");
open (FAS,">$fasf");
#Entry	Feature	Location	Qualifier	Value�����
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


$line=@file;#�ե���������Կ�



$i=0;
$c=0;
until ($file[$i]=~ /^FEATURES/) {#2  submitter, contact, ��°�����ɽ��
## Definition���Ǽ
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
     $ffdef=~ s/\.$//;#�Ǹ�˥ԥꥪ�ɤ�����н���
}

#Entry̾��Locus�Ԥ������
if ($file[$i]=~ /^LOCUS/) {
   $acc=$file[$i];
   $acc=~ s/^LOCUS +//;
   $acc=~ s/ {3,}.*//;
   $acc=~ s/\n|\r\n|\r//;
   $acc.="_".$loc;
#   $acc=~ s/ .+$//g;# ��������ꥢ�����å�����ֹ����
   print ANN "$acc	SUBMITTER		";#ACCESSION #��ɽ��
}

### keyword�γ�Ǽ
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
     $keyw=~ s/\.$//;#�Ǹ�˥ԥꥪ�ɤ�����н���
}

#SUBMITTER���������˳�Ǽ
if ($file[$i]=~ /^  JOURNAL   Submitted/) {#1
   @submitter=();
   $submitter_line=$i;#SUBMITTER�Կ����Ǽ
   $submitter[0]=$file[$i];
   $submitter[0]=~ s/^  JOURNAL   Submitted.*\) //;
   $submitter[0]=~ s/to the .* databases\.//;
   $submitter[0]=~ s/\n|\r\n|\r//;
   $submitter[0]=~ s/ {1,}$//;;#�����˥��ڡ���������н���
   if ($submitter[0]!~ /-$|\/$/) {#������'-'��'/'�Ǥʤ���Х��ڡ����򤤤��
      $submitter[0]=$submitter[0]." ";
   }
   $i++;
   # ^  JOURNAL   Submitted�μ��Ԥ�Contact:�ξ��contact person�����������ǽ�°������Ǽ
   if ($file[$i]=~ /^            Contact:/) {
      $contactp=$file[$i];
      $contactp=~ s/\n|\r\n|\n//;
      $contactp=~ s/^ +Contact://;
      $i++;
 
   $j=1;
   while ($file[$i]=~ /^            /) {
         $submitter[$j]=$file[$i];
         $submitter[$j]=~ s/\n|\r\n|\r//;
         $submitter[$j]=~ s/ {1,}$//;#�����˥��ڡ���������н���
         $submitter[$j]=~ s/^            //;#Ƭ�Υ��ڡ��������
         if ($submitter[$j]!~ /-$|\/$/) {#������'-'��'/'�Ǥʤ���Х��ڡ����򤤤��
            $submitter[$j]=$submitter[$j]." ";
         }
         $j++;
         $i++;
   }
   } else { # ^  JOURNAL   Submitted�μ��Ԥ�Contact:��̵������contact person��������ƽ�°������Ǽ
   $contactp="";
   $j=1;
   while ($file[$i]=~ /^            /) {
         $submitter[$j]=$file[$i];
         $submitter[$j]=~ s/\n|\r\n|\r//;
         $submitter[$j]=~ s/ {1,}$//;#�����˥��ڡ���������н���
         $submitter[$j]=~ s/^            //;#Ƭ�Υ��ڡ��������
         if ($submitter[$j]!~ /-$|\/$/) {#������'-'��'/'�Ǥʤ���Х��ڡ����򤤤��
            $submitter[$j]=$submitter[$j]." ";
         }
         $j++;
         $i++;
   }
   }
 
   $i--;#while̿���1�������Ƥ���ΤǸ��餹
   $sub_end[$c]=$i;# ��SUBMITTER����κǽ��Կ����Ǽ
   
   @subauthor=();#SUBMITTER AUTHORS�����Ƥ�Ԥ��Ȥ˳�Ǽ��������
   #  JOURNAL   Submitted��ľ���� AUTHORS�Ԥ�õ��
   until ($file[$submitter_line]=~ /^  AUTHORS/) {
         $submitter_line--;
   }
   $sub_start[$c]=$submitter_line-1;# ��SUBMITTER����Υ������ȹ�(REFERENCE��)���Ǽ
   $c++;
   $subauthor[0]=$file[$submitter_line];
   $subauthor[0]=~ s/\n|\r\n|\r//;
   $subauthor[0]=~ s/ {1,}$//;#�����˥��ڡ���������н���
   $subauthor[0]=~ s/^  AUTHORS   //;#��Ƭ��AUTHORS�����
   $subauthor[0]=~ s/ and/,/;# and�βս���ִ�
   if ($subauthor[0]=~ /,$/) {
      $subauthor[0]=$subauthor[0]." ";#����������ޤΤȤ��ϥ��ڡ�����ä���
   }
   $submitter_line++;
   $j=1;
   while ($file[$submitter_line]=~ /^            /) {
         $subauthor[$j]=$file[$submitter_line];
         $subauthor[$j]=~ s/\n|\r\n|\r//;
         $subauthor[$j]=~ s/ {1,}$//;#�����˥��ڡ���������н���
         $subauthor[$j]=~ s/^ {1,}//;#��Ƭ�Υ��ڡ�����õ�
         $subauthor[$j]=~ s/ and/,/;# and�βս���ִ�
         if ($subauthor[$j]=~ /,$/) {
            $subauthor[$j]=$subauthor[$j]." ";#����������ޤΤȤ��˥��ڡ�������
         }
   $submitter_line++;
   $j++;
   }

}#1��ifʸ��

$i++;
}#2��until��
$ftl=$i;# Feature�ΰ�γ��ϹԿ�


######### SUBMITTER ����γ�Ǽ
$a="";
foreach my $value(@subauthor) {#�Ԥ��Ȥ����Ƥ�Ϣ�뤷��$a���ݴ�
      $a=$a.$value;
}
@subauthor=split(/, /,$a);#Ϣ�뤵�줿AUTHORS�����Ƥ�', '���ڤ�ʬ����AUTHOR�Ȥ��Ƴ�Ǽ
# Last name-First name�ˤ���@name�˳�Ǽ
#@name=();
#foreach my $value(@subauthor) {
#      @a=split(/,/,$value);
#      if ($a[1]!~ /\.$/) {#AUTHOR��������'.'�Ǥʤ����ϼ�ư��ľ���褦ɽ��
#          push(@er,"Correction may be needed at SUBMITTER: $a[1] $a[0]");
#      }
#      $a[1]=~ s/\./ /g;
#      push (@name,$a[1].$a[0]);#@name��ɽ����SUBMITTERS���Ǽ
#}

#SUBMITTER��°�����ɽ��
$a="";
foreach my $value(@submitter) {#SUBMITTER��°����γƹԤ�Ϣ�뤷$a�˳�Ǽ
      $a=$a.$value;
}
$a=~ s/^ +//;# �ǽ��;�פʥ��ڡ���������н���
$a=~ s/ +$//;# �Ǹ��;�פʥ��ڡ���������н���
$a=~ s/\)$//;# �Ǹ��)������н���
@submitter=split(/, |; /,$a);#', ' '; '�Ƕ��ڤä�����
#@contact=split(/ /,$submitter[0]);#@submitter�κǽ��index��contact person�Ȳ��ꤷ��Ǽ
#
#eval {grep(/$contact[$#contact]/,@name)};#$contact��SUBMITTERS�Τ����줫�Ȱ��פ��뤫������å�
#if ($@) {
#     $a=0
#     } else {
#     $a=grep(/$contact[$#contact]/,@name);
#}
#if ($a>0) {
#      shift(@submitter);#contact������Ф�����ʬ��õ�
#      $contactp=join(" ",@contact);# first, last name�֤˥��ڡ����������
#      $contactp=~ s/ $//;
#      print ANN "contact	$contactp\n";#contact person��ɽ��
#      $con1=substr($contact[0],0,1);#contact person��first name initial���Ǽ
#      for ($c=1;$c<=$#contact;$c++) {
#           $con1=$con1." ".$contact[$c];# contact person�� initial+last name���Ǽ
#      }
#      $con1=~ s/ $//;
#      $c=0;
#      $cc=0;
#      foreach my $value(@name) {# Submitters��ɽ��
#           if (($value eq $con1) and ($c==0)) {
#                $c=1;# contact person��1�٤Τߤ�ɽ���ˤ��뤿����ѿ�
#                print ANN "			ab_name	$contactp\n";#author��contact pearson�Ȱ��פ�����contact person��ɽ��
#           } else {
#                print ANN "			author	$value\n";
#           }
#      }
#} else {#SUBMITTERS����Ļ���Ʊ��̾�����ʤ�����author�Τ�ɽ��

# contact person, ab_nameɽ��
      if ($contactp ne "") {
           print ANN "contact	$contactp\n";#contact person��ɽ��
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
$eml=-1;#@submitter���E-mail or Phone or Fax���������
foreach my $value(@submitter) {
      if  ($value=~ /\(E-mail|E-mail :|Phone  :|Fax    :/) {
          $eml=$j;
      }
      $j++;
}

#E-mail or Phone or Fax�Ԥ�¸�ߤ�����
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

#E-mail�Ԥ��ʤ����ϺǸ�����Ƥ�country̾�Ȥߤʤ��Ƴ����Ƥ�ɽ��
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

### ��ʸ����γ�Ǽ
$i=0;
until ($file[$i]=~ /^FEATURES/) {#3  ��ʸ�����ɽ��
$c=0;
if ($file[$i]=~ /^  AUTHORS/) {#4  REFERENCE AUTHOR�Ԥ�SUBMITTER����Ǥ����$c=1���Ǽ
     @refauthor=();
     for ($j=0;$j<=$#sub_start;$j++) {
          if (($sub_start[$j]<=$i) and ($i<=$sub_end[$j])) {
               $c=1;
          }
     }
     if ($c==0) {#5  c=0�ʤ�REFERENCE������Ǽ
          $refauthor[0]=$file[$i];
          $refauthor[0]=~ s/\n|\r\n|\r//;
          $refauthor[0]=~ s/ {1,}$//;#�����˥��ڡ���������н���
          $refauthor[0]=~ s/^  AUTHORS   //;#��Ƭ��AUTHORS�����
          $refauthor[0]=~ s/ and/,/;# and�βս���ִ�
          if ($refauthor[0]=~ /,$/) {
              $refauthor[0]=$refauthor[0]." ";#����������ޤΤȤ��ϥ��ڡ�����ä���
          }
          $i++;
          $j=1;
          while ($file[$i]=~ /^            /) {
               $refauthor[$j]=$file[$i];
               $refauthor[$j]=~ s/\n|\r\n|\r//;
               $refauthor[$j]=~ s/ {1,}$//;#�����˥��ڡ���������н���
               $refauthor[$j]=~ s/^ {1,}//;#��Ƭ�Υ��ڡ�����õ�
               $refauthor[$j]=~ s/ and/,/;# and�βս���ִ�
               if ($refauthor[$j]=~ /,$/) {
                    $refauthor[$j]=$refauthor[$j]." ";#����������ޤΤȤ��˥��ڡ�������
               }
               $i++;
               $j++;
          }

     ######### ��ʸAUTHOR�����ɽ��
     $a="";
     $a=join("",@refauthor);#�Ԥ��Ȥ����Ƥ�Ϣ�뤷��$a���ݴ�
     @refauthor=split(/, /,$a);#Ϣ�뤵�줿AUTHORS�����Ƥ�', '���ڤ�ʬ����AUTHOR�Ȥ��Ƴ�Ǽ
# Last name-First name�ˤ���@name�˳�Ǽ
#     @name=();
#     foreach my $value(@refauthor) {
#          @a=split(/,/,$value);
#          if ($a[1]!~ /\.$/) {#AUTHOR��������'.'�Ǥʤ����ϼ�ư��ľ���褦ɽ��
#             push(@er,"Please correct REF AUTHOR: $a[1] $a[0]");
#          }
#          $a[1]=~ s/\./ /g;
#          push (@name,$a[1].$a[0]);#@name��ɽ����SUBMITTERS���Ǽ
#     }
#     print ANN "	REFERENCE		author	$name[0]\n";
#     shift(@name);
#     foreach my $value(@name) {
#          print ANN "			author	$value\n";
#     }

#reference author ɽ��
     print ANN "	REFERENCE		ab_name	$refauthor[0]\n";
     shift(@refauthor);
     foreach my $value(@refauthor) {
          print ANN "			ab_name	$value\n";
     }

     $title="";
     until ($file[$i]=~ /^  JOURNAL/) {# Ref title�Ԥ�Ϣ��
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
     $title=~ s/ +$//;#�Ǹ�˥��ڡ��������äƤ��ޤ��ΤǺ��
     $jn="";# journal�ΰ���Ǽ
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
     if ($jn=~ /Unpublished/i) {# reference status��ɽ��
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
     $jn=~ s/^ +//;# ref. status�ΰ褬�����줿�Ȥ���;�פʥ��ڡ��������
     $jn=~ s/ +$//;# ref. status�ΰ褬�����줿�Ȥ���;�פʥ��ڡ��������
     @a=split(/ /,$jn);
     if ($a[$#a]=~ /\d{4}/) {# year��ɽ��, @a�κǽ�index��year�Ȥߤʤ�
          $a[$#a]=~ s/\(|\)//g;
          print ANN "			year	$a[$#a]\n";
          pop(@a);
          } else {
          ($year)=(localtime(time))[5]+1900;
          print ANN "			year	$year\n";
          push(@er,"Cannot find year in Reference: $jo. $year is automatically entered.");
     }
     if ($a[$#a]=~ /^\w+-\w+$/) {# start, end page��ɽ��
         $a[$#a]=~ s/-/\n			end_page	/;
         print ANN "			start_page	$a[$#a]\n";
         pop(@a);
     } else {
         if ($a[$#a]=~ /^\w+$/) {# start, end page���'-'���ʤ����
             print ANN "			start_page	$a[$#a]\n";
             print ANN "			end_page	$a[$#a]\n";
             pop(@a);
          }
     }
     if ($a[$#a]=~ /\(\w+|\w+\)/) {#volume (issue)��ɽ��
          print ANN "			volume	$a[$#a-1] $a[$#a]\n";
          push (@er,"Please verify Reference volume: $a[$#a-1] $a[$#a]");
          pop(@a);
          pop(@a);
     } else {
          if ($a[$#a]=~ /^\w+$/) {#issue���ʤ�����volume�Τ�ɽ��
               print ANN "			volume	$a[$#a]\n";
               pop(@a);
          }
     }
     if (@a) {
          my $value=join(" ",@a);
          print ANN "			journal	$value\n";
     }
     }#5��if (C=0�λ��ν���)��
}#4��if��
$i++;
}#3 ��unitl��

# topology��ɽ��
if ($file[0]=~ / {1,}circular{1,}/) {
     print ANN "	TOPOLOGY		circular\n";
}

# division, keyword��ɽ��
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


### COMMENT�Ԥ�ɽ�� 1
if ($options=~ /-c/) {#7 ���ץ����'-c'��COMMENT���Ƥ�ʸ�Ϥ��Ȥ˥ޡ�������ɽ��
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


}#6 �� until��
}#7 �� if��

### COMMENT�Ԥ�ɽ�� 2
if ($options!~ /-c/) {#8 -c ������󤬤ʤ����COMMENT�Ԥ�line���Ȥ�ɽ��
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
}#9��until��
}#8��if��

### TPA entry��PRIMARY�ΰ���Ѵ�
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


##### feature�ΰ�μ���
for ($i=$ftl;$i<$line;$i++) { #10
if ($file[$i]=~ /^ORIGIN/) {
     $seqline=$i;### ����γ��ϰ��֤��Ǽ
     $i=$line;# $i�ο���ǽ��Ԥˤ��� forʸ��λ����
}
if ($file[$i]=~ /^     \w+/) { #11
     $ft=$file[$i];
     $ft=~ s/\n|\r\n|\r//;
     $ft=~ s/^ {1,}//;#�ǽ�Υ��ڡ��������
     $ft=~ s/ {1,}$//;#�Ǹ�˥��ڡ���������н���
     if ($file[$i+1]=~ /^                     [A-Za-z<>0-9]/) {#location�����԰ʾ�ξ��ν���
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
          $qu[$j]=$file[$i];# qualifier�ΰ�����Ƥ�@qu����¸
          $qu[$j]=~ s/\n|\r\n|\r//;
          $qu[$j]=~ s/^ {1,}//;#�ǽ�Υ��ڡ��������
          $qu[$j]=~ s/ {1,}$//;#�Ǹ�˥��ڡ���������н���
          $qu[$j]=$qu[$j]."\n";# "�Ƕ��ڤ����������뤿����Ԥ�虜�Ȳä���
     $j++;
     $i++;
     }
     $i--;
#����
     $l=0;
     @qv=();
     for ($k=0;$k<$j;$k++) {
        if ($qu[$k]=~ /\/\w+/) {
             $qv[$l]=$qu[$k];
             @a=split(/"/,$qu[$k]);# "�Ƕ��ڤ����������å�
             $c=@a;
             if ($c==2) {# "�����Ĵޤޤ�Ƥ�����ʣ���Ԥ˵��ܤ�����Ȥߤʤ�
                  $k++;
                  $qv[$l]=~ s/\n|\r\n|\r//;
                  until (($qu[$k]=~ /"$/) or ($k>=$j)) {
                       if ($qv[$l]=~ /^\/translation|\/$|-$/) {#������ /, - �ξ��ϥ��ڡ�����ä��ʤ��Ƿ��
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

####  Feature, Qualifier��ɽ��
$ft=~ s/ +/\t/;
$c=0;
if ($ft=~ /^gene/) {# gene featureɽ������ɽ���ν���
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
          if ($value=~ /^translation/) {# translationɽ������ɽ���ν���
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


}#11��if��
}#10��for��

### Sequence fasta�ե�����κ���
print FAS ">$acc\n";
for ($i=$seqline+1;$i<$line;$i++) {#12
     $file[$i]=~ s/[ 0-9]//g;
     $file[$i]=~ s/^ +//g;
     $file[$i]=~ s/^\/\/\n|^\/\/\r\n|^\/\/\r//g;
     $file[$i]=~ s/\n$|\r\n$|\r$//g;
     if ($file[$i] ne "") {print FAS $file[$i],"\n"}
}#12��for��
print FAS "//\n";

}#13��for��

close(ANN);
close(FAS);

### warning��ɽ��
foreach my $value(@er) {
     print $value,"\n";
}


#}
#************************************************
#* FFintoANN.pl                                 *
#* version 2.0                                  *
#* �н�                                         *
#*  �ץ���������  �������                  *
#************************************************
#
#��FFintoANN.pl �Ȥ�
#�ե�åȥե�����򥢥Υơ������ե�������Ѵ�����perl������ץȤǤ���
#
#��������ˡ
#perl����ѤǤ���Ķ���ɬ�פǤ����ե�åȥե������unix���Է�������¸����Ƥ���
#ɬ�פ�����ޤ���
#
#[���ޥ�ɽ�]
#perl FFintoANN.pl [flat file name] [-t -g -c]
#
#�嵭���ޥ�ɤ�
#[flat file name].ann   (annotation file)
#[flat file name].fasta (fasta file)
#��Ʊ��ǥ��쥯�ȥ�˼�ư��������ޤ���
#
#
#�����㡨
#perl FFintoANN.pl AB100001
#
#perl FFintoANN.pl AB100002 -t -g
#
#perl FFintoANN.pl AB100003 -t- -g -c
# 
#�����ץ���������
#-t : translation������ե������ȥ��ߥλ������annotation file�˲ä��ޤ���
#      -t ���ץ����ʤ��Ǥ�translation��ä��ޤ���
#-g : gene�ե������㡼��annotation file�˵��ܤ��ޤ���
#      -g ���ץ����ʤ��Ǥ�annotatin file����gene�ե������㡼�Ͻ�����ޤ���
#-c : �ԥꥪ��(.)��ʸ�Ϥν�����Ƚ�Ǥ���COMMENT�Ԥ�ʸ�Ϥ��Ȥ˥ޡ�������ɽ�����ޤ���
#      -c ���ץ����ʤ��Ǥϡ��ե�åȥե������Ʊ�ͤ˲��Ԥ��ޤ���
#
#������¾�������
#1.
#GenBankͳ��Υե�åȥե�����Τ褦�ˡ�E-mail, tel�����ե�åȥե�������˵��ܤ����
#���ʤ���硢annotatin file��ˤ�email, phone�ʤɤ�ɽ������ޤ���
#��ư�ǵ������Ƥ���������
#
#2.
#annotation file��Reference�������'volume'�ˤ�issue�ֹ��ޤ᤿���Ƥ����Ϥ���ޤ���
#
#3.
#annotation file�ؤ���Ͽ�Խ�°�����ɽ���ˤĤ���;
#�ե�åȥե�������ǡ�Submitter�ν�°��������Ƥ�institute, department, street, 
#city, state, zip, country�ν�ˣ����ܤ����¤�Ǥ�����Τ� annotation file��
#�����ս�ؤ�ȿ�Ǥ��Ԥ��ޤ���
#
#��ˣ����ܤ����¤�Ǥ��ʤ����annotatin file�ˤϡ����줿�ͤ�ɽ������ޤ���
#
#4.
#WGS, TPA�Υե�åȥե�����Ǥ�annotation file���DATATYPE��ɽ������ޤ���
#
#
#
#
#��warning�����ƤˤĤ���,
#��ư�Ǥν��������餫�ʲս�ˤĤ��Ƥ�warning�����Ϥ���ޤ���
#
#
#"Please check submitter information"
# ---��Ͽ�Ծ���ι��ܤ�¿��(,�Ƕ��ڤ�����ܿ���¿��)����ɽ������ޤ���
# 
# 
#"Cannot find year in Reference: xxxxx. $year is automatically entered."
# ---Reference�ν���ǯ��Ƚ��Ǥ��ʤ���硢����ԥ塼��������¡���פ�Ʊ��ǯ��
#    ��ưŪ�˵�������ޤ���
# 
#"Please verify Reference volume: xxxxx"
# ---Reference��volume��()��¸�ߤ������ɽ������ޤ���
#
#
#
#������
#[2010-Jan-15]
#version 2����
#ab_nane���б���reference status��Unpublished���б���email, phone, fax, url �ο��ե����ޥåȤ��б�
#
#[2005-Jul-27]
#����ȥ꡼̾��Ϣ³No.��ä���ɽ������褦�˽���
#(entry̾��Ʊ��ˤʤ�Τ��ɤ�����)
#
#[2004-Sep-10]
#version 1.0����������


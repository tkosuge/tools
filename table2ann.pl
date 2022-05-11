#!/usr/bin/perl
# Jan-31-2007, programmed by tkosuge
# ann2table �ˤ�ä�ann�ե����뤫���Ѵ�����table�ե������ann�ե�������ᤷ�ޤ�
# usage 
# perl table2ann.pl [table-ann file] > [outputfile]
#
# table����Ƭ�Ǥ� Entry	Feature	Location	Direction	Left	Right�μ���
# Qualifier���Ϥޤ�褦�ˤʤäƤ��뤳�Ȥ�ɬ�פǤ�
#
# table�Ǥϡ�translation��exception�����ι��ܤˤʤ�褦�˺������Ƥ�������
# 
open (FF,$ARGV[0]);

@ff=<FF>;

if ($ff[0]!~ /^Entry\tFeature\tLocation\tDirection\tLeft\tRight/) {
     die "File is invalid!\n";
}
@fq=split(/\t|\r\n$|\n$|\r$/,$ff[0]); #1���ܤ����Ƥ����

for ($i=1;$i<=$#ff;$i++) {
     @v=split(/\t|\r\n$|\n$|\r$/,$ff[$i]);#�ƹԤι��ܤ� @v �˳�Ǽ
     if ($ff[$i] eq "") {
          die "line $i is null\n";# ���Ԥλ��ϥ��顼
     }
     if (($v[0] eq "") or ($v[1] eq "") or ($v[2] eq "")) {
          die "line $i is invalid\n";# entry, feature, location�����ΤȤ��ϥ��顼
     }

     if ($i==1) {
          print "$v[0]\t";#$i=1�ΤȤ��ˤϤȤˤ�������ȥ�̾ɽ��
     } else {
          if (($i>1) and ($v[0] ne $entry)) {
               print "$v[0]\t";# $i>1�ǡ�����ȥ�̾���Ѥ�äƤ���Х���ȥ�̾��ɽ��
          } else {
               print "\t";
          }
     }

     print "$v[1]\t$v[2]";#feature, location��ɽ��
     $c=3;
     $f_exception=0;
     for ($j=6;$j<=$#v;$j++) {# qualifier, value��ɽ��
          if (($v[$j] ne "") and ($fq[$j] eq "exception")) {
               $f_exception=1;# exception��������ˤϥե饰�򤿤Ƥ�
          }
          if (($v[$j] ne "") and ($fq[$j] eq "translation") and ($f_exception==0)) {
               $v[$j]="";#exception���ʤ����translation��ɽ�����ʤ��褦��$v[$j]����ˤ���
          }
          # value�����Ǥʤ���"@@!+!@@" �Ǥ�ʤ������̾�ɽ��
          if (($v[$j] ne "") and ($v[$j] ne "@@!+!@@") and ($v[$j]!~ /^ +$/)) {
               if ($c==3) {
                    print "\t$fq[$j]\t$v[$j]\n";
                    $c=1;
               } else {
                    print "\t\t\t$fq[$j]\t$v[$j]\n";
               }
          }
          # value��"@@!+!@@" �ξ��
          if ($v[$j] eq "@@!+!@@") {
               if ($fq[$j] ne "") {# qualifier�������qualifier�Τߤ�ɽ��
                   if ($c==3) {
                        print "\t$fq[$j]\n";
                        $c=1;
                   } else {
                        print "\t\t\t$fq[$j]\n";
                   }
               } else {# qualifier�����ʤ鲿��ɽ�����ʤ�
                   print "\n";
               }
          }
          
     }
     
     $entry=$v[0];
     $feature=$v[1];
     $location=$v[2];
     


}

#!/usr/bin/perl
# annotation file����feature, qualifier�̃e�[�u�����쐬����
# perl ann2table.pl [ann file] > [out file]
# 
# Takehide Kosuge

# �����o���Ȃ�qualifier�̐ݒ�
# SUBMITTERS����country�͏����o���Ȃ��悤�ɂ��Ă���
# 
@noqual=qw(Qualifier ab_name author consrtm email fax phone url phext contact zip state city street department 
institute status title year start_page end_page volume journal circular 
type division keyword hold_date);

open (FF,$ARGV[0]);


@ff=<FF>;
for (0..$#ff) {# file����qualifier�𒊏o
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
@q1=sort{$a cmp $b}@q;#qualifer��sort����Ċi�[

# �equalifier�̍ő�g�p���𒊏o
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
          if ($c==2) {# $c��2�ɂȂ�Ǝ���feature�Ɉڂ����Ɣ���
               for (0..$#q1) {
                    # @cqmax�Ɋequalifier�̍ő�l���i�[�����
                    if ($cqmax[$_] < $cq[$_]) {
                         $cqmax[$_]=$cq[$_];
                    }
                    $cq[$_]=0;
               }
               $c=1;
          }
          # qualifier �̎�ނ��Ƃɐ����J�E���g
          for ($i=0;$i<=$#q1;$i++) {
               if (($q1[$i] eq $a[3]) and ($aft!~ /submitter/i)) {
                    $cq[$i]++;
                    $i=$#q1+1;# qualifier���������for����ł�
               }
          }
}

#�t�@�C���̍ŏI�s�𔻒肵��qualifier���𔽉f������
for (0..$#q1) {
     # @cqmax�Ɋequalifier�̍ő�l���i�[�����
     if ($cqmax[$_] < $cq[$_]) {
          $cqmax[$_]=$cq[$_];
     }
     $cq[$_]=0;
}

#1�s�ڂ�qualifier�s��\��
print"Entry\tFeature\tLocation\tDirection\tLeft\tRight";
@q=();# @q�ɍő�g�p���𔽉f����qualifier���X�g������
for ($i=0;$i<=$#q1;$i++) {
     for (1..$cqmax[$i]) {
          print "\t$q1[$i]";
          push (@q,$q1[$i]);
     }
}
print"\n";

#�efeature���Ƃ�qualifier���e�������o��
%qann;
$c=0;
$aft="";
for (0..$#ff) {
     $ff[$_]=~ s/\r\n|\n//g;
     @a=split(/\t/,$ff[$_]);
     if ($a[1] ne "") {
          $aft=$a[1];# feature���i�[
     }
     if ($a[0] ne "") {# entry���e���擾
          $entry=$a[0];
     }
     $qchk=grep(/^$a[3]$/i,@noqual);
     if ($qchk==0) {# 10
     if ($a[1]=~ /[A-Za-z0-9_']/) {
          $c++;
          if ($c==2) {# $c��2�ɂȂ�Ǝ���feature�Ɉڂ����Ɣ��肵�ĕ\��
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
     # value���equalifier���Ƃ�@qann�Ɋi�[
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

# �t�@�C���̍ŏI�s�𔻒肵�čŏIfeature�̓��e�������o��
for (0..@q) {
     print "\t$qann{$_}";
}
print "\n";

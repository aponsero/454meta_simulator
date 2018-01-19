use 5.010;
use strict;
use warnings;

use LWP::Simple;
use LWP::UserAgent;
use Bio::SeqIO;

my $size=400;

my $name=$ARGV[0];
print "name = $name\n";
my $nb_reads=$ARGV[1];
print "nb_reads= $nb_reads\n";
my $nb_seq=$ARGV[2];
print "nb_seq= $nb_seq\n";
my $db=$ARGV[3];
print "db=$db";
my $refGen="$db/$name";

my $fileexport="artificial_$name.fna";

#my $in  = Bio::SeqIO-> new ( -file   => $refGen,
#                              -format => 'fasta' );

#if(open(my $out, '>', $fileexport)){


print "$refGen contains $nb_seq and I want to generate $nb_reads\n";

#my $cpt=0;

#for(my $i=0; $i<=$nb_reads; $i++){
   #randomly select a contig in the file
#   my $cpt++;

#   my $random_contig = int(rand($nb_seq));
#   print "random contig pick : $random_contig";
#   my $record;

#   for(my $j=0; $j<$random_contig; $j++){
#      $record = $in->next_seq();
#      print "my id = $record->id()\n";
#   }
   
   #my $seq=$record->seq;
   #my $lengthMax=length($seq)-$size;
#   my $lengthMax=700;
   #randomly select a read of given size in contig
#   my $random_read =int(rand($lengthMax));
   
#   print "random read pick : $random_read\n";
   #print $out ">$cpt\n";
   #my $read=substr($seq, $random_read, $size);
   #print $out "$read\n";
   
#}
#}else{die "cannot open $fileexport";}




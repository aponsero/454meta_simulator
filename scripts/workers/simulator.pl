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
my $offset=$ARGV[4];
my $gaussFile="gaussian.log";

my $fileexport="artificial_$name.fna";

my @gaussSize;

##########################import gaussian read size###########################

my $off_comp=0;
if(open(my $gf, '<', $gaussFile)){
    while($off_comp < $offset){
        my $row = <$gf>;
        $off_comp++;
    }
    for(my $k=0;$k<$nb_reads;$k++){
        my $row = <$gf>;
        chomp $row;
        push @gaussSize, $row;
   }

}else{die "could not find $gaussFile for gaussian read profiles";}

##################################print gauss size#########################
print "\nGaussFile offset : $offset\n";
print "gauss size List :\n";
foreach (@gaussSize) {
 	print "$_\n";
}


######################################open files#############################

my $in  = Bio::SeqIO-> new ( -file   => $refGen,
                             -format => 'fasta' );

if(open(my $out, '>', $fileexport)){


print "$refGen contains $nb_seq and I want to generate $nb_reads\n";


####################################script##################

#randomly select contigs in the file

my $ptr=0;
my %random_picks;
my $cpt=0;

if($nb_seq > 1){

   for(my $i=0; $i<$nb_reads; $i++){
   #randomly select a contig in the file

      my $random_contig = int(rand($nb_seq))+1;
      print "random contig pick : $random_contig\n";
      $random_picks{$random_contig}++;
   }
}else{
      $random_picks{1}=$nb_reads;
}

print "############checking hash##############\n";
foreach my $key (keys %random_picks){
  my $value = $random_picks{$key};
  print "Contig n°$key --> $value reads to generates\n";
  }

#parse the file and get random reads
print "###########random reads generation##############\n";
while(my $record = $in->next_seq()){
   $ptr++;
   print "this is record n°$ptr\n";
   if(exists $random_picks{$ptr}){
       print "I need $random_picks{$ptr} reads in that contig\n";
       my $seq=$record->seq();
       
   #randomly select a read of given size in contig
       for(my $j=0; $j< $random_picks{$ptr}; $j++){
          my $readSize=$gaussSize[$cpt];
          my $contig_length=length($seq);
          my $lengthMax=length($seq)-$readSize;

          my $random_start =int(rand($lengthMax))+1;
          my $random_end=$random_start+$readSize;

          print "gaussian read size = $readSize / contig_size = $contig_length / start=$random_start finish= $random_end\n";

          print $out ">artificial_$cpt\n";
          my $read=substr($seq, $random_start, $readSize);
          print $out "$read\n";

          $cpt++
       }
   }else{print "this contig won't be use for read generation\n";}
}



}else{die "cannot open $fileexport";}




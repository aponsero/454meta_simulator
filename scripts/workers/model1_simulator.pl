use 5.010;
use strict;
use warnings;

use LWP::Simple;
use LWP::UserAgent;
use Bio::SeqIO;

#################Argument parsing##################################
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

my $fileexport="artificial_$name";
my $fileexport_err="err_artificial_$name";

my @gaussSize;

#####################error model checks################
my $cpt_ins=0;
my $cpt_mut=0;
my $cpt_del=0;

my $total_read_length=0;
##############Error model###################################################
my $ratemut=1325;
my $rateins=355;
my $ratedel=387;

my %char;
$char{"a"}="model";
$char{"A"}="model";
$char{"t"}="model";
$char{"T"}="model";
$char{"C"}="model";
$char{"c"}="model";
$char{"G"}="model";
$char{"g"}="model";
$char{"n"}="model";
$char{"N"}="model";

################################function declaration###########################
sub RateChoice{
  my $n = scalar(@_);

  my $res=3;
  my $probamut=$_[0];
  my $probains=$_[1];
  my $probadel=$_[2];

  my $randomMut=int(rand($probamut));
  if($randomMut eq 0){$res=0;}
  my $randomIns=int(rand($probains));
  if($randomIns eq 0){
     if($randomMut eq 0){$res=10;}
     else{$res=1;}
  }
  my $randomDel=int(rand($probadel));
  if($randomDel eq 0){$res=2;}


  return $res; #0=mutation;1=insertion;10=mutation+insertion;2=deletion;3=nothing
}

sub MutationCase{
   my $n = scalar(@_);

   my $mutNb=$_[0];#mutation number
   my $orig=$_[1];#original letter
   my $choice;

   if($orig eq "a" or $orig eq "A"){
      if($mutNb eq 1){$choice="t";}
      elsif($mutNb eq 2){$choice="g";}
      elsif($mutNb eq 3){$choice="c";}
      else{die "error in input mutnb $mutNb";}
   }elsif($orig eq "t" or $orig eq "T"){
      if($mutNb eq 1){$choice="a";}
      elsif($mutNb eq 2){$choice="g";}
      elsif($mutNb eq 3){$choice="c";}
      else{die "error in input mutnb $mutNb";}
   }elsif ($orig eq "c" or $orig eq "C"){
      if($mutNb eq 1){$choice="t";}
      elsif($mutNb eq 2){$choice="g";}
      elsif($mutNb eq 3){$choice="a";}
      else{die "error in input mutnb $mutNb";}
   }elsif($orig eq "g" or $orig eq "G"){
      if($mutNb eq 1){$choice="t";}
      elsif($mutNb eq 2){$choice="a";}
      elsif($mutNb eq 3){$choice="c";}
      else{die "error in input mutnb $mutNb";}
   }elsif($orig eq "n" or $orig = "N"){
      if($mutNb eq 1){$choice="t";}
      elsif($mutNb eq 2){$choice="a";}
      elsif($mutNb eq 3){$choice="c";}
      elsif($mutNb eq 4){$choice="g";}
      else{die "error in input mutnb $mutNb";}
   }else {die "error in input letter : $orig";}

   return $choice;
}

sub InsertionCase{
   my $n = scalar(@_);
   my $mutNb=$_[0];

   my $choice;

   if($mutNb eq 1){$choice="a";}
   elsif($mutNb eq 2){$choice="t";}
   elsif($mutNb eq 3){$choice="c";}
   elsif($mutNb eq 4){$choice="g";}

   return $choice;
}

sub ErrorModel{
   my $n = scalar(@_);
   my $read = $_[0];#read
   my $mut_read ="";
   
   for(my $lect=0; $lect<length($read); $lect++){
     my $curr=substr($read, $lect, 1);
 
     if(defined $char{$curr}){
         my $choice=RateChoice($ratemut, $rateins, $ratedel);
         if($choice eq 0){
            my $mut;
            if($curr eq "N" or $curr eq "n"){
                $mut=int(rand(4))+1;
            }else{$mut=int(rand(3))+1;}
            my $letter=MutationCase($mut, $curr);
            $mut_read=$mut_read.$letter;
            $cpt_mut++;
        }elsif($choice eq 1){
            my $ins=int(rand(4))+1;
            my $letterIns=InsertionCase($ins);
            $mut_read=$mut_read.$curr.$letterIns;
            $cpt_ins++;
        }elsif($choice eq 10){
            my $mut;
            if($curr eq "N" or $curr eq "n"){
                $mut=int(rand(4))+1;
            }else{$mut=int(rand(3))+1;}
            my $letter=MutationCase($mut, $curr);
            my $ins=int(rand(4))+1;
            my $letterIns=InsertionCase($ins); 
            $mut_read=$mut_read.$letter.$letterIns;
            $cpt_mut++;
            $cpt_ins++;
        }elsif($choice eq 2){
            $cpt_del++;
        }else{
            $mut_read=$mut_read.$curr;
        } 
      }else{warn "unknown character $curr ; this character was not taken into account\n";}

   }


   return $mut_read;
}

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
        $total_read_length=$total_read_length+$row;
   }

}else{die "could not find $gaussFile for gaussian read profiles";}

##################################print gauss size#########################
print "\nGaussFile offset : $offset\n";

######################################open files#############################

my $in  = Bio::SeqIO-> new ( -file   => $refGen,
                             -format => 'fasta' );

if(open(my $out, '>', $fileexport)){

if(open(my $out_err, '>', $fileexport_err)){

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
       my $seq=$record->seq();
       my $contig_length=length($seq);
       print "I need $random_picks{$ptr} reads in that contig (size = $contig_length )\n";

   #randomly select a read of given size in contig
       for(my $j=0; $j< $random_picks{$ptr}; $j++){
          my $readSize=$gaussSize[$cpt];
          my $lengthMax=length($seq)-$readSize;

          my $random_start =int(rand($lengthMax));
          my $random_end=$random_start+$readSize;

          print $out ">${name}_artificial_$cpt\n";
          my $read=substr($seq, $random_start, $readSize);
          print $out "$read\n";
                  
          #applying error model
          my $read_error=ErrorModel($read);
          print $out_err ">${name}_err_artificial_$cpt\n";
          print $out_err "$read_error\n";          

          $cpt++
       }
   }else{print "this contig won't be use for read generation\n";}
}

################error model check printing###################
print "#####################error report#################\n";
print "nb of pb generated : $total_read_length \n";
print "nb of pb mutated : $cpt_mut \n";
print "nb of pb inserted : $cpt_ins \n";
print "nb of pb deleted : $cpt_del \n";


}else{die "cannot open $fileexport";}


}else{die "cannot open $fileexport_err";}


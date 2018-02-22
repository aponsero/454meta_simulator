use 5.010;
use strict;
use warnings;

use LWP::Simple;
use LWP::UserAgent;
use Bio::SeqIO;

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

####################error model################
my %mutModel;
   $mutModel{"A"}=1133;
   $mutModel{"T"}=1542;
   $mutModel{"C"}=1404;
   $mutModel{"G"}=1274;
   $mutModel{"N"}=1325;

my %favMutation;
   $favMutation{"GGCTT"}="C";
   $favMutation{"GAGCG"}="T";
   $favMutation{"TGTCC"}="G";
   $favMutation{"ATATT"}="C";
   $favMutation{"AAAAG"}="C";
   $favMutation{"CCACT"}="G";
   $favMutation{"TGGGG"}="A";
   $favMutation{"GCGTC"}="C";
   $favMutation{"AAATT"}="A";
   $favMutation{"CCCCT"}="G";
   $favMutation{"TGTTT"}="G";
   $favMutation{"AGGTT"}="G";
   $favMutation{"CGTGG"}="A";
   $favMutation{"TGTTA"}="A";
   $favMutation{"CGTGG"}="C";
   $favMutation{"GGGGG"}="C";
   $favMutation{"CCCCT"}="T";
   $favMutation{"TCGGG"}="A";
   $favMutation{"GGGGA"}="C";
   $favMutation{"GGCCG"}="G";
   $favMutation{"AAAAG"}="G";
   $favMutation{"GTGCA"}="A";
   $favMutation{"CACAA"}="G";
   $favMutation{"ACACT"}="T";
   $favMutation{"TTGGC"}="T";
   $favMutation{"AAAAC"}="C";
   $favMutation{"GGGTC"}="G";
   $favMutation{"AGGGA"}="C";
   $favMutation{"TCCAA"}="G";
   $favMutation{"ACGTG"}="G";
   $favMutation{"AAACA"}="A";
   $favMutation{"CCGCT"}="T";
   $favMutation{"TTCTT"}="C";
   $favMutation{"TTTTG"}="G";
   $favMutation{"GGGGC"}="C";
   $favMutation{"ACCCA"}="G";
   $favMutation{"GGGGC"}="T";
   $favMutation{"TAGGG"}="T";
   $favMutation{"GATCC"}="T";
   $favMutation{"CGGGG"}="T";
   $favMutation{"CAGGG"}="T";
   $favMutation{"GTGGG"}="C";
   $favMutation{"AAGAA"}="G";
   $favMutation{"AAAAC"}="T";
   $favMutation{"GGGGT"}="A";
   $favMutation{"CCACG"}="T";
   $favMutation{"GTGCG"}="T";
   $favMutation{"TTGTT"}="G";
   $favMutation{"AAAAA"}="C";
   $favMutation{"CACGC"}="C";
   $favMutation{"ACCCC"}="G";
   $favMutation{"CGAGG"}="A";
   $favMutation{"GGGAG"}="G";
   $favMutation{"AAATA"}="A";
   $favMutation{"GGTGG"}="T";
   $favMutation{"TTTGG"}="T";
   $favMutation{"GGGGT"}="C";
   $favMutation{"GTGGG"}="T";
   $favMutation{"GACCC"}="T";
   $favMutation{"GGGCG"}="G";
   $favMutation{"GTGAG"}="T";
   $favMutation{"AGGAA"}="G";
   $favMutation{"AAAGG"}="A";
   $favMutation{"CCCCG"}="A";
   $favMutation{"CCCAC"}="C";   



my %fiveProba;
   $fiveProba{"GGCTT"}=0.00085055711491;
   $fiveProba{"GAGCG"}=0.000871344143052;
   $fiveProba{"TGTCC"}=0.000871459694989;
   $fiveProba{"ATATT"}=0.000882320502923;
   $fiveProba{"AAAAG"}=0.000883392226148;
   $fiveProba{"CCACT"}=0.000887803795361;
   $fiveProba{"TGGGG"}=0.000893754887722;
   $fiveProba{"GCGTC"}=0.000897867564534;
   $fiveProba{"AAATT"}=0.000905562742561;
   $fiveProba{"CCCCT"}=0.000906536125465;
   $fiveProba{"TGTTT"}=0.000938306357026;
   $fiveProba{"AGGTT"}=0.000941841299741;
   $fiveProba{"CGTGG"}=0.000949367088608;
   $fiveProba{"TGTTA"}=0.00101611264334;
   $fiveProba{"CGTGG"}=0.00102848101266;
   $fiveProba{"GGGGG"}=0.00103164953392;
   $fiveProba{"CCCCT"}=0.00108784335056;
   $fiveProba{"TCGGG"}=0.00109359922805;
   $fiveProba{"GGGGA"}=0.00120987830048;
   $fiveProba{"GGCCG"}=0.0012942590367;
   $fiveProba{"AAAAG"}=0.00140303471212;
   $fiveProba{"GTGCA"}=0.00140370578327;
   $fiveProba{"CACAA"}=0.0014164305949;
   $fiveProba{"ACACT"}=0.00147368421053;
   $fiveProba{"TTGGC"}=0.00158248714229;
   $fiveProba{"AAAAC"}=0.00160113858744;
   $fiveProba{"GGGTC"}=0.0016257052692;
   $fiveProba{"AGGGA"}=0.00173286199487;
   $fiveProba{"TCCAA"}=0.00174506226699;
   $fiveProba{"ACGTG"}=0.00176385142146;
   $fiveProba{"AAACA"}=0.00178841656349;
   $fiveProba{"CCGCT"}=0.0018819425319;
   $fiveProba{"TTCTT"}=0.00200252169399;
   $fiveProba{"TTTTG"}=0.00203107545445;
   $fiveProba{"GGGGC"}=0.00207177705006;
   $fiveProba{"ACCCA"}=0.00208276736394;
   $fiveProba{"GGGGC"}=0.0021386085678;
   $fiveProba{"TAGGG"}=0.00218493270407;
   $fiveProba{"GATCC"}=0.00224406097655;
   $fiveProba{"CGGGG"}=0.00226169461606;
   $fiveProba{"CAGGG"}=0.00233248515691;
   $fiveProba{"GTGGG"}=0.00249445676275;
   $fiveProba{"AAGAA"}=0.00253827238836;
   $fiveProba{"AAAAC"}=0.00257961216865;
   $fiveProba{"GGGGT"}=0.00263002169768;
   $fiveProba{"CCACG"}=0.00266691189994;
   $fiveProba{"GTGCG"}=0.00273410799727;
   $fiveProba{"TTGTT"}=0.00280735208433;
   $fiveProba{"AAAAA"}=0.00286810310831;
   $fiveProba{"CACGC"}=0.00301521632424;
   $fiveProba{"ACCCC"}=0.00306873977087;
   $fiveProba{"CGAGG"}=0.0030875748503;
   $fiveProba{"GGGAG"}=0.00310182063385;
   $fiveProba{"AAATA"}=0.00314677455608;
   $fiveProba{"GGTGG"}=0.00344946533287;
   $fiveProba{"TTTGG"}=0.00395664889042;
   $fiveProba{"GGGGT"}=0.00401078308896;
   $fiveProba{"GTGGG"}=0.0040465631929;
   $fiveProba{"GACCC"}=0.00425692933497;
   $fiveProba{"GGGCG"}=0.00434995378174;
   $fiveProba{"GTGAG"}=0.00442533034156;
   $fiveProba{"AGGAA"}=0.00521344918776;
   $fiveProba{"AAAGG"}=0.00702019029937;
   $fiveProba{"CCCCG"}=0.0074958864038;
   $fiveProba{"CCCAC"}=0.01024496337;


my $ratemut=1325;
my $rateins=355;
my $ratedel=387;

#####################error model checks################
my $cpt_ins=0;
my $cpt_mut=0;
my $cpt_del=0;

my $total_read_length=0;

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

   if($orig eq "A"){
      if($mutNb eq 1){$choice="T";}
      elsif($mutNb eq 2){$choice="G";}
      elsif($mutNb eq 3){$choice="C";}
      else{die "error in input mutnb $mutNb";}
   }elsif($orig eq "T"){
      if($mutNb eq 1){$choice="A";}
      elsif($mutNb eq 2){$choice="G";}
      elsif($mutNb eq 3){$choice="C";}
      else{die "error in input mutnb $mutNb";}
   }elsif ($orig eq "C"){
      if($mutNb eq 1){$choice="T";}
      elsif($mutNb eq 2){$choice="G";}
      elsif($mutNb eq 3){$choice="A";}
      else{die "error in input mutnb $mutNb";}
   }elsif($orig eq "G"){
      if($mutNb eq 1){$choice="T";}
      elsif($mutNb eq 2){$choice="A";}
      elsif($mutNb eq 3){$choice="C";}
      else{die "error in input mutnb $mutNb";}
   }elsif($orig = "N"){
      if($mutNb eq 1){$choice="T";}
      elsif($mutNb eq 2){$choice="A";}
      elsif($mutNb eq 3){$choice="C";}
      elsif($mutNb eq 4){$choice="G";}
      else{die "error in input mutnb $mutNb";}
   }else {warn "error in input letter : $orig";
         $choice=$orig;}

   return $choice;
}

sub InsertionCase{
   my $n = scalar(@_);
   my $mutNb=$_[0];

   my $choice;

   if($mutNb eq 1){$choice="A";}
   elsif($mutNb eq 2){$choice="T";}
   elsif($mutNb eq 3){$choice="C";}
   elsif($mutNb eq 4){$choice="G";}

   return $choice;
}


sub ErrorModel{
   my $n = scalar(@_);

   my $read = $_[0];#read
   my $mut_read= "";
   #init reading frame
   my $cadre="NNNN";
   my $first_char=uc(substr($read, 0, 1));
   $cadre=$cadre.$first_char;

   #looping through read characters
   for(my $lect=0; $lect<length($read); $lect++){
     my $curr=uc(substr($read, $lect, 1));
     my $next=uc(substr($read, ($lect+1), 1));

     $cadre=$cadre.$next;
     $cadre=substr($cadre, 1); #update reading frame

     if(defined $mutModel{$curr}){
         #choose the rates of mutation, insertions and deletion
       my $choice=3;
       if(defined $fiveProba{$cadre}){
        $choice=RateChoice($fiveProba{$cadre},$rateins, $ratedel);
       } 
       else{  
         $choice=RateChoice($mutModel{$curr},$rateins, $ratedel);
       }
         if($choice eq 0){
             my $mut;
             my $letter="";
             #verify if we need a precise mutation
             if(defined $fiveProba{$cadre}){
                $letter=$favMutation{$cadre};
             }else{
                 if($curr eq "N"){
                     $mut=int(rand(4))+1;
                 }else{$mut=int(rand(3))+1;}
                 $letter=MutationCase($mut, $curr);
             }
             $mut_read=$mut_read.$letter;
             $cpt_mut++;
         }elsif($choice eq 1){
             my $ins=int(rand(4))+1;
             my $letterIns=InsertionCase($ins);
             $mut_read=$mut_read.$curr.$letterIns;
             $cpt_ins++;
         }elsif($choice eq 10){
             my $mut;
             if($curr eq "N"){
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
       my $seq=$record->seq();
       my $contig_length=length($seq);
       print "I need $random_picks{$ptr} reads in that contig (size = $contig_length )\n";
      
   #randomly select a read of given size in contig
       for(my $j=0; $j< $random_picks{$ptr}; $j++){
          my $readSize=$gaussSize[$cpt];
          my $contig_length=length($seq);
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


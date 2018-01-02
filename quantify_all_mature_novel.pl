#! /usr/bin/env perl
use strict;
use warnings;
use utf8;
use Getopt::Long;

# This script needs ucsc's twoBitToFa program
#/data/pkg/ucsc/twoBitToFa
# Uses genome in two bit format for speed
# Change this path for GRCm38 
#/data/db/GenCode/GRCm38p5/GRCm38.primary_assembly.genome.2bit

my $input;
my $output;
my $verbose=0;
my $help=0;
my $USAGE = <<_EOS_;
	./quantify_all_mature_novel.pl <input> <output>
_EOS_

&Getopt::Long::Configure( 'pass_through', 'no_autoabbrev');
&Getopt::Long::GetOptions(
	'input|i=s'     =>  \$input,
	'output|o:s'    =>  \$output,
	'verbose|v!'    =>  \$verbose,
	'help|h'        =>  \$help,
) or die $USAGE . "\n";

if ($help || 0 ) {
	print $USAGE . "\n"
}

my $PROJECT_DIR = $ENV{'DATA_DIR'};
my $ALL_FILE_LIST = $ENV{'ALL_FILE_LIST'};
my $DATA_DIR = $ENV{'DATA_DIR'};

my $NOVEL=0;
my $MATURE=0;
my $MATURE_UN=0;

my $Nmature = InOut::wFILE("all_novel_mature.fa");
my $Nstar = InOut::wFILE("all_novel_star.fa");
my $Nprecursor = InOut::wFILE("all_novel_precursor.fa");

my $MDmature = InOut::wFILE("all_mirbase_detected_mature.fa");
my $MDstar = InOut::wFILE("all_mirbase_detected_star.fa");
my $MDprecursor = InOut::wFILE("all_mirbase_detected_precursor.fa");

#my $MUmature = InOut::wFILE("all_mirbase_mature_undetected.fa");
#my $MUstar = InOut::wFILE("all_mirbase_star_undetected.fa");
#my $MUprecursor = InOut::wFILE("all_mirbase_precursor_undetected.fa");

#miRBase miRNAs not detected by miRDeep2
#miRBase precursor id    total read count        mature read count(s)    star read count remaining reads UCSC browser    NCBI blastn     miRBase mature sequence(s)      miRBase star sequence(s)        miRBase precurso
#r sequence
#
my @sigNOVEL = ();
my @sigMATURE = ();

my $IN = arFILE($ARGV[0]);
while(<$IN>) 
{
	chomp;
	my $LINE=$_;
       	if($LINE =~ m/^[#]*novel/) { 
		$NOVEL=1;
		next;
	}elsif($LINE =~ m/^[#]*mature\s+miRBase\s+miRNAs\s+detected/) { 
		$MATURE=1;
		next;
	}elsif($LINE =~ m/^[#]*mature\s+miRBase\s+miRNAs\s+not\s+detected/) { 
		$MATURE_UN=1;
		next;
	} elsif ($LINE =~ m/^\s*$/) {
       		if($NOVEL) { 
			$NOVEL=0;
		} elsif($MATURE) {
			$MATURE=0;
		#} elsif($MATURE_UN) {
		#	$MATURE_UN=0;
		}
	} elsif ($LINE =~ m/^provisional|tag|miRBase/) {
		next;
	}	
	
	if($NOVEL) {
		my @A = split(/\t/); 
		#my($id, $mature, $star, $precursor, $coord) = @A[0,13,14,15,16];
		my($id, $conf, $mature, $star, $precursor, $coord) = @A[0,2, 13,14,15,16];
		$conf = (split(/\s+/, $conf))[0];
		$id =~ s/\s*//g;
		$star  =~ s/\s*//g;
		$precursor =~ s/\s*//g;
		$coord =~ m/^(.*?):(\d+)[\.][\.](\d+):([\+\-])$/;
		my($chromosome, $start, $end, $strand) = ($1, $2, $3, $4);
		$id = $chromosome . "_" . $start . "_" . $end;
		if($conf > 50) {
			push(@sigNOVEL, "mmu-miR-" . $id);
		}
		$start -= 25;
		$end += 25;
		$precursor=`/data/pkg/ucsc/twoBitToFa -seq=$chromosome -start=$start -end=$end /data/db/GenCode/GRCm38p5/GRCm38.primary_assembly.genome.2bit test.fa; cat test.fa | grep -v "^>" | perl -ne '{chomp; printf("%s", \$_);}'`;

		if($strand eq "-") {
			$precursor =~ tr/[ATGC]/[TACG]/;
			$precursor = reverse($precursor);
		}
		printf $Nmature (">mmu-miR-%s\n%s\n", $id . "-5p", $mature);
		printf $Nstar (">mmu-miR-%s\n%s\n", $id . "-3p", $star);
		printf $Nprecursor (">mmu-mir-%s\n%s\n", $id, $precursor);
	}

	if($MATURE) {
		my @A = split(/\t/); 
		#my($id, $mirid, $mature, $star, $precursor, $coord) = @A[0,10,14,15, 16,17];
		my($id, $conf, $mirid, $mature, $star, $precursor, $coord) = @A[0,2, 9,13,14, 15,16];
		$conf = (split(/\s+/, $conf))[0];
		$id =~ s/\s*//g;
		$mirid =~ s/\s*//g;
		$star  =~ s/\s*//g;
		$precursor =~ s/\s*//g;
		$coord =~ m/^(.*?):(\d+)[\.][\.](\d+):([\+\-])$/;
		my($chromosome, $start, $end, $strand) = ($1, $2, $3, $4);
		$id = $chromosome . "_" . $start . "_" . $end;

		$start -= 25;
		$end += 25;
		$precursor=`/data/pkg/ucsc/twoBitToFa -seq=$chromosome -start=$start -end=$end /data/db/GenCode/GRCm38p5/GRCm38.primary_assembly.genome.2bit test.fa; cat test.fa | grep -v "^>" | perl -ne '{chomp; printf("%s", \$_);}'`;
		if($strand eq "-") {
			$precursor =~ tr/[ATGC]/[TACG]/;
			$precursor = reverse($precursor);
		}
		$mirid =~ s/5p$//;	
		$mirid =~ s/3p$//;	
		$mirid =~ s/[\-]$//;	
		if($conf > 50) {
			push(@sigMATURE, $mirid);
		}

		printf $MDmature (">%s-%s\n%s\n", $mirid , $id . "-5p", $mature);
		printf $MDstar (">%s-%s\n%s\n", $mirid , $id  . "-3p", $star);
		$mirid =~ s/miR/mir/;
		printf $MDprecursor (">%s-%s\n%s\n", $mirid , $id, $precursor);
	}

=pod

	if($MATURE_UN) {
		my @A = split(/\t/); 
		my($mirid, $mature, $precursor) = @A[0,9,scalar(@A)-1];
		$mirid =~ s/\s*//g;
		$mature =~ s/\s*//g;
		$precursor =~ s/\s*//g;
		my $REGION=`grep -m 1 "$mirid" /data/db/miRNA/miRBase/release21/mmu.gff3 | awk '{print(\$1,\$4,\$5);}'`;
		my($chromosome, $start, $end) = split(/\s/, $REGION);
		$start -= 25;
		$end += 25;
		$precursor=`/data/pkg/ucsc/twoBitToFa -seq=$chromosome -start=$start -end=$end /data/db/GenCode/GRCm38p5/GRCm38.primary_assembly.genome.2bit test.fa; cat test.fa | grep -v "^>" | perl -ne '{chomp; printf("%s", \$_);}'`;
		my $count=1;
		foreach $MATURE (split(/\s/, $mature)) 
		{
			printf $MUprecursor (">%s\n%s\n", $mirid . "-$count", $precursor);
			$mirid =~ s/mir/miR/;
			printf $MUmature (">%s\n%s\n", $mirid . "-$count", $MATURE);
			$count++;
		}
	}
=cut

}

my $OUT = InOut::wFILE("sigNOVEL.txt");
printf $OUT ("%s", join("\n", @sigNOVEL));
close($OUT);

$OUT = InOut::wFILE("sigMATURE.txt");
printf $OUT ("%s", join("\n", @sigMATURE));
close($OUT);

close($Nmature);
close($Nstar);
close($Nprecursor);
close($MDmature);
close($MDstar);
close($MDprecursor);
#close($MUmature);
#close($MUstar);
#close($MUprecursor);

sub arFILE
{
my $FILE=shift;

my ($a, $b) = splice( @{[caller(0)]}, 0, 2);
my $INFILE;

my $ftype = `file $FILE`;
if($ftype =~ m/compressed/i) {
    if($ftype =~ m/Xz/i) {
        use IO::Uncompress::UnXz qw(unxz $UnXzError) ;
        $INFILE = new IO::Uncompress::UnXz $FILE || die "\"InOut\" Error: arFILE(@_),  unxz failed: $UnXzError \n Can't read $FILE :  $!\n $d : Called from program $a($b)\n";
    } elsif($ftype =~ m/Lzma/i) {
        use IO::Uncompress::UnLzma qw(unlzma $UnLzmaError) ;
        $INFILE = new IO::Uncompress::Unlzma $FILE || die "\"InOut\" Error: arFILE(@_),  unlzma failed: $UnLzmaError \n Can't read $FILE :  $!\n $d : Called from program $a($b)\n";
    } else {
        use IO::Uncompress::AnyUncompress qw(anyuncompress $AnyUncompressError) ;
        $INFILE = new IO::Uncompress::AnyUncompress $FILE || die "\"InOut\" Error: arFILE(@_),  anyuncompress failed: $AnyUncompressError \n Can't read $FILE :  $!\n $d : Called from program $a($b)\n";
    }
} else {
    $INFILE = new FileHandle("<$FILE") || die "\"InOut\" Error: arFILE(@_), Can't read $FILE :  $!\n $d : Called from program $a($b)\n";
}

return($INFILE);
}


#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;
use LWP::Simple;
use DB_File;


my ($inputSeqFile, $outputFolder, $maxSubject, $cut_e_value, $homo_range, $min_size, $max_size, $num_cpus, $GLOBAL_BLAST_DB) = ('', 'faaOut', 1000, "1e-20", 'F', 0.7, 1.5,1, "/home/blunt/bio/ncbi/db/nr");
my $options = GetOptions(
			"i=s" => \$inputSeqFile,
			"t=s" => \$cut_e_value,
			"o=s" => \$outputFolder,
			"h=s" => \$homo_range,
			"s=f" => \$min_size,
			"l=f" => \$max_size,
			"N=i" => \$num_cpus,
			"d=s" => \$GLOBAL_BLAST_DB
			);

if (! $inputSeqFile) {
	print "use getNcbiSeq.pl [options]\n";
	print "\noptions\n\n";
	print "   -i input filename in fasta format, required\n";
	print "   -o output folder, default faaOut\n";
	print "   -t blast threshold, default 1e-20\n";
	print "   -h remain alignment region, [T/F], default F\n";
	print "   -s minimal sequence size, x time bigger then original sequence, default 0.7\n";
	print "   -l maximal sequence size, y times small then original sequences, defalut 1.5\n";
	print "   -N Number of CPUs to use for BLAST searching, default 1\n";
	print "   -d Blast databaset to use. default: nr\n";

	exit;
}

my $querySeqHashRef = GetInputSeqHashRef($inputSeqFile);

#print Dumper($querySeqHashRef);
my $blastOutputHashRef = Blastcl3($querySeqHashRef, $maxSubject);
PasteSeqToFiles($blastOutputHashRef, $querySeqHashRef, $cut_e_value, $homo_range, $min_size, $max_size, $outputFolder);






sub GetNcbiSeq {
	my ($giArrayRef) = @_;
	my $NcbiSeqFileName = "NCBIsequence.faaTemp";
	my $GI_tempfilename = "SEARCH.gis";
	my $NcbiSeqHashRef = {};
	if (-e $NcbiSeqFileName) {
		$NcbiSeqHashRef = SeqFileToHash($NcbiSeqFileName);
	}

	open(GIFILE, ">$GI_tempfilename");

#	my @giArray;
	foreach my $gi (@$giArrayRef) {
		print GIFILE "$gi\n";
	}

	close(GIFILE);

	system("fastacmd -d $GLOBAL_BLAST_DB -i $GI_tempfilename -t T 1>> $NcbiSeqFileName");

	$NcbiSeqHashRef = SeqFileToHash($NcbiSeqFileName);

	return $NcbiSeqHashRef;
}





sub PasteSeqToFiles{
	my ($blastOutputHashRef, $querySeqHashRef, $cut_e_value, $homo_range, $min_size, $max_size, $outputFolder) = @_;
	my $ncbiSeqHashRef = GetNcbiSeq([keys %$blastOutputHashRef]);
	my $allNames = [keys %$querySeqHashRef];
	my $nameGiHashRef = {};
	my $seqBelowFilter = [];
	while (my ($gi, $resultHashRef) = each %$blastOutputHashRef) {

		if (!exists $ncbiSeqHashRef->{$gi}) {
			delete $blastOutputHashRef->{$gi};
			next;
		}
		my ($name, $e_value) = ($resultHashRef->{'n'}, $resultHashRef->{'e'});

		if ($e_value < $cut_e_value) {
			push @{$nameGiHashRef->{$name}}, $gi;
		} else {
			push @$seqBelowFilter, "$gi\t$name\t$e_value\n";
		}
	}
	
	open (OR, ">remove.table");
	open (ORS, ">remove.faa1");
	foreach (@$seqBelowFilter) {
		my @token = split(/\t/,$_);
		print ORS $ncbiSeqHashRef->{$token[0]};
		print OR $_;
	}
	close OR;

	unless (-e $outputFolder) {
		system("mkdir $outputFolder");
	}
	
	foreach my $name (@$allNames) {
		open (OF,">./$outputFolder/$name.faa");
		print OF $querySeqHashRef->{$name};
		print OF "\n";
		unless (exists $nameGiHashRef->{$name}) {
			next;
		}
		my $giArrayRef = $nameGiHashRef->{$name};
		my $seqTemp = {};
		my $seqNum = (@$giArrayRef);
		my $order = []; 
		my $oriSeqSize = seqSize(\$querySeqHashRef->{$name});
		my $seqSizeHash = {};
		foreach my $gi (@$giArrayRef) {
			my $size = seqSize(\$ncbiSeqHashRef->{$gi});
			$seqSizeHash->{$gi} = $size;
		}


		#$order = [sort {QseqSize(\$NCBIseqHashRef->{$a}) <=> QseqSize(\$NCBIseqHashRef->{$b})} @$giArrayRef];
		$order = [sort {$seqSizeHash->{$a} <=> $seqSizeHash->{$b}} @$giArrayRef];
		open (OF,">./$outputFolder/$name.faa");
		print OF $querySeqHashRef->{$name}; 
		print OF "\n";
		foreach my $gi (@$order) {
			if ($homo_range eq 'T') {
				my $hr = $blastOutputHashRef->{$gi};
				my ($q_start, $q_end, $s_start, $s_end) = ($hr->{'qs'}, $hr->{'qe'}, $hr->{'ss'}, $hr->{'se'});
				my $start = ($s_start > $q_start) ? $s_start - $q_start - 1: 0;
				my $end = (($oriSeqSize - $q_end) < ($seqSizeHash->{$gi} - $s_end)) ? $s_end + $oriSeqSize - $q_end - 1: $seqSizeHash->{$gi} - 1;
		#		print "q $q_start-$q_end of $oriSeqSize\ts $s_start-$s_end of $seqSizeHash->{$gi}\t$start-$end\n"; 
				if (($end - $start) > ($oriSeqSize * $min_size)) {
					my $seq = GetSeqRegion(\$ncbiSeqHashRef->{$gi}, $start, $end, $seqSizeHash->{$gi});
				#print "$name $gi\t$q_start, $q_end, $oriSeqSize\t$s_start, $s_end, $seqSizeHash->{$gi}\t$start, $end\n";
					print OF $seq;
			#	print OF $NCBIseqHashRef->{$gi};
				}
			} else {
				if (($seqSizeHash->{$gi} < $oriSeqSize * $max_size) && ($seqSizeHash->{$gi} > $oriSeqSize * $min_size)) {
					print OF $ncbiSeqHashRef->{$gi};
				}
			}
		}
		close OF;


	}
}

sub GetSeqRegion {
	my ($seqRef, $start, $end, $size) = @_;
	my @array = split(/\n+/,$$seqRef);
	my $title = shift(@array);
	my $join = join('',@array);	
	my $subseq = substr($join, $start, $end - $start);
	for (my $i = 1; $i < (length($subseq) / 71); $i++) {
		substr $subseq, 71 * $i -1 , 0, "\n";
	}
	
#	print "$title $start-$end\n$subseq\n\n";
	return "$title $start-$end of $size\n$subseq\n\n";
}


sub seqSize {
	my ($seqRef) = @_;
	my @array = split(/\n+/,$$seqRef);
	my $size = 0;
	shift(@array);
	foreach (@array) {
	#	if ($_ =~ /\>/) { next;}
		$size += length($_);
	}
	return $size;
}

sub QseqSize {
	return length(${$_[0]}) - index(${$_[0]},"\n");
}

sub DO_CDHIT {

	my ($seqTemp, $giArray, $cutOff) = @_;
	my $command = "cd-hit -i CD_hitTemp.seq -o CD_hitTemp.cdhit -c $cutOff >/dev/null";
	open (OC, ">CD_hitTemp.seq");
	foreach (@$giArray) {
		print OC $seqTemp->{$_};
	}
	close OC;
	system($command);
	my $newArray = [];
	my $hashRef = SeqFileToHash("CD_hitTemp.cdhit");
	system ("rm CD_hitTemp.*");
	@$newArray = keys %$hashRef;
	return $newArray;

}

sub SeqFileToHash {
	my ($seqFileName) = @_;
	my $seqHashRef = {};
	my $title = '';
	open (ISS, $seqFileName);
	while (<ISS>) {
		if ($_ =~ />gi\|(\d+)\|/) {
			$title = $1;
			if (exists $seqHashRef->{$title}) {
				delete $seqHashRef->{$title};
			}
		}
		$seqHashRef->{$title} .= $_;
	}
	close ISS;
	return $seqHashRef;
}

sub Blastcl3 {

	my ($seqHashRef, $maxSubject) = @_;
	my $giBlastResultRef = {};
	my $giToSimilar = [];
	unless (-e "tempOut") {
		system("mkdir tempOut");
	}

	while (my ($name, $sequence) = each %$seqHashRef) {
		my $tempSeqFile = "./tempOut/$name.seqTemp";
		my $tempOutFile = "./tempOut/$name.outTemp";
		open (OS,">$tempSeqFile");
		print OS $sequence;
		close OS;
		#my $command = "blastcl3 -i $tempSeqFile -o $tempOutFile -p blastp -d /home/blunt/bio/ncbi/db/nr -F F -v $maxSubject -b $maxSubject -m8 -e 1e-5";
		unless (-s $tempOutFile) {
			my $command = "blastall -i $tempSeqFile -o $tempOutFile -p blastp -d $GLOBAL_BLAST_DB -F F -v $maxSubject -b $maxSubject -m8 -e 1e-5 -a $num_cpus";
			print "now blasting $name sequence\n";
			system($command);
		}
		unlink($tempSeqFile);
		my $previousGi = '';
		open (IB, $tempOutFile);
		while (my $temp = <IB>)  {
			chomp $temp;
			my @array = split(/\s+/,$temp);
			my ($bit_score, $e_value, $identity, $q_start, $q_end, $s_start, $s_end) = ($array[11], $array[10], $array[2], $array[6], $array[7], $array[8], $array[9]);
			my ($gi) = $array[1] =~ /gi\|(\d+)\|/;
			my $tempRef = { 'b' => $bit_score, 'e' => $e_value, 'n' => $name, 'id' => $identity, 'qs' => $q_start, 'qe' => $q_end, 'ss' => $s_start, 'se' => $s_end};

			if ($previousGi eq $gi) {    #just select fist blast result if there are multiple hits for single sequence
				next;
			} else {
				$previousGi = $gi;
			}

			if ($identity > 95) {  #mark those gi that if the identity are greather then 90 percent to the query sequence
				push @$giToSimilar, $gi;
			}

			if ((exists $giBlastResultRef->{$gi}) && ($bit_score < $giBlastResultRef->{$gi}->{'b'})) {
			#	print "$giBlastResultRef->{$gi}->{'n'} $giBlastResultRef->{$gi}->{'b'}     $name $bit_score\n";
			} else {
				$giBlastResultRef->{$gi} = $tempRef;
			}
		}
		

	}

	foreach my $gi (@$giToSimilar) { #remove those sequences that too similar to Query sequences;
		delete $giBlastResultRef->{$gi};
	#	print "$gi\n";
	}

	return $giBlastResultRef;
}


sub GetInputSeqHashRef {
	my ($inputSeqFile) = @_;
	my $seqHashRef = {};
	my $seqCount = {};
	my $currentName = '';
	open (IS, $inputSeqFile);
	while (<IS>) {
		if ($_ =~ /^\s+/) { next;}
		if ($_ =~ /\>(\S+)\s/) {
			$currentName = $1;
			if (length $currentName > 10) {
				print "Sequence title $currentName is too long, it can not longer then 10 characters!!\n";
				exit;
			}
			$seqCount->{$currentName}++;
		}
			$seqHashRef->{$currentName} .= $_;
	}
	my $redundantNum = 0;
	while (my ($key, $value) = each %$seqCount) {
		$redundantNum = ($value > $redundantNum) ? $value : $redundantNum;
		if ($value >  1) {
			print "sequence name $key has $value copies\n";
		}
	}
	if ($redundantNum > 1) {
		my $errmessage = "\nPlease remove redundant sequences\n\n";
		die $errmessage;
	}
	return $seqHashRef;
}

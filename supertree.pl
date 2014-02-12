#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Math::Complex;
use Data::Dumper;
use XML::Simple;
use DB_File;
#########################################################################
#	Auther : Ming-Ren Yen						#
#	Date: 18JAN08							#
#	UCSD Saier's Lab						#
#	To make alignment or distance matrix for superfamily tree	#
#	from random select sequence					#
#									#
#########################################################################		


# import all sequcne from all faa files to hash %infile_seq_num;

my ($numTrees, $numSeqs, $tempFolder, $output_filename, $input_directory) = (100, 5, "./supertree","infile", ".");

my $command_line_options = GetOptions(
					"n=i" => \$numTrees,
					"s=i" => \$numSeqs,
					"t=s" => \$tempFolder,
					"o=s" => \$output_filename,
					"i=s" => \$input_directory
					);


system("mkdir -p $tempFolder");

my $in = (`ls $input_directory/*.faa`);
$in =~ s/.faa//g;
my $infiles = [split /\n/,$in];


my $seqHashRef = {};
foreach my $inFile (@$infiles) {
	my $hashRef = SeqFileToHash("$inFile.faa");
	$seqHashRef->{$inFile} = $hashRef;	
}


open (OD,">$output_filename") or die;
for (my $tree = 1; $tree <= $numTrees; $tree++) {
	my $randomHashArray = {};
	foreach my $inFile (@$infiles) {
		my @seqNameArray = keys %{$seqHashRef->{$inFile}};
		my $seqNum = (@seqNameArray);
#	$randomHashArray->{$inFile} = RandomArray(0, $seqNum - 1, $numSeqs);
		my $tempArray = [];
		foreach(@{RandomArray(0, $seqNum - 1, $numSeqs)}){
#	print "$seqNameArray[$_] ";
			push @$tempArray, $seqNameArray[$_];
		}
		$randomHashArray->{$inFile} = $tempArray;
#print "\n";
	}
	print "tree # $tree \n";
	my $arrayData = GetScoreMatrix($infiles, $seqHashRef, $randomHashArray);
	my $numFiles = (@$infiles);
	print OD "      $numFiles\n";
	for (my $i = 0; $i < $numFiles; $i++) {
	#	print "$infiles->[$i]\n";
		my $outname = "$infiles->[$i]         ";
		print OD substr($outname, 0, 10);
		for (my $j = 0; $j < $numFiles; $j++) {
			print OD "  $arrayData->[$i][$j]";
		}
		print OD "\n";
	}
	print OD "\n";

}
close OD;



#sub MakeMatrix {
#	my ($infiles, $seqHashRef, $randomHashArray) = @_;
#	my $arrayData = [];
#	my $matrixTemp = [];
#	my $numFiles = (@$infiles);
#
#	push (@$matrixTemp, "      $numFiles\n");
#	for (my $i = 0; $i < $numFiles; $i++) {
#		my $outname = "$infiles->[$i]         ";
#		push (@$matrixTemp, substr($outname, 0, 10));
#               SeqToFile("$tempFolder/$infiles->[$i].subject", $seqHashRef->{$infiles->[$i]}, $randomHashArray->{$infiles->[$i]});
#              system ("formatdb -i $tempFolder/$infiles->[$i].subject -p T -l /dev/null/log");
#             for (my $j = 0; $j < $numFiles; $j++) {
#    #                    if ($i < $j) {
#                                print '.';
#                                SeqToFile("$tempFolder/$infiles->[$j].query", $seqHashRef->{$infiles->[$j]}, $randomHashArray->{$infiles->[$j]});
#                                my $averScore = GetScore3("$tempFolder/$infiles->[$j].query", "$tempFolder/$infiles->[$i].subject", $randomHashArray->{$infiles->[$j]}, $randomHashArray->{$infiles->[$i]});
#                                my $middle = 1;
#                                $arrayData->[$i][$j] = sprintf("%.6f", ($averScore));
#				push (@$matrixTemp, "  $arrayData->[$i][$j]");
#                                unlink("$tempFolder/$infiles->[$j].query");
#                        } elsif ($i > $j) {
#				push (@$matrixTemp, "  $arrayData->[$j][$i]");
#                        } else {
#				push (@$matrixTemp, "  0.000000");
#                        }
#                }
#		push (@$matrixTemp, "\n");
#                print "\n";
#                unlink ("$tempFolder/$infiles->[$i].subject.phr");
#                unlink ("$tempFolder/$infiles->[$i].subject.psq");
#                unlink ("$tempFolder/$infiles->[$i].subject.pin");
#                unlink ("$tempFolder/$infiles->[$i].subject");
#        }
#	push (@$matrixTemp, "\n");
#        print "\n";
#	return $matrixTemp;
#
#
#}






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
		} elsif ($_ =~ />(\S+)\s/) {
			$title = $1;
		}
		$seqHashRef->{$title} .= $_;
	}
	close ISS;
	return $seqHashRef;
}

sub SeqToFile {
	my ($fileName, $seqHashRef, $array) = @_;
	open (OS1, ">$fileName");
	foreach my $name (@$array) {
		print OS1 $seqHashRef->{$name};
	}
	close OS1;
}

sub GetScoreMatrix {
	my ($infiles, $seqHashRef, $randomHashArray) = @_;
	my $numFiles = (@$infiles);
	my $arrayData = [];
	for (my $i = 0; $i < $numFiles; $i++) {
		SeqToFile("$tempFolder/$infiles->[$i].subject", $seqHashRef->{$infiles->[$i]}, $randomHashArray->{$infiles->[$i]});
		system ("formatdb -i $tempFolder/$infiles->[$i].subject -p T -l /dev/null/log");
		for (my $j = 0; $j < $numFiles; $j++) {
			if ($i < $j) {
				print '.';
				SeqToFile("$tempFolder/$infiles->[$j].query", $seqHashRef->{$infiles->[$j]}, $randomHashArray->{$infiles->[$j]});
				my $averScore = GetScore3("$tempFolder/$infiles->[$j].query", "$tempFolder/$infiles->[$i].subject", $randomHashArray->{$infiles->[$j]}, $randomHashArray->{$infiles->[$i]});
				#my $averScore = 1;
				my $temp = sprintf("%.6f", ($averScore));
				$arrayData->[$i][$j] = 	"$temp";
                                unlink("$tempFolder/$infiles->[$j].query");
                        } elsif ($i > $j) {
				$arrayData->[$i][$j] = $arrayData->[$j][$i];
                        } else {
				$arrayData->[$i][$j] = "0.000000";
                        }
                }
                print "\n";
                unlink ("$tempFolder/$infiles->[$i].subject.phr");
                unlink ("$tempFolder/$infiles->[$i].subject.psq");
                unlink ("$tempFolder/$infiles->[$i].subject.pin");
                unlink ("$tempFolder/$infiles->[$i].subject");
        }
	return $arrayData;	
}





sub GetScore3 {
	my ($queryFile, $subjectFile, $array1, $array2) = @_;

	my $scoreHash = {};
	foreach my $name1 (@$array1) {
		foreach my $name2 (@$array2) {
			$scoreHash->{"$name1\t$name2"} = 10;
		}
	}
	my $command = "blastall -i $queryFile -d $subjectFile -p blastp -F T -m8";
	my @result =  `$command`;
	foreach my $input (@result) {
	#	print $input;
	#	chomp $input;
		my @token = split(/\t/, $input);
		my ($name1) = ($token[0] =~ /gi\|(\d+)\|/) ? ($token[0] =~ /gi\|(\d+)\|/) : $token[0];
		my ($name2) = ($token[1] =~ /gi\|(\d+)\|/) ? ($token[1] =~ /gi\|(\d+)\|/) : $token[1];
		if ($scoreHash->{"$name1\t$name2"} == 10) {
			$scoreHash->{"$name1\t$name2"} = $token[11];
		}
	#	print "$name1\t$name2\t$token[11]\n";
	}
	my $array = [values %$scoreHash];
	#system ("rm formatdb.log");
	return (100 / middleScore([values %$scoreHash])) ;
}

sub RandomArray {
	my ($min, $max, $num) = @_;
	my $oldArray = [$min...($max)];
	my $size = (@$oldArray);
	if (($max - $min) < $num) {
	#	print "$size\t@$oldArray\n";
		return $oldArray
	}
	my $newArray = [];
	while ($num) {
		my $rand = rand(time) * 1000 % ($size);
		if ($oldArray->[$rand] ne 'a') {
			push @$newArray, $oldArray->[$rand];
			$oldArray->[$rand] = 'a';
			$num--;
		}
	}
#	print "$size\t@$newArray\n";
	return $newArray;
}


sub middleScore {
	my ($rawArrayRef) = @_;
	my $rawArraySize = (@$rawArrayRef);
	if ($rawArraySize < 2) {
		return $rawArrayRef->[0];
	} elsif ($rawArraySize < 200) {
		my $sum = 0;
		foreach my $score (@$rawArrayRef) {
			$sum += $score;
		}
		return ($sum/$rawArraySize);
	}
	@$rawArrayRef = sort { $b <=> $a } @$rawArrayRef;
	my $distributionArrayRef = [];
	my $scale = 10; # per 1 unit of score. 
	my $arm =  ($scale * $scale) / 2;
	my $distributionArraySize = ($rawArrayRef->[0]) * $scale + $arm;

	#initial the $distributionArrayRef
	for (my $i = 0; $i <= $distributionArraySize; $i++) {
		$distributionArrayRef->[$i] = 0;
	}

	
	foreach my $score (@$rawArrayRef) {
		my $position = $score * $scale;
		my $cStart = $position - $arm;
		my $cEnd = $position + $arm;;
		for (my $i = $cStart; $i <= $cEnd; $i++) {
			$distributionArrayRef->[$i]++;
		}
	}

	my $highestCount = 0;
	my $highestPosition = 10;
	for (my $i = 0; $i <= $distributionArraySize; $i++) {
		if ($distributionArrayRef->[$i] > $highestCount) {
			$highestPosition = $i;
			$highestCount = $distributionArrayRef->[$i];
		}
	}
	return ($highestPosition / $scale);
}



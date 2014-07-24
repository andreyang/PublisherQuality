#!/usr/bin/perl
use strict;
use Shell qw(cp gunzip mv);

#####
## sub declaration
sub bot_testing;

#####
## variable declaration
my $record;
my @imp_record;
my @imp_request;
my $useragent;
my @bot;


#####
## file declaration
my $loaddir =       "c:/Users/ayang/Documents/PublisherQuality/Perl";
my $botfile =       "$loaddir/bot.txt";
#my $botfile =       "$loaddir/bot_iab_bad.txt";
#my $botfile =       "$loaddir/bot_iab_required.txt";
my $datadir =       "$loaddir";
my $logdir  = 	    "$loaddir";
my $infile =        "$datadir/impressions.txt";
my $outfile =        "$datadir/outfile.txt";

#####
## load bot file into array
my $ind = 0;
open(botfile, "< $botfile") or die "Couldn't open $botfile for reading: $!\n";
while ($record = <botfile>) {
  chomp($record);  # remove new line character
  @imp_record = split(/\|/, $record);
  @bot[$ind] = $imp_record[0];
  $ind++;
}
close($botfile);


#####
## input file
open(infile, "< $infile") or die "Couldn't open $infile for reading: $!\n";\


#####
## output file
open(outfile, "> $outfile") or die "Couldn't open $outfile for writing: $!\n";


#####
## loop thru input file
while ($record = <infile>) {	
  chomp($record);  # remove new line character 
  @imp_request = split(/\|/, $record);

  $useragent = lc(@imp_request[0]);
  my $bot_agent = bot_testing($useragent);
  if (length($useragent) < 15) {
    print outfile "$imp_request[0]|$imp_request[1]|$imp_request[2]|null\n";
  }
  elsif ($bot_agent ne "NULL") {
    #;
    print outfile "$imp_request[0]|$imp_request[1]|$imp_request[2]|$bot_agent\n";
  }
  else {
  ;
  #print outfile "$imp_request[0]|$imp_request[1]|$imp_request[2]|NULL\n";
  }
}
  
  
############################################################################################################

sub bot_testing {

  foreach ($ind = 0; $ind < @bot; $ind++) {
    my $botname = lc(@bot[$ind]);
    #if substring has to appears in the beginning, use ==0. else use >=0
    #if (index(@_[0], $botname) >= 0) {
    if (index(@_[0], $botname) == 0) {
      return $botname;
    }
  }
  return "NULL";
}








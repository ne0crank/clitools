#!/usr/bin/env perl

=head1 NAME

building.pl

=head1 SYPNOPSIS

This perl script finds the fastest and cheapest algorithms for finding the highest floor that will not break the golf ball in a 100k floor building.

=cut

# required modules
use strict;
use warnings;
use Date::Calc qw(:all);
#use Data::Dump qw(dump);
use Time::HiRes qw(gettimeofday tv_interval);

# initial values for global variables
my $timers->{app}->{start} = [Time::HiRes::gettimeofday];
my $maxFloor = 100000;
my $eggFloor = $maxFloor;
my $algorithm = {};
my $perfReport = {};

# initial values for algorithm
foreach my $eachFloor ( 1 .. $maxFloor ) {

  if ( $maxFloor % $eachFloor == 0 ) {
      $algorithm->{$eachFloor - 1} = $eachFloor;
  }

}

# print debug info for initial values
#( $algorithm ) and &dump('algorithms', $algorithm);

&printTimer( 'Library', $timers->{app}->{start} );


# strategy notes:
# iterate through each algorithm
# mark time and drop count (also cost) for each
# move up the floors using algorithm until first ball breaks
# when the first ball breaks, move to floor - alg + 1
# and move up floors by one until top floor - 1
# print time used, balls used, and drops

foreach my $algKey ( sort keys %{ $algorithm } ) {

  # start Timer and other variables
  $timers->{$algKey}->{start} = [Time::HiRes::gettimeofday];
  my $dropCount = 0;
  my $ballCount = 2;
  my $thisFloor = 1;
  my $nextFloor = 1;

  # debug printout
  # &dump( "new alg: ", $algorithm->{$algKey}, " balls: $ballCount drops: $dropCount floor: $thisFloor next: $nextFloor" );

  # check the floor and move to another floor or drop the ball
  # while ( $nextFloor < 2 and $dropCount < 2 ) {
  while ( $ballCount > 0 and $dropCount < $maxFloor ) {

    # debug printout
    # &dump( "before drop - alg: ", $algorithm->{$algKey}, " balls: $ballCount drops: $dropCount floor: $thisFloor next: $nextFloor" );

    # drop the ball and check
    ( $ballCount, $dropCount ) =
      &dropBall( $ballCount, $dropCount, $thisFloor );

    # debug printout
    # &dump( "after drop - alg: ", $algorithm->{$algKey}, " balls: $ballCount drops: $dropCount floor: $thisFloor next: $nextFloor" );

    # set the next floor to check
    $nextFloor = &getNextFloor( $ballCount, $algKey + 1, $thisFloor );

    # debug printout
    # &dump( "after next - alg: ", $algorithm->{$algKey}, " balls: $ballCount drops: $dropCount floor: $thisFloor next: $nextFloor" );

    # travel to the next floor to drop the ball from
    $thisFloor = $nextFloor;
  }

  # end and print Timer and results
  &printEntry( $algorithm->{$algKey}, $ballCount, $dropCount, $timers->{$algKey}->{start} );
}

&printTotal;
&printTimer( 'Total', $timers->{app}->{start} );

# method to print out time used for program or algorithm
# takes these inputs:
# - label (what was run)
# - start (start time for label)
# - fini (end time for label)
# output: time in seconds
sub printTimer {
  my ($label, $start, $fini) = @_;
  $label = ( $label ) ? $label : 'Total';
  $start = ( $start ) ? $start : [Time::HiRes::gettimeofday];
  $fini = ( $fini ) ? $fini : [Time::HiRes::gettimeofday];

  my $sec_timer = Time::HiRes::tv_interval( $timers->{app}->{start}, [Time::HiRes::gettimeofday] );

  printf "\nApp %s Timer: %0.6f seconds\n", $label, $sec_timer;
}

# method to print algorithm summary
# inputs:
# - algorithm key
# - number of balls left
# - number of drops (also cost in dollars)
# - algorithm start time
# outputs (printed in tab format on display):
# - algorithm key
# - balls left
# - count of drops (and cost)
# - time in seconds
sub printEntry {
  my ($gkey, $balls, $drops, $start) = @_;
  $gkey = ( $gkey ) ? sprintf "%0.6d", $gkey : '0';
  $balls = ( $balls ) ? $balls : 0;
  $drops = ( $drops ) ? $drops : $maxFloor;
  $start = ( $start ) ? $start : [Time::HiRes::gettimeofday];

  my $sec_timer = Time::HiRes::tv_interval( $start, [Time::HiRes::gettimeofday] );

  $perfReport->{$gkey} = sprintf "%0.6d\t%0.2f\t%0.6d\t%0.6f\n",
    $gkey, $balls, $drops, $sec_timer;
}

sub printTotal {
  print "\nAlgo\tBalls\tDrops\tSeconds\n";
  print "==========================================\n";
  for my $repEntry ( sort keys %{ $perfReport } ) {
    print $perfReport->{$repEntry};
  }
}

# method to drop the ball
# inputs:
# - current $drops
# - current $balls
# - current algorithm key
# outputs:
# - new drop count
# - new ball count
sub dropBall {
  my ( $balls, $drops, $floor ) = @_;
  $balls = ( $balls ) ? $balls : 0;
  $drops = ( $drops ) ? $drops : 0;

  if ( ( $drops <= $maxFloor ) and $balls > 0 ) {
    $drops++;
    $balls-- if ( $floor >= $eggFloor );
  }
  return ( $balls, $drops );

}


# method to calculate the next target floor
# inputs:
# - current floor
# - algorithm (count steps)
# - current $balls
# output:
# - next target floor
sub getNextFloor {
  my ( $balls, $aKey, $aFloor ) = @_;

  my $twoNextFloor = $aFloor + $aKey;
  my $oneNextFloor = $aFloor + 1;
  my $brkNextFloor = $aFloor - $aKey + 1;

  # if balls == 2, choose next floor based on which floor is < max floor
  if ( $balls == 2 and $aFloor < $maxFloor ) {
    if ( $twoNextFloor <= $maxFloor ) {
      return $twoNextFloor;
    } elsif ( $oneNextFloor <= $maxFloor ) {
      return $oneNextFloor;
    }
  } elsif ( $balls == 1 and $aFloor <= $maxFloor ) {
    return $aFloor++;
  }
  return $maxFloor;
}

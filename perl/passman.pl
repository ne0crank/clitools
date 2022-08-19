#!/usr/bin/env perl

=head1 NAME

passman.pl - Perl extension for Passman.pm

=head1 SYNOPSIS


=head1 DESCRIPTION

passman.pl uses the Passman.pm module to manage passwords and keys.

=head2 EXPORT

None by default.

=head1 SEE ALSO

=head1 AUTHOR

Kent schaeffer
kent.schaeffer@five9.com

=head1 MAINTENANCE

Kent Schaeffer
kent.schaeffer@five9.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 by Kent Schaeffer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.34.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

## required modules

use strict;
use warnings;
use Getopt::Long;
Getopt::Long::Configure( "bundling" );

use Data::Dump qw( dump );
use Cwd qw( abs_path );
use File::Basename qw( dirname basename );
use Switch;
use Term::ReadKey;
use List::Util qw( any );

# use Regexp::Common qw(net);
# use Data::Validate::IP;
# use Net::DNS;
# use Net::CIDR;
# use Net::Netmask;

use Passman;


use vars qw {
 $meta $keys $path
};

our $VERSION = '0.01';

$path = &abs_path($0);
$meta = {
  debug => 0,
  help => 0,
  version => 0,
  acts => [ 'get', 'add', 'mod', 'del' ],
  full => $path,
  dir => &dirname($path),
  run => &basename($path),
  mssg => {
    help => 'You requested this help screen',
    error => 'General Error, but I cannot figure out what happened',
    missing => ' is missing - please enter now',
    nodata => 'No data found for ',
    newdata => 'Please enter new ',
    success => 'Successful attempt to ',
    failure => 'Failed attempt to '
  }
};


GetOptions(
  'debug|d'    => \$meta->{debug},   ## show debug output
  'app|a=s'    => \$keys->{appl},
  'user|u=s'   => \$keys->{user},
  'pass|p=s'   => \$keys->{pass},
  'action|c=s' => \$keys->{acts},  ## action = add, del, mod, get (default)
  'file|f=s'   => \$keys->{file},
  'version|v'  => \$meta->{version},
  'help|h'     => \$meta->{help},
  'usage|g'    => \$meta->{help},
);

&usage( $meta->{errs}{help} ) if ( $meta->{help} or $meta->{usage} );
if ( $meta->{version} ) {
  print $meta->{runs} . ' version ' . $VERSION . "\n";
  exit 0;
}

$keys->{acts} = ( defined($keys->{acts}) and any { lc $keys->{acts} } @{ $meta->{acts} } )
  ? lc $keys->{acts} : $meta->{acts}[0];
$keys->{appl} = $keys->{appl} || '';
$keys->{user} = $keys->{user} || '';
$keys->{pass} = $keys->{pass} || '';
$keys->{file} = $keys->{file} || '';

dump $keys, $meta if ( $meta->{debug} );

if ( $keys->{acts} eq 'get' ) {
  $keys->{object} = new Passman;
  $keys->{appl} = $keys->{appl} || &ask_missing( 'app', $meta->{mssg}{missing} );
  $keys->{user} = $keys->{user} || &ask_missing( 'user', $meta->{mssg}{missing} );
  $keys->{pass} = $keys->{object}->getpass( $keys->{appl}, $keys->{user} );
  $keys->{return} = ( length( $keys->{pass} ) > 0 ) ? $meta->{mssg}{success} : $meta->{mssg}{failure};
  printf "%s find this object\nApp: %s\nUser: %s\nPass: %s\n",
      $keys->{return}, $keys->{appl}, $keys->{user}, $keys->{pass};
} elsif ( $keys->{acts} eq 'add' ) {
  $keys->{object} = new Passman;
  $keys->{appl} = $keys->{appl} || &ask_missing( 'app', $meta->{mssg}{missing} );
  $keys->{user} = $keys->{user} || &ask_missing( 'user', $meta->{mssg}{missing} );
  $keys->{pass} = $keys->{pass} || &ask_missing( 'pass', $meta->{mssg}{newdata} . 'password' );
  $keys->{return} = ( $keys->{object}->setpass( $keys->{appl}, $keys->{user} ) )
    ? $meta->{mssg}{success} : $meta->{mssg}{failure};
  printf "%s add this object\nApp: %s\nUser: %s\nPass: %s\n",
      $keys->{return}, $keys->{appl}, $keys->{user}, $keys->{pass};
} elsif ( $keys->{acts} eq 'mod' ) {
  $keys->{object} = new Passman;
  $keys->{appl} = $keys->{appl} || &ask_missing( 'app', $meta->{mssg}{missing} );
  $keys->{user} = $keys->{user} || &ask_missing( 'user', $meta->{mssg}{missing} );
  $keys->{pass} = $keys->{pass} || &ask_missing( 'pass', $meta->{mssg}{newdata} . 'password' );
  $keys->{return} = ( $keys->{object}->resetpass( $keys->{appl}, $keys->{user} ) )
    ? $meta->{mssg}{success} : $meta->{mssg}{failure};
  printf "%s mod this object\nApp: %s\nUser: %s\nPass: %s\n",
      $keys->{return}, $keys->{appl}, $keys->{user}, $keys->{pass};
}



sub ask_missing {
    my ( $object, $phrase ) = @_;
    $object = $object || 'app';
    $phrase = $phrase || $object . $meta->{mssg}{missing};
    ReadMode('noecho') if ( $object eq 'pass' );
    my $accept = '';
    while ( not $accept ) {
      print $phrase . ": ";
      chomp( $accept = <STDIN> );
      $accept = $accept || '';
    }
    ReadMode(0);
    exit 0 if ( $accept and $accept =~ /exit|quit/i );
    return $accept;
}

# $keys->{object} = new Passman;
# $keys->{public} = $keys->{object}->getpass( $keys->{app}, 'public' );
# $keys->{private} = $keys->{object}->getpass( $keys->{app}, 'private' );

# sub get_data {
#   $keys->{object} = new Passman;
#   $keys->{pass} = $keys->{object}->getpass( $keys->{apps}, $keys->{user} );
#   printf "App: %s\nUser: %s\nPass: %\n", $keys->{apps}, $keys->{user}, $keys->{pass};
# }

sub usage {

    @_ and print STDERR "\n @_\n";

    print STDERR <<EOT;

Usage: $meta->{run}
    --apps APP --user USER --pass|-a PASS [--action|-a ACTION] [--file FILE]
    [--debug] || [--version] || [--help]

Options:
  --debug               display debug messages to screen
  --version             display version of script and exit
  --help | -h           display this help screen
  --usage | -u          display this help screen
  --app | -a APP        (required) application to use
  --user | -u USER      (required) user to use
  --pass | -p PASS      (required for add/mod) password to use
  --action | -c ACTION  (optional) action to use
  --file | -f FILE      (optional) data file to use

Notes:
  - user will be prompted for any missing values required
  - valid ACTION (does): add, mod, del, get (default)
  - FILE must be fully qualified path and filename
  - FILE will default to file set in Passman.pm
  - PASS is required for add and mod actions
  - create a link for better access to this script:
    ln -s ~/[repo_folder]/passman.pl ~/bin/passman
  - create a link for better access to the Passman.pm module:
    ln -s ~/[repo_folder]/Passman.pm ~/perl5/lib/perl5/Passman.pm

EOT

    exit 255;
}

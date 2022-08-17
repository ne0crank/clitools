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
use Data::Dump qw(dump);
use Cwd qw(abs_path);
use Switch;

# use Regexp::Common qw(net);
# use Data::Validate::IP;
# use Net::DNS;
# use Net::CIDR;
# use Net::Netmask;

use Passman;


use vars qw {
 $meta $opts $keys
};

our $VERSION = '0.01';

$meta->{does} = 'get';
$meta->{runs} = &abs_path($0);
$meta->{errs} = {
  help => 'You requested this help screen',
  error => 'General Error, but I cannot figure out what happened',
  missing => 'Options APP and USER are missing'
};

$opts = {};
GetOptions(
  $opts,
  'debug',   ## show debug output
  'apps=s'  => \$meta->{apps},
  'user=s'  => \$meta->{user},
  'pass=s'  => \$meta->{pass},
  'does=s'  => \$meta->{does},  ## action = add, del, mod, get (default)
  'file=s'  => \$meta->{file},
  'version'
);

( $opts->{debug} ) and dump %$meta, %$keys, %$opts;

&usage( $meta->{errs}{help} ) if ( $opts->{help} );
if ( $opts->{version} ) {
  print $meta->{runs} . ' version ' . $VERSION . "\n";
  exit 0;
}
&usage( "Error: ", $meta->{errs}{missing} )
  unless ( defined $opts->{apps} or defined $opts->{user} );

$keys->{apps} = ( $opts->{apps} ) ? $opts->{apps} : $meta->{apps};
$keys->{user} = ( $opts->{user} ) ? $opts->{user} : $meta->{user};
$keys->{pass} = ( $opts->{pass} ) ? $opts->{pass} : $meta->{pass};
$keys->{does} = ( $opts->{does} ) ? $opts->{does} : $meta->{does};
$keys->{file} = ( $opts->{file} ) ? $opts->{file} : $meta->{file};

switch( $keys->{does} ) {
  case 'get' {
    $keys->{object} = new Passman;
    $keys->{pass} = $keys->{object}->getpass( $keys->{apps}, $keys->{user} );
    if ( $keys->{pass} ) {
      printf "App: %s\nUser: %s\nPass: %\n", $keys->{apps}, $keys->{user}, $keys->{pass};
    } else {
      printf "no password found for App: %s and User: %s\n", $keys->{apps}, $keys->{user};
    }
  }
}

$keys->{object} = new Passman;
$keys->{public} = $keys->{object}->getpass( $keys->{app}, 'public' );
$keys->{private} = $keys->{object}->getpass( $keys->{app}, 'private' );

sub get_data {
  $keys->{object} = new Passman;
  $keys->{pass} = $keys->{object}->getpass( $keys->{apps}, $keys->{user} );
  printf "App: %s\nUser: %s\nPass: %\n", $keys->{apps}, $keys->{user}, $keys->{pass};
}

sub usage {

    @_ and print STDERR "\n @_\n";

    print STDERR <<EOT;

Usage: $meta->{runs}
    --apps APP --user USER --pass PASS [--does ACTION] [--file FILE]
    [--debug] || [--version] || [--help]

Options:
  --debug             display debug messages to screen
  --help              display this help screen
  --version           display version of script and this help screen
  --apps | -a APP     (required) application to use
  --user | -u USER    (required) user to use
  --pass | -p PASS    (required for add/mod) password to use
  --does | -d ACTION  (optional) action to use
  --file | -f FILE    (optional) data file to use

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

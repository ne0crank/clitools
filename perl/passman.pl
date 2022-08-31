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
ne0crank@icloud.com

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
<<<<<<< Updated upstream
Getopt::Long::Configure( "bundling", "ignorecase_always" );
=======
Getopt::Long::Configure( "bundling" );
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
 $opts $meta $keys $path
=======
 $meta $keys $path
>>>>>>> Stashed changes
};

our $VERSION = '0.01';

$path = &abs_path($0);
$meta = {
<<<<<<< Updated upstream
=======
  debug => 0,
  help => 0,
  version => 0,
>>>>>>> Stashed changes
  acts => [ 'get', 'add', 'mod', 'del' ],
  full => $path,
  dir => &dirname($path),
  run => &basename($path),
  mssg => {
    help => 'You requested this help screen',
    error => 'General Error, but I cannot figure out what happened',
<<<<<<< Updated upstream
    nodata => 'No data found for ',
    newdata => 'Please enter new ',
    success => 'Successful attempt to ',
    failure => 'Failed attempt to ',
    exist => 'Password already exists for ',
    differ => 'Password differs for ',
    nopass => 'No password found for ',
    addnow => 'do you want to add it now? (y|n) ',
    newold => 'Is this the new or old password? (n|o) '
  },
  good => {
    bool => [ 'y', 'n', 1, 0, 'yes', 'no' ],
    nope => [ 'n', 'o', 'new', 'old' ],
    quit => [ 'q', 'e', 'b', 'bye', 'exit', 'quit' ]
=======
    missing => ' is missing - please enter now',
    nodata => 'No data found for ',
    newdata => 'Please enter new ',
    success => 'Successful attempt to ',
    failure => 'Failed attempt to '
>>>>>>> Stashed changes
  }
};


GetOptions(
<<<<<<< Updated upstream
  $opts,
  'version|v'     => \$opts->{version},
  'help|usage|h'  => \$opts->{help},
  'quiet|q'       => \&set_quiet,
  'verbose|b'     => \$opts->{verbose},
  'debug|d'       => \$opts->{debug},   ## show debug output
  'app|a=s'       => \$keys->{appl},
  'user|u=s'      => \$keys->{user},
  'pass|p=s'      => \$keys->{pass},
  'action|c=s'    => \$keys->{acts},  ## action = add, del, mod, get (default)
  'file|f=s'      => \$keys->{file},
);

&usage( 'No options provided' ) if (
  not $opts->{version} and not $opts->{help} and not $opts->{quiet}
  and not $opts->{verbose} and not $opts->{debug}
  and not $keys->{appl} and not $keys->{user} and not $keys->{pass}
  and not $keys->{acts} and not $keys->{file} );

&usage( $meta->{mssg}{help} ) if ( $opts->{help} );

if ( $opts->{version} ) {
  print $meta->{run} . ' version ' . $VERSION . "\n";
  exit 0;
}

$keys->{acts} = ( $keys->{acts} and any { lc $keys->{acts} } @{ $meta->{acts} } )
  ? lc $keys->{acts} : $meta->{acts}[0];

$keys->{object} = Passman->new();
$keys->{appl} = $keys->{appl} || &askMissing( 'app', $meta->{mssg}{newdata} );
$keys->{user} = $keys->{user} || &askMissing( 'user', $meta->{mssg}{newdata} );
$keys->{pass} = $keys->{pass} || undef;
$keys->{file} = ( $keys->{file} and -e $keys->{file} ) ? $keys->{file} : undef;

dump $keys, $meta, $opts if ( $opts->{debug} );

if ( $keys->{acts} eq 'del' ) {
  $keys->{return} = $keys->{object}->delPassword( $keys->{appl}, $keys->{user} );
  if ( $opts->{quiet} ) {
    printf "%s", $keys->{return};
  } else {
    printf "\nDelete password - result: %s\nApp: %s\nUser: %s\n",
      $keys->{return}, $keys->{appl}, $keys->{user};
  }
} elsif ( $keys->{acts} eq 'add' ) {
  $keys->{pass} = $keys->{pass} || &askMissing( 'pass', $meta->{mssg}{newdata} . 'password' );
  $keys->{return} = $keys->{object}->addPassword( $keys->{appl}, $keys->{user}, $keys->{pass} );
  if ( $keys->{return} ) {
    $keys->{return} = ( length $keys->{return} < 2 )
      ? sprintf "%s%s and matches", $meta->{mssg}{exist}, $keys->{user}
      : $keys->{return};
  } else {
    $keys->{return} = sprintf "%s%s and does not match", $meta->{mssg}{exist}, $keys->{user};
  }
  if ( $opts->{quiet} ) {
    printf "%s", $keys->{return};
  } else {
    printf "\nAdd new password - result: %s\nApp: %s\nUser: %s\nPass: %s\n",
      $keys->{return}, $keys->{appl}, $keys->{user}, $keys->{pass};
  }
} elsif ( $keys->{acts} eq 'mod' ) {
  if ( $keys->{pass} ) {
    $keys->{newold} = &askAny( 'pass', $meta->{mssg}{newold}, $meta->{good}{nope}  );
    if ( $keys->{newold} =~ /^o/i ) {
      $keys->{oldpass} = $keys->{pass};
      $keys->{newpass} = &AskMissing( 'pass', $meta->{mssg}{newdata} . 'new password' );
    } elsif ( $keys->{newold} =~ /^n/i ) {
      $keys->{newpass} = $keys->{pass};
      $keys->{oldpass} = &askMissing( 'pass', $meta->{mssg}{newdata} . 'current password' );
    }
  }
  $keys->{oldpass} = $keys->{oldpass} || &askMissing( 'pass', $meta->{mssg}{newdata} . 'current password' );
  $keys->{newpass} = $keys->{newpass} || &askMissing( 'pass', $meta->{mssg}{newdata} . 'new password' );
  $keys->{return} = $keys->{object}->modPassword( $keys->{appl}, $keys->{user},
    $keys->{oldpass}, $keys->{newpass} );
  if ( $keys->{return} eq 'different' ) {
    $keys->{return} = sprintf "%s%s", $meta->{mssg}{differ}, $keys->{user};
  } elsif ( $keys->{return} eq 'none' or length $keys->{return} < 1 ) {
    $keys->{return} = sprintf "%s%s", $meta->{mssg}{nopass}, $keys->{user};
    $keys->{addnow} = &askAny( 'pass', $meta->{mssg}{addnow}, $meta->{good}{bool} );
    if ( $keys->{addnow} =~ /^y/i ) {
      $keys->{pass} = &askMissing( 'pass', $meta->{mssg}{newdata} . 'password' );
      $keys->{return} = $keys->{object}->addPassword( $keys->{appl}, $keys->{user}, $keys->{pass} );
      if ( $keys->{return} ) {
        $keys->{return} = sprintf "%s%s", $meta->{mssg}{exist}, $keys->{user};
      } else {
        $keys->{return} = sprintf "%s%s", $meta->{mssg}{nodata}, $keys->{user};
      }
      if ( $opts->{quiet} ) {
        printf "%s", $keys->{return};
      } else {
        printf "\nAdd new password - result: \n%s\nApp: %s\nUser: %s\nPass: %s\n",
          $keys->{return}, $keys->{appl}, $keys->{user}, $keys->{pass};
      }
    } else {
      $keys->{return} = sprintf "%s%s", $meta->{mssg}{nodata}, $keys->{user};
      if ( $opts->{quiet} ) {
        printf "%s", $keys->{return};
      } else {
        printf "\nModify password - result: \n%s\nApp: %s\nUser: %s\nPass: %s\n",
          $keys->{return}, $keys->{appl}, $keys->{user}, $keys->{pass};
      }
    }
  }
} else { ## assuming 'get' action
  $keys->{pass} = $keys->{object}->getPassword( $keys->{appl}, $keys->{user} );
  $keys->{pass} =
    ( $keys->{pass} and length $keys->{pass} > 1 and $keys->{pass} !~ /^HASH/ )
    ? $keys->{pass}
    : sprintf "%s%s", $meta->{mssg}{nodata}, $keys->{user};
  if ( $opts->{quiet} ) {
    printf "%s", $keys->{pass};
  } else {
    printf "\nRead password - result: %s\nApp: %s\nUser: %s\nPass: %s\n",
      $keys->{pass}, $keys->{appl}, $keys->{user}, $keys->{pass};
  }
}



sub askAny {
    my ( $object, $phrase, $accept ) = @_;
    $object = $object || 'pass';
    $phrase = $phrase || $meta->{mssg}{newdata} . $object;
    my $response = '';
    while ( not any { lc $response } @{ $accept } ) {
      print $phrase . ": ";
      chomp( $response = <STDIN> );
      $response = $response || '';
      exit 0 if ( $response and any { lc $response } @{ $meta->{good}{quit} } );
    }
    ReadMode(0);
    return $response;
}

sub askMissing {
    my ( $object, $phrase ) = @_;
    $object = $object || 'pass';
    $phrase = $phrase || $meta->{mssg}{newdata} . $object;
    ReadMode('noecho') if ( $object eq 'pass' );
    my $response = '5';
    while ( $response ne '' ) {
      print $phrase . ": ";
      chomp( $response = <STDIN> );
      $response = $response || '5';
      exit 0 if ( $response and any { lc $response } @{ $meta->{good}{quit} } );
    }
    ReadMode(0);
    return $response;
}

sub setQuiet {
  $opts->{quiet} = 1;
  $opts->{verbose} = 0;
  $opts->{debug} = 0;
=======
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
    return $accept;
>>>>>>> Stashed changes
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

  print STDERR "\n@_\n" if ( @_ );

  print STDERR <<EOT;

Usage: $meta->{run}
    --apps APP --user USER --pass|-a PASS [--action|-a ACTION] [--file FILE]
    [--debug] || [--version] || [--help]

Options:
<<<<<<< Updated upstream
  --help|usage  | -h           display this help screen
  --version     | -v           display version of script and exit
  --quiet       | -q           display less output to screen
  --verbose     | -b           display more output to screen
  --debug       | -d           display debug messages to screen
  --app         | -a APP       (required) application to use
  --user        | -u USER      (required) user to use
  --pass        | -p PASS      (required for add/mod) password to use
  --action      | -c ACTION    (optional) action to use
  --file        | -f FILE      (optional) data file to use
=======
  --debug               display debug messages to screen
  --version             display version of script and exit
  --help | -h           display this help screen
  --usage | -u          display this help screen
  --app | -a APP        (required) application to use
  --user | -u USER      (required) user to use
  --pass | -p PASS      (required for add/mod) password to use
  --action | -c ACTION  (optional) action to use
  --file | -f FILE      (optional) data file to use
>>>>>>> Stashed changes

Notes:
  - user will be prompted for any missing values required
  - valid ACTION: add, mod, del, get (default)
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

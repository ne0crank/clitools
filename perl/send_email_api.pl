#!/usr/bin/env perl

=head1 NAME

send_email_api.pl - Perl extension for MailJet smtp api

=head1 SYNOPSIS


=head1 DESCRIPTION

send_email_api uses the MailJet api to send email via the five9.com domain and keys.

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
use Date::Calc qw(:all);
use Data::Dump qw(dump);

# use Regexp::Common qw(net);
# use Data::Validate::IP;
# use Net::DNS;
# use Net::CIDR;
# use Net::Netmask;

use IO::All;
use JSON::XS ();
use Term::ReadKey;
use Time::HiRes qw( gettimeofday tv_interval );
use List::Util qw(any);
use HTTP::Cookies;
use LWP::UserAgent;
use HTTP::Request;
use URI::Escape;
use Passman;
use File::Basename;
use Socket qw( inet_aton );

use vars qw {
  $timer $meta $opts $mail $keys
};

our $VERSION = '0.02';

$timer->{start} = [Time::HiRes::gettimeofday];

$keys->{object} = new Passman;
$keys->{app} = 'mailjet';
$keys->{public} = $keys->{object}->getpass( $keys->{app}, 'public' );
$keys->{private} = $keys->{object}->getpass( $keys->{app}, 'private' );

$meta = {
  mail => {
    normal => {
      email => 'five9.report@five9.com',
      name  => 'Five9 Reports'
    },
    error => {
      email => 'ps_custom_report_tech@five9.com',
      name  => 'Five9 Custom Report Team'
    }
  },
  user => {
    'public' => $keys->{public},
    'private' => $keys->{private}
  },
  subject => 'Five9 Custom Report',
  format => 'text'
};

$opts = {};
GetOptions(
  $opts,
  'debug',   ## show debug output
  'keys=s@'         => \$mail->{user},
  'sender=s%'       => \$mail->{sender},
  'recipients=s@'   => \$mail->{recipients},
  'subject=s'       => \$mail->{subject},
  'message=s'       => \$mail->{message},
  'format=s'        => \$mail->{format},  ## text or html
  'attach=s@'       => \$mail->{attach}
);

$mail->{sender} = ( $opts->{sender} ) ? $opts->{sender} : $meta->{mail}{normal};
$mail->{recipients} = ( $opts->{recipients} ) ? $opts->{recipients} : $meta->{mail}{normal};
$mail->{subject} = ( $opts->{subject} ) ? $opts->{subject} : $meta->{mail}{subject};
$mail->{message} = ( $opts->{message} ) ? $opts->{message} : $meta->{mail}{subject};
$mail->{format} = ( $opts->{format} ) ? $opts->{format} : $meta->{mail}{format};
$mail->{attach} = ( $opts->{attach} ) ? $opts->{attach} : '';

( $opts->{debug} ) and dump %$mail, %$opts;

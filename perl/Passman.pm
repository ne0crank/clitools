package Passman;

=head1 NAME

Passman - Perl extension for passman library

=head1 SYNOPSIS

  use Passman;
  my $pass_obj = new Passman;
  my $pass_app = 'ddi';
  my $svc_user = 'some_service_account';
  my $svc_pass = $pass_obj->getpass( $pass_app, $svc_user );

=head1 DESCRIPTION

Passman is a core library for storing credentials in an encrypted format
for use in perl scripts. This module handles encryption and deencryption of the
credentials.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Patrick Piper

=head1 MAINTENANCE

Kent Schaeffer
kent.schaeffer@five9.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Patrick Piper

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

# required modules
use strict;
use warnings;

use IO::All;
use JSON::XS ();
use MIME::Base64;
use Crypt::CBC;
use Crypt::Cipher::AES;
use Term::ReadKey;

our $VERSION = '0.02';

my $user;
my $passman_file = '/opt/five9/scripts/f9pcr/modules/F9PCR/Config/.passman';
my $cryptkey     = 'humptydumptysatonawallandhadagreatfallandthequeendidnothelpatall';
my $ivector      = '0123456789123456';

sub new {
	my $class = shift;
	return bless {}, $class;
}


sub _readall {
	my $data;

	return {} unless -e $passman_file;
	$data < io($passman_file);
	return JSON::XS::decode_json $data;
}

sub _writeall {
	my ( $self, $data ) = @_;

    #
    # hack to remove line feeds - hope it doesn't mess with Node library.
    foreach my $key (keys %{$data} ) {
    	chomp $data->{$key};
    }
	my $x = JSON::XS::encode_json($data);
	$x > io($passman_file);
}

sub _get_user {
    my ( $self, $xuser, $xenvi ) = @_;
    $xuser = ( $xuser ) ? $xuser : $user->{uix};
    $xenvi = ( $xenvi ) ? $xenvi : 'ddi';
    my $accept = '';
    while ( not $accept ) {
        my $user_prompt = $self->_prompt_user( "\nEnter $xuser ID for $xenvi", "$user->{uix}", "text" );
        $accept = ( $user_prompt ) ? $user_prompt : $user->{uix};
    }
	exit 0 if ( $accept and $accept =~ /exit|quit/i );
    return $accept;
}

# function TO PROMPT FOR PASSWORD
sub _get_pass {
    my ( $self, $xuser, $xenvi, $cause ) = @_;
    $xenvi = ( $xenvi ) ? $xenvi : 'ddi';
    my $accept = '';
    while ( not $accept ) {
        my $user_prompt = $self->_prompt_user( "\n$cause $xuser passcode for $xenvi", "", "pass" );
        $accept = ( $user_prompt ) ? $user_prompt : '';
    }
	exit 0 if ( $accept and $accept =~ /exit|quit/i );
    return $accept;
}


# function TO PROMPT FOR SOME INFO
sub _prompt_user {
    my ( $prompt, $default, $type ) = @_;
    my $defaultValue = $default ? "[$default]" : "";

    my $quest = '';
    if ( not $type or $type and $type =~ /^text$/i ) {
        print "$prompt $defaultValue: ";
        chomp( $quest = <STDIN> );
    } elsif ( $type and $type =~ /^pass$/i ) {
        print "$prompt $defaultValue: ";
        ReadMode('noecho');
        chomp( $quest = <STDIN> );
        ReadMode(0);
    }
    exit 0 if ( $quest and $quest =~ /exit|quit/i );
    return $quest ? $quest : $default;
}

sub encrypt {
	my ( $self, $s ) = @_;

	my $cipher = Crypt::CBC->new(
		-key         => $cryptkey,
		-cipher      => 'Cipher::AES',
		-iv          => $ivector,
		-literal_key => 1,
		-header      => "none",
		-keysize     => 32
	);
	return MIME::Base64::encode_base64( $cipher->encrypt($s) );
}

sub decrypt {
	my ( $self, $s ) = @_;

	my $cipher = Crypt::CBC->new(
		-key         => $cryptkey,
		-cipher      => 'Cipher::AES',
		-iv          => $ivector,
		-literal_key => 1,
		-header      => "none",
		-keysize     => 64
	);
	return $cipher->decrypt( MIME::Base64::decode_base64($s) );
}

sub setpass {
	my ( $self, $app_id, $userid, $password ) = @_;

	my $data = $self->_readall;
	$app_id = $self->_get_app() unless ( $app_id );
	$userid = $self->_get_user( $app_id ) unless ( $userid );
	$data->{ $app_id . '/' . $userid } = $self->encrypt($password);
	$self->_writeall($data);
}

sub resetpass {
	my ( $self, $app_id, $userid ) = @_;

	# Not implemented yet
	$app_id = $self->_get_app() unless ( $app_id );
	$userid = $self->_get_user( $app_id ) unless ( $userid );
    my $p1 = $self->_get_pass( $userid, $app_id, 'Enter' );
    my $p2 = $self->_get_pass( $userid, $app_id, 'Verify' );
    if ( $p1 ne $p2 ) {
    	die "Passwords not the same, please try again!";
    } else {
		my $data = $self->_readall;
		$data->{ $app_id . '/' . $userid } = $self->encrypt($p2);
		$self->_writeall($data);
    }
}

sub getpass {
	my ( $self, $app, $userid ) = @_;

	my $data = $self->_readall;
	return $self->decrypt( $data->{ $app . '/' . $userid } );
}

1;
__END__

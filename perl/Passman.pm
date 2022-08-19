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

Kent schaeffer

=head1 MAINTENANCE

Kent Schaeffer
kent.schaeffer@five9.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 Kent Schaeffer, ne0crank

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.34.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

# required modules
use strict;
use warnings;

use IO::All;
use JSON::XS ();
use MIME::Base64;
use Crypt::Argon2 qw( argon2id_pass argon2id_verify );
use Crypt::URandom qw( urandom );
use Term::ReadKey;

our $VERSION = '0.03';

# my $user;
# my $passman_file = '/opt/five9/scripts/f9pcr/modules/F9PCR/Config/.passman';
# my $cryptkey     = 'humptydumptysatonawallandhadagreatfallandthequeendidnothelpatall';
# my $ivector      = '0123456789123456';

my $helper = {
	salt => urandom(16),
	cost => 4,
	fact => '128M',
	para => 4,
	tags => 32,
	file => '~/.passman'
};

sub new {
	my $class = shift;
	my $self = {
		_passfile => shift,
		_application => shift,
		_username => shift,
	};
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


sub _encrypt {
	my ( $self, $pwd ) = @_;
  my $encoded = &argon2id_pass( $pwd, $helper->{salt}, $helper->{cost},
	    $helper->{fact}, $helper->{para}, $helper->{tags} );
	return $encoded || $pwd;
}

sub _decrypt {
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
	return $self->_decrypt( $data->{ $app . '/' . $userid } );
}

1;
__END__

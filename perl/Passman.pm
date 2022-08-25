package Passman;

=head1 NAME

Passman - Perl extension for passman library

=head1 SYNOPSIS

  use Passman;
  my $pass_obj = new Passman(optional_password_file);
  my $pass_app = 'some_application';
  my $svc_user = 'some_service_account';
  my $svc_pass = $pass_obj->getPass( $pass_app, $svc_user );

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

use IO::All -utf8;
use JSON::XS qw( encode_json decode_json );
use MIME::Base64 qw( encode_base64 decode_base64 );
## use Crypt::Rijndael;
use Crypt::CBC;
## use Crypt::Cipher::AES;
## use Term::ReadKey;
use Data::Dump qw( dump );

our $VERSION = '0.03';
our $DEBUG   = 1;

my $passman_file = '/opt/five9/scripts/f9pcr/modules/F9PCR/Config/.passman';
my $cryptkey     = 'humptydumptysatonawallagreatfall';
my $cipher       = Crypt::CBC->new(
	-cipher => 'Rijndael',
	-key    => $cryptkey,
	-pbkdf  => 'pbkdf2',
);


sub new {
	my ( $class ) = shift;
	my $self = {
		_passfile => shift || $passman_file,
		_cipher   => '',
		_cryptkey => '',
	};
	dump 'Passman.pm new class', $self if ( $DEBUG );
	return bless $self, $class;
}


sub _readAll {
	## my $data;
	my ( $self ) = @_;
	## $self->_cipher->set_iv( $ivector );
	dump $self if ( $DEBUG );
	system( "touch $self->{_passfile}" ) if ( not -e $self->{_passfile} );
	return {} if ( -s $self->{_passfile} );
	## $self->{_passfile} = $self->{_passfile} || $passman_file;
	return decode_json( io->file( $self->{_passfile} )->all );
	## $data < io($passman_file);
	## my $fileHash < io $self->{_passfile};
  ## dump $fileHash if $DEBUG;
	## return decode_json $fileHash;
}

sub _writeAll {
	my ( $self, $data ) = @_;
	#
  #   #
  #   # hack to remove line feeds - hope it doesn't mess with Node library.
  #   foreach my $key (keys %{$data} ) {
  #   	chomp $data->{$key};
  #   }
	# my $x = JSON::XS::encode_json($data);
	# $x > io($passman_file);
	dump $data if ( $DEBUG );
	$self->{_passfile} = $self->{_passfile} || $passman_file;
  return io( $self->{_passfile} )->print( encode_json( $data ) );
}



# # function TO PROMPT FOR SOME INFO
# sub _prompt_user {
#     my ( $prompt, $default, $type ) = @_;
#     my $defaultValue = $default ? "[$default]" : "";
#
#     my $quest = '';
#     if ( not $type or $type and $type =~ /^text$/i ) {
#         print "$prompt $defaultValue: ";
#         chomp( $quest = <STDIN> );
#     } elsif ( $type and $type =~ /^pass$/i ) {
#         print "$prompt $defaultValue: ";
#         ReadMode('noecho');
#         chomp( $quest = <STDIN> );
#         ReadMode(0);
#     }
#     exit 0 if ( $quest and $quest =~ /exit|quit/i );
#     return $quest ? $quest : $default;
# }

# sub _generate {
# 	my ( $self, $password ) = @_;
# 	my $salt = $self->_generateSalt();
# 	my $iterations = $self->_hashconf->{iterations};
# 	for (1 .. $iterations) {
# 		$password = hashing( "${salt}${password}" );
# 	}
# 	return $salt . ':' . $iterations . ':' . $password;
# }
#
# sub _validate {
# 	my ( $self, $password, $hash ) = @_;
# 	my ( $salt, $iterations ) = split /:/, $hash;
# 	my $generated = $self->_generate( $password, $salt, $iterations );
# 	return $hash eq $generated;
# }

sub _encrypt {
	# my ( $self, $object ) = @_;
	#
	# my $cipher = Crypt::CBC->new(
	# 	-key         => $cryptkey,
	# 	-cipher      => 'Cipher::AES',
	# 	-iv          => $ivector,
	# 	-literal_key => 1,
	# 	-header      => "none",
	# 	-keysize     => 32
	# );
	# return MIME::Base64::encode_base64( $cipher->encrypt( $object ) );
  my ( $self, $decrypted ) = @_;
	$self->{_cryptkey} = $self->{_cryptkey} || $cryptkey;
  $self->{_cipher} = $cipher || Crypt::CBC->new(
		-cipher => 'Rijndael',
		-key    => $self->{_cryptkey},
		-pbkdf  => 'pbkdf2',
	);
	return encode_base64( $self->{_cipher}->encrypt( $decrypted ) );
	# $self->{_ivector} = $self->{_ivector} || $ivector;
	# $self->{_cryptkey} = $self->{_cryptkey} || $cryptkey;
	# $self->{_cipher} = $self->{_cipher} ||
	#   Crypt::Rijndael->new( $self->{_cryptkey}, Crypt::Rijndael::MODE_CBC() );
	# $self->{_cipher}->set_iv( $self->{_ivector} );
	# return ( $decrypted )
	#   ? MIME::Base64::encode_base64( $self->{_cipher}->encrypt( $decrypted ) )
	# 	: {};
}

sub _decrypt {
	# my ( $self, $object ) = @_;
	#
	# my $cipher = Crypt::CBC->new(
	# 	-key         => $cryptkey,
	# 	-cipher      => 'Cipher::AES',
	# 	-iv          => $ivector,
	# 	-literal_key => 1,
	# 	-header      => "none",
	# 	-keysize     => 32
	# );
	# return $cipher->decrypt( MIME::Base64::decode_base64( $object ) );
  my ( $self, $crypted ) = @_;
	$self->{_cryptkey} = $self->{_cryptkey} || $cryptkey;
  $self->{_cipher} = $cipher || Crypt::CBC->new(
		-cipher => 'Rijndael',
		-key    => $self->{_cryptkey},
    -pbkdf  => 'pbkdf2',
	);
	return $self->{_cipher}->decrypt( decode_base64( $crypted ) );

	# $self->{_ivector} = $self->{_ivector} || $ivector;
	# $self->{_cryptkey} = $self->{_cryptkey} || $cryptkey;
	# $self->{_cipher} = $self->{_cipher} ||
	#   Crypt::Rijndael->new( $self->{_cryptkey}, Crypt::Rijndael::MODE_CBC() );
	# $self->{_cipher}->set_iv( $self->{_ivector} );
	# return ( $crypted )
	#   ? $self->{_cipher}->decrypt( MIME::Base64::decode_base64( $crypted ) )
	# 	: {};
}

sub _validate {
	my ( $self, $decrypt, $encrypt ) = @_;
	my $encrypted = $self->_encrypt( $decrypt );
	return $encrypt eq $encrypted;
}

sub _getApplication {
	my ( $self, $appl ) = @_;
	my $all_apps = $self->_readAll;
	dump $all_apps if ( $DEBUG );
	return $all_apps->{ $appl };
}

sub _getUser {
  #   my ( $self, $xuser, $xenvi ) = @_;
  #   $xuser = ( $xuser ) ? $xuser : $user->{uix};
  #   $xenvi = ( $xenvi ) ? $xenvi : 'ddi';
  #   my $accept = '';
  #   while ( not $accept ) {
  #       my $user_prompt = $self->_prompt_user( "\nEnter $xuser ID for $xenvi", "$user->{uix}", "text" );
  #       $accept = ( $user_prompt ) ? $user_prompt : $user->{uix};
  #   }
	# exit 0 if ( $accept and $accept =~ /exit|quit/i );
  #   return $accept;
	my ( $self, $appl, $user ) = @_;
	dump 'Passman.pm _getUser', $self, $appl, $user if ( $DEBUG );
	my $valid_app = $self->_getApplication( $appl, $user );
	return $valid_app->{ $user };
}

# function TO PROMPT FOR PASSWORD
sub getPassword {
  #   my ( $self, $xuser, $xenvi, $cause ) = @_;
  #   $xenvi = ( $xenvi ) ? $xenvi : 'ddi';
  #   my $accept = '';
  #   while ( not $accept ) {
  #       my $user_prompt = $self->_prompt_user( "\n$cause $xuser passcode for $xenvi", "", "pass" );
  #       $accept = ( $user_prompt ) ? $user_prompt : '';
  #   }
	# exit 0 if ( $accept and $accept =~ /exit|quit/i );
  #   return $accept;
	my ( $self, $appl, $user ) = @_;
	my $valid_user = $self->_getUser( $appl, $user );
	return $self->_decrypt( $valid_user->{ pass } );
}

sub addPassword {
	# my ( $self, $app_id, $userid, $password ) = @_;
	#
	# my $data = $self->_readall;
	# $app_id = $self->_get_app() unless ( $app_id );
	# $userid = $self->_get_user( $app_id ) unless ( $userid );
	# $data->{ $app_id . '/' . $userid } = $self->encrypt($password);
	my ( $self, $appl, $user, $pass ) = @_;
  my $exist_user = $self->_getUser( $appl, $user );
	dump 'Passman.pm add password1', $appl, $user, $pass, $exist_user, $self if ( $DEBUG );
  return $self->_validate( $pass, $exist_user->{pass} )
	  if ( $exist_user );
  my $data = $self->_readAll();
	my $encrypt = $self->_encrypt( $pass );
	$data->{ $appl }{ $user }{pass} = $encrypt;
	dump 'Passman.pm add password2', $data, $self if ( $DEBUG );
	$self->_writeAll( $data );
	return $encrypt;
}

sub modPassword {
	# my ( $self, $app_id, $userid ) = @_;
	#
	# # Not implemented yet
	# $app_id = $self->_get_app() unless ( $app_id );
	# $userid = $self->_get_user( $app_id ) unless ( $userid );
  #   my $p1 = $self->_get_pass( $userid, $app_id, 'Enter' );
  #   my $p2 = $self->_get_pass( $userid, $app_id, 'Verify' );
  #   if ( $p1 ne $p2 ) {
  #   	die "Passwords not the same, please try again!";
  #   } else {
	# 	my $data = $self->_readall;
	# 	$data->{ $app_id . '/' . $userid } = $self->encrypt($p2);
	# 	$self->_writeall($data);
  #   }
  my ( $self, $appl, $user, $old_pass, $new_pass ) = @_;
	my $data = $self->_readAll();
	if ( $data->{ $appl }{ $user } ) {
		if ( $self->_validate( $old_pass, $data->{ $appl }{ $user }{pass} ) ) {
			my $encrypt = $self->_encrypt( $new_pass );
			$data->{ $appl }{ $user }{pass} = $encrypt;
			$self->_writeAll( $data );
			return $encrypt;
		} else {
			return 'different';
		}
	} else {
		return 'none';
	}
}

sub delPassword {
  my ( $self, $appl, $user ) = @_;
	my $data = $self->_readAll();
	if ( $data->{ $appl }{ $user } ) {
		delete $data->{ $appl }{ $user};
		$self->_writeAll( $data );
		return 'deleted';
	} else {
		return 'not found';
	}
}

1;
__END__

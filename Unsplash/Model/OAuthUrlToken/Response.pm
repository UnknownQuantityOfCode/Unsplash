package Unsplash::Model::OAuthUrlToken::Response;

use parent 'Unsplash::Model';
use DateTime;

my $oauthendpoint = "https://unsplash.com/oauth/token";

sub fields {
	my $self = shift;
	return {
		access_token => {
			required => 1
		},
		token_type => {
			required => 1
		},
		scope => {
			required => 1
		},
		created_at => {
			required => 1
		}
	};
}

sub created {
	my $self = shift;
	return ($self->{created_at}) ? DateTime->from_epoch( epoch => $self->{created_at} ) : undef;
}

1;

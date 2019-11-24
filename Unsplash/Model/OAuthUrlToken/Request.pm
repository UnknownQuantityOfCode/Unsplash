package Unsplash::Model::OAuthUrlToken::Request;

use parent 'Unsplash::Model';

our $oauthendpoint = "https://unsplash.com/oauth/token";

sub fields {
	my $self = shift;
	return {
		client_id => {
			required => 1,
		},
		client_secret => {
			required => 1,
		},
		redirect_uri => {
			required => 1,
		},
		code => {
			required => 1,
		},
		grant_type => {
			required => 1,
			default => 'authorization_code',
			validate => '^authorization_code$'
		}
	};
}

1;

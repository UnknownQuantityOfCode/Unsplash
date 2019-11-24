package Unsplash::Model::OAuthUrlAuthorize::Builder;

use parent 'Unsplash::Model';

my $oauthendpoint = "https://unsplash.com/oauth/authorize";

sub fields {
	my $self = shift;
	return {
		client_id => {
			required => 1,
		},
		redirect_uri => {
			required => 1,
		},
		response_type => {
			required => 1,
			default => 'code'
		},
		scope => {
			required => 1,
			transform => sub {
				my $scope = shift;
				if($scope eq ':all'){
					return 'public+read_user+write_user+read_photos+write_photos+write_likes+write_followers+read_collections+write_collections';
				}elsif($scope eq ':read'){
					return 'public+read_user+read_photos+read_collections';
				}
				return $scope;
			}
		}
	};
}

sub oauth_link {
	my $self = shift;
	my @params;
	foreach my $f (sort keys %{$self->fields()}){
		push @params, "$f=".$self->{$f};
	}
	return $oauthendpoint."?".join('&', @params);
}

1;

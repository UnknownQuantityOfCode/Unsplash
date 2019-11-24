package Unsplash::Model::User::Update;

use parent 'Unsplash::Model';

sub fields {
	my $self = shift;
	return {
		username => {

		},
		first_name => {

		},
		last_name => {

		},
		email => {

		},
		url => {

		},
		location => {

		},
		bio => {

		},
		instagram_username => {

		}
	};
}

1;

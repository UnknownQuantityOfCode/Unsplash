package Unsplash::Model::Generic::Link;

use parent 'Unsplash::Model';

sub fields {
	my $self = shift;
	return {
		url => {
			required => 1
		}
	};
}

1;

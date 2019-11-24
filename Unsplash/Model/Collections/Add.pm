package Unsplash::Model::Collections::Add;

use parent 'Unsplash::Model';

sub fields {
	my $self = shift;
	return {
		collection_id => {
			required => 1
		},
		photo_id => {
			required => 1
		},
	};
}

1;

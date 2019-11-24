package Unsplash::Model::Collections::Remove;

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

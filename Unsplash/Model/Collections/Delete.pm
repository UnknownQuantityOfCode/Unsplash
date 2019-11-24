package Unsplash::Model::Collections::Delete;

use parent 'Unsplash::Model';

sub fields {
	my $self = shift;
	return {
		id => {
			required => 1
		}
	};
}

1;

package Unsplash::Model::Collections::Update;

use parent 'Unsplash::Model';

sub fields {
	my $self = shift;
	return {
		id => {
			required => 1,
		},
		title => {
			required => 1,
		},
		description => {

		},
		private => {

		}
	};
}

1;

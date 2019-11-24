package Unsplash::Model::Collections::Create;

use parent 'Unsplash::Model';

sub fields {
	my $self = shift;
	return {
		title => {
			required => 1
		},
		description => {

		},
		private => {

		}
	};
}

1;

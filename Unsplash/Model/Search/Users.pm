package Unsplash::Model::Search::Users;

use parent 'Unsplash::Model';
use Unsplash::Model::Users;

sub fields {
	my $self = shift;
	return {
		total => {
			required => 1,
		},
		total_pages => {
			required => 1,
		},
		results => {
			transform => sub {
				if(ref $_[0] eq 'Unsplash::Model::Users'){
					return $_[0];
				}else{
					return Unsplash::Model::Users->new($_[0]);
				}
			},
			validate => sub {
				if(ref $_[0] eq 'Unsplash::Model::Users'){
					my ($pass,$returned_data,$m) = $_[0]->validate;
					if($pass){
						return 1;
					}
				}
				return 0;
			}
		}
	};
}

1;

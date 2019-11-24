package Unsplash::Model::Users;

use parent 'Unsplash::Model';
use Unsplash::Model::User;

sub new {
	my $class = shift;
	my $data = shift;

	my $self = {};
	foreach my $d (@$data){
		push @{$self->{users}}, Unsplash::Model::User->new(%{$d});
	}

	bless( $self, $class );

	my ($s,$d,$m) = $self->validate();
	die $m unless $s;
	
	return $self;
}

sub fields {
	my $self = shift;
	return {
		users => {
			required => 1,
			transform => sub {
				my $data = shift;
				my @p;
				foreach my $d (@$data){
					if(ref $d eq 'Unsplash::Model::User'){
						push @p, $d;
					}else{
						push @p, Unsplash::Model::User->new(%{$d});
					}
				}
				return \@p;
			},
			validate => sub {
				my $data = shift;
				foreach my $d (@$data){
					if(ref $d eq 'Unsplash::Model::User'){
						my ($pass,$returned_data,$m) = $d->validate;
						unless($pass){
							return 0;
						}
					}	
				}
				return 1;
			}
		}
	};
}

1;

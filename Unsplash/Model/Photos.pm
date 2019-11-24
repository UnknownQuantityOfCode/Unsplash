package Unsplash::Model::Photos;

use parent 'Unsplash::Model';
use Unsplash::Model::Image;
use Unsplash::Model::Photo;

sub new {
	my $class = shift;
	my $data = shift;

	my $self = {};
	foreach my $d (@$data){
		push @{$self->{photos}}, Unsplash::Model::Photo->new(%{$d});
	}

	bless( $self, $class );

	my ($s,$d,$m) = $self->validate();
	die $m unless $s;
	
	return $self;
}

sub fields {
	my $self = shift;
	return {
		photos => {
			required => 1,
			transform => sub {
				my $data = shift;
				my @p;
				foreach my $d (@$data){
					if(ref $d eq 'Unsplash::Model::Photo'){
						push @p, $d;
					}else{
						push @p, Unsplash::Model::Photo->new(%{$d});
					}
				}
				return \@p;
			},
			validate => sub {
				my $data = shift;
				foreach my $d (@$data){
					if(ref $d eq 'Unsplash::Model::Photo'){
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

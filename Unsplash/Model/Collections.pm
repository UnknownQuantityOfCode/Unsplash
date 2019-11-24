package Unsplash::Model::Collections;

use parent 'Unsplash::Model';

use Unsplash::Model::Image;
use Unsplash::Model::Collections::Collection;

sub new {
  my $class = shift;
  my $data = shift;
  if(ref $data eq 'HASH'){
    $data = $data->{collections};
  }
  my $self = {};
  foreach my $d (@$data){
    push @{$self->{collections}}, Unsplash::Model::Collections::Collection->new(%{$d});
  }

  bless( $self, $class );

  my ($s,$d,$m) = $self->validate();
  die $m unless $s;
  
  return $self;
}

sub fields {
  my $self = shift;
  return {
    collections => {
      required => 1,
      transform => sub {
        my $data = shift;
        my @p;
        foreach my $d (@$data){
          if(ref $d eq 'Unsplash::Model::Collections::Collection'){
            push @p, $d;
          }else{
            push @p, Unsplash::Model::Collections::Collection->new(%{$d});
          }
        }
        return \@p;
      },
      validate => sub {
        my $data = shift;
        foreach my $d (@$data){
          if(ref $d eq 'Unsplash::Model::Collections::Collection'){
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

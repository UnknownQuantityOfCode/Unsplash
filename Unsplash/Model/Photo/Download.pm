package Unsplash::Model::Photo::Download;

use parent 'Unsplash::Model';

sub fields {
  my $self = shift;
  return {
    url => {
      required => 1,  
    }
  };
}

1;

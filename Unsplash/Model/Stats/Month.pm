package Unsplash::Model::Stats::Month;

use parent 'Unsplash::Model';

sub fields {
  my $self = shift;
  return {
    month_stats => {
        required => 1,
    }
  };
}

1;

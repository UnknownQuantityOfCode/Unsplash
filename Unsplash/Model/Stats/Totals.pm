package Unsplash::Model::Stats::Totals;

use parent 'Unsplash::Model';

sub fields {
  my $self = shift;
  return {
    total_stats => {
        required => 1,
    }
  };
}

1;

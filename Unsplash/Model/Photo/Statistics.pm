package Unsplash::Model::Photo::Statistics;

use parent 'Unsplash::Model';
use Unsplash::Model::Generic::Statistics;

sub fields {
  my $self = shift;
  return {
    id => {
      required => 1,  
    },
    downloads => {
      transform => sub {
        unless(ref $_[0] eq 'Unsplash::Model::Generic::Statistics'){
          return Unsplash::Model::Generic::Statistics->new(%{$_[0]});
        }else{
          return $_[0];
        }
      },
      validate => sub {
        if(ref $_[0] eq 'Unsplash::Model::Generic::Statistics'){
          my ($pass,$d,$m) = $_[0]->validate;
          if($pass){
            return 1;
          }
        }
        return 0;
      },
      default => sub { return Unsplash::Model::Generic::Statistics->new(%{$_[0]});}
    },
    views => {
      transform => sub {
        unless(ref $_[0] eq 'Unsplash::Model::Generic::Statistics'){
          return Unsplash::Model::Generic::Statistics->new(%{$_[0]});
        }else{
          return $_[0];
        }
      },
      validate => sub {
        if(ref $_[0] eq 'Unsplash::Model::Generic::Statistics'){
          my ($pass,$d,$m) = $_[0]->validate;
          if($pass){
            return 1;
          }
        }
        return 0;
      },
      default => sub { return Unsplash::Model::Generic::Statistics->new(%{$_[0]});}
    },
    likes => {
      transform => sub {
        unless(ref $_[0] eq 'Unsplash::Model::Generic::Statistics'){
          return Unsplash::Model::Generic::Statistics->new(%{$_[0]});
        }else{
          return $_[0];
        }
      },
      validate => sub {
        if(ref $_[0] eq 'Unsplash::Model::Generic::Statistics'){
          my ($pass,$d,$m) = $_[0]->validate;
          if($pass){
            return 1;
          }
        }
        return 0;
      },
      default => sub { return Unsplash::Model::Generic::Statistics->new(%{$_[0]});}
    },
  };
}

1;

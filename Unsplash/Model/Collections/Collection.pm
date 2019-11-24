package Unsplash::Model::Collections::Collection;

use parent 'Unsplash::Model';
use Unsplash::Model::Image;
use Unsplash::Model::User;
use Unsplash::Model::Photo;

sub fields {
  my $self = shift;
  return {
    id => {
      required => 1
    },
    title => {

    },
    description => {

    },
    published_at => {

    },
    updated_at => {

    },
    curated => {

    },
    total_photos => {

    },
    private => {

    },
    share_key => {

    },
    cover_photo => {
      transform => sub {
        unless(ref $_[0] eq 'Unsplash::Model::Photo'){
          return Unsplash::Model::Photo->new(%{$_[0]});
        }else{
          return $_[0];
        }
      },
      validate => sub {
        if(ref $_[0] eq 'Unsplash::Model::Photo'){
          my ($pass,$d,$m) = $_[0]->validate;
          if($pass){
            return 1;
          }
        }
        return 0;
      },
      default => sub { return Unsplash::Model::Photo->new(%{$_[0]});}
    },
    user => {
      transform => sub {
        unless(ref $_[0] eq 'Unsplash::Model::User'){
          return Unsplash::Model::User->new(%{$_[0]});
        }else{
          return $_[0];
        }
      },
      validate => sub {
        if(ref $_[0] eq 'Unsplash::Model::User'){
          my ($pass,$d,$m) = $_[0]->validate;
          if($pass){
            return 1;
          }
        }
        return 0;
      },
      default => sub { return Unsplash::Model::User->new(%{$_[0]});}
    },
    links => {

    }
  };
}

1;

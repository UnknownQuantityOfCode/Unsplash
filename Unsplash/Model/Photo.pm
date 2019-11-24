package Unsplash::Model::Photo;

use parent 'Unsplash::Model';
use Unsplash::Model::Image;
use Unsplash::Model::User;
use Unsplash::Model::Collections;

sub fields {
  my $self = shift;
  return {
    id => {
      required => 1,
    },
    created_at => {
      # required => 1,
    },
    updated_at => {
      # required => 1,
    },
    width => {

    },
    height => {

    },
    color => {

    },
    likes => {

    },
    liked_by_user => {

    },
    description => {

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
    current_user_collections => {
      transform => sub {
        if(ref $_[0] eq 'Unsplash::Model::Collections'){
          return $_[0];
        }else{
          return Unsplash::Model::Collections->new($_[0]);
        }
      },
      validate => sub {
        if(ref $_[0] eq 'Unsplash::Model::Collections'){
          my ($pass,$returned_data,$m) = $_[0]->validate;
          if($pass){
            return 1;
          }
        }
        return 0;
      }
    },
    urls => {
      transform => sub {
        my $data = $_[0];
        foreach my $type (qw(regular raw full thumb small)){
          $data->{$type} = Unsplash::Model::Image->new(url => $data->{$type}) unless ref $data->{$type};
        }
        return $data;
      }

    },
    links => {

    },
    statistics => {

    },
    views => {

    }
  };
}

1;

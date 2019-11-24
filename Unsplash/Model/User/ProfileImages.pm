package Unsplash::Model::User::ProfileImages;

use parent 'Unsplash::Model';
use Unsplash::Model::Image;

sub fields {
	my $self = shift;
	return {
		small => {
			transform => sub {
				if($_[0]){
					return _convert($_[0]) unless ref $_[0] eq 'HASH';
				}
				return $_[0];
			},
			validate => sub {
				if(ref $_[0] eq 'Unsplash::Model::Image'){
					my ($pass,$d,$m) = $_[0]->validate;
					if($pass){
						return 1;
					}
				}elsif(!$_[0]){
					return 1;
				}
				return 0;
			},
			default => sub { if ($_[0]) { return Unsplash::Model::Image->new(%{$_[0]}); } }
		},
		medium => {
			transform => sub {
				if($_[0]){
					return _convert($_[0]) unless ref $_[0] eq 'HASH';
				}
				return $_[0];
			},
			validate => sub {
				if(ref $_[0] eq 'Unsplash::Model::Image'){
					my ($pass,$d,$m) = $_[0]->validate;
					if($pass){
						return 1;
					}
				}elsif(!$_[0]){
					return 1;
				}
				return 0;
			},
			default => sub { if ($_[0]) { return Unsplash::Model::Image->new(%{$_[0]}); } }
		},
		large => {
			transform => sub {
				if($_[0]){
					return _convert($_[0]) unless ref $_[0] eq 'HASH';
				}
				return $_[0];
			},
			validate => sub {
				if(ref $_[0] eq 'Unsplash::Model::Image'){
					my ($pass,$d,$m) = $_[0]->validate;
					if($pass){
						return 1;
					}
				}elsif(!$_[0]){
					return 1;
				}
				return 0;
			},
			default => sub { if ($_[0]) { return Unsplash::Model::Image->new(%{$_[0]}); } }
		}
	};
}

sub _convert {
	my $url = shift;
	my ($link, $params) = split('\?', $url);
	my $data = {url => $link};
	foreach my $kv (split('&', $params)){
		my ($key, $value) = split('=', $kv);
		$data->{$key} = $value;
	}
	return $data;
}

1;

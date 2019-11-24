package Unsplash::Model;

use strict;
use warnings;

use v5.10;
use Data::Dumper;

use DateTime;
use DateTime::Format::Strptime;
use JSON::XS;

use Unsplash::Model::Image;

use constant 'ISO8601' => '%Y-%m-%dT%H:%M:%SZ';

sub new {
	my $class = shift;
	my %data = @_;
	
	my $self = {};
	foreach my $key (keys %data){
		$self->{$key} = $data{$key};
	}

	bless( $self, $class );

	my ($s,$d,$m) = $self->validate();
	warn $m." for Model $class" unless $s;
	die "Too many errors" unless $s;
	return $self;
}

sub fields {
	my $self = shift;
	return {};
}

sub validate {
	my $self = shift;
	my $fields = $self->fields;
	my $data = $self->data;
	my ($errors, @error_text);
	foreach my $f (sort keys %{$fields}){
		if($fields->{$f}->{transform}){
			if(ref $fields->{$f}->{transform} eq 'CODE'){
				$data->{$f} = $self->{$f} = $fields->{$f}->{transform}($data->{$f});
			}
		}
		
		if($fields->{$f}->{required} && (!$data->{$f} && $data->{$f} != 0)){
			if(ref $fields->{$f}->{default} eq 'CODE'){
				$data->{$f} = $self->{$f} = $fields->{$f}->{default}($data->{$f});
			}else{
				$data->{$f} = $self->{$f} = $fields->{$f}->{default};
			}
		}

		if($fields->{$f}->{required} && (!$data->{$f} && $data->{$f} != 0)){
			push @{$errors->{required}}, $f;
			push @error_text, "$f required but not found";
		}elsif($data->{$f} && $fields->{$f}->{validate}){
			my $regex = $fields->{$f}->{validate};
			my $default_in_use = 0;
			VALIDATE:if((ref $fields->{$f}->{validate} eq 'CODE' && !$fields->{$f}->{validate}($data->{$f})) || (ref $fields->{$f}->{validate} ne 'CODE' && $data->{$f} !~ /$regex/gm)){
				if($fields->{$f}->{default} && !$default_in_use){
					if(ref $fields->{$f}->{default} eq 'CODE'){
						$self->{$f} = $fields->{$f}->{default}($data->{$f});
					}else{
						$self->{$f} = $fields->{$f}->{default};
					}
					$data->{$f} = $self->{$f};
					$default_in_use++;
					goto VALIDATE;
				}else{
					push @{$errors->{valid}}, $f;
					push @error_text, "$f not valid";
				}
			}
		}
	}
	return (((scalar @error_text) ? 0:1), $errors, join(',', @error_text));
}

sub data {
	my $self = shift;
	my $fields = $self->fields;
	my $data;
	foreach my $f (keys %{$fields}){
		if(ref $self->{$f} && ref $self->{$f} ne 'HASH' && ref $self->{$f} ne 'ARRAY' && ref $self->{$f} ne 'DateTime'){
			if(ref $self->{$f} eq 'JSON::PP::Boolean'){
				$data->{$f} = ($self->{$f}) ? 1:0;	
			}else{
				$data->{$f} = $self->{$f}->data;
			}
		}elsif(ref $self->{$f} eq 'HASH'){
			foreach my $k (keys %{$self->{$f}}){
				$data->{$f}->{$k} = (index(ref $self->{$f}->{$k},'Unsplash') > -1 && $self->{$f}->{$k}->can('data')) ? $self->{$f}->{$k}->data : $self->{$f}->{$k};
			}
		}elsif(ref $self->{$f} eq 'ARRAY'){
			my @temp;
			foreach my $a (@{$self->{$f}}){
				eval {
					$a->data
				};
				if ($@) {
					push @temp, $a;
				}else{
					push @temp, $a->data;
				}
			}
			$data->{$f} = \@temp;
		}elsif(ref $self->{$f} eq 'DateTime'){
			$data->{$f} = $self->{$f}->iso8601() || $self->{$f}->strftime(ISO8601);
		}else{
			$data->{$f} = (ref $self->{$f} && index(ref $self->{$f},'Unsplash') > -1 && $self->{$f}->can('data')) ? $self->{$f}->data : $self->{$f};
		}
	}
	return $data;
}

sub TO_JSON {
	my $self = shift;
	return $self->data;
}

sub parse_datetime {
	my $string = shift;
	my $parser = DateTime::Format::Strptime->new(
	  pattern => ISO8601,
	  on_error => 'croak',
	);
	my $dt = $parser->parse_datetime($string);
	return $dt;
}

1;

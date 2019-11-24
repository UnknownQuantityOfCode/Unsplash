package Unsplash::Model::Image;

use parent 'Unsplash::Model';

sub fields {
	my $self = shift;
	return {
		url => {
			required => 1
		},
		w => {

		},
		h => {

		},
		crop => {

		},
		fm => {

		},
		auto => {

		},
		q => {

		},
		fit => {

		},
		dpi => {

		},
		cs => {

		},
		fit => {

		},
		ixid => {

		},
		ixlib => {

		}
	};
}

sub get {
	my $self = shift;
	my $data = $self->data;
	delete $data->{url};
	return ($data) ? _generate_url($self->{url}, $data) : $self->{url};
}

sub set {
	my $self = shift;
	my %fields = @_;
	my $set_fields = $self->fields;
	foreach my $key (keys %fields){
		$self->{$key} = $fields{$key} if $set_fields->{$key};
	}
	return $self->get();
}

sub _generate_url {
	my ($url, $data) = @_;
	$url =~ s/\?.+//igm if $data;
	my @params;
	foreach my $p (sort keys %{$data}){
		push @params, "$p=".$data->{$p} if $data->{$p};
	}
	return (scalar @params) ? "$url?".join('&', @params) : $url;
}

sub _from_url {
	my $self = shift;
	my $url = shift || $self->{url};
	my ($link, $params) = split('\?', $url);
	$self->{url} = $link;
	foreach my $kv (split('&', $params)){
		my ($key, $value) = split('=', $kv);
		$self->{$key} = $value;
	}
	return $self;
}

1;

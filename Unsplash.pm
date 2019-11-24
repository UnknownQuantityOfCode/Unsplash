package Unsplash;

use v5.10;

use strict;
use warnings;

# Libraries
    use JSON::XS;
    use LWP::UserAgent;
    use HTTP::Request::Common;

# Models
    use Unsplash::Model;

    use Unsplash::Model::Collections;
    use Unsplash::Model::Collections::Add;
    use Unsplash::Model::Collections::Collection;
    use Unsplash::Model::Collections::Create;
    use Unsplash::Model::Collections::Delete;
    use Unsplash::Model::Collections::Remove;
    use Unsplash::Model::Collections::Update;

    use Unsplash::Model::Generic::Link;
    use Unsplash::Model::Generic::Statistics;

    use Unsplash::Model::OAuthUrlAuthorize::Builder;

    use Unsplash::Model::OAuthUrlToken::Request;
    use Unsplash::Model::OAuthUrlToken::Response;

    use Unsplash::Model::Photo::Download;
    use Unsplash::Model::Photo::Statistics;
    use Unsplash::Model::Photo;
    use Unsplash::Model::Photos;

    use Unsplash::Model::Search::Collections;
    use Unsplash::Model::Search::Photos;
    use Unsplash::Model::Search::Users;

    use Unsplash::Model::Stats::Month;
    use Unsplash::Model::Stats::Totals;

    use Unsplash::Model::Users;
    use Unsplash::Model::User::ProfileImages;
    use Unsplash::Model::User;
    use Unsplash::Model::User::Statistics;
    use Unsplash::Model::User::Update;
    
# INIT
	sub new {
		my $class = shift;
		my %data = @_;
		my $self = {
            "endPointSandbox" => "https://api.unsplash.com/",
			"endPointProduction" => "https://api.unsplash.com/",
            "endPointService" => "https://api.unsplash.com/"
		};
		foreach my $key (keys %data){
			$self->{$key} = $data{$key};
		}

		if($self->{'access_token'}){
            $self->{"Authorization"} = "Bearer ".$self->{'access_token'};
        }elsif($self->{'client_id'} || $self->{'client_secret'}){
            # $self->{"Authorization"} = $self->{'client_id'}." ".$self->{'client_secret'};
        }else{
            warn "No access information provided";
        }

        $self->{"User-Agent"} = "UnsplashModule/1.0 ".(($self->{'client_id'}) ? "(Merchant/".$self->{'client_id'}.")" : "(Public)");
        $self->{"Accept-Version"} = 'v1';

		bless( $self, $class );
		return $self;
	}

# Core Functions
    sub _ua {
        my $self = shift;
        if($self->{ua}){
        	return $self->{ua};
        }
        my $ua = LWP::UserAgent->new;
        $ua->default_header('Content-Type'   => 'application/json');
        $ua->default_header('Authorization'  => $self->{"Authorization"}) if $self->{"Authorization"};
        $ua->default_header('Accept-Version' => $self->{"Accept-Version"});
        $ua->default_header('User-Agent'     => $self->{"User-Agent"});
        $self->{ua} = $ua;
        return $self->{ua};
    }

    sub _build_url {
        my $self = shift;
    	my ($url, $data) = @_;
        $url = $self->{endPointProduction}.$url unless $url =~ /^https?\:/igm;

        my @matches = ($url =~ /(:[^\b\/\?]{1,})/igm);
        foreach my $match (@matches){
            my $key = $match; $key =~ s/://igm; my $value = delete $data->{$key};
            $url =~ s/$match/$value/igm;
        }

    	my @params;
    	foreach my $p (sort keys %{$data}){
    		push @params, "$p=".$data->{$p};
    	}
    	return (scalar @params) ? "$url?".join('&', @params) : $url;
    }

    sub _call {
        my $self = shift;
        my $type = uc(shift);
        return (0, {message => "INVALID TYPE $type"}) unless $type =~ /^(GET|POST|PUT|DELETE)$/gm;
        my $url = shift;
        my $content = shift;

        $url = $self->_build_url($url, $content);
        my $ua = $self->_ua() || return (0, {}, 'No UA Present');

        my $request = HTTP::Request->new($type => $url);
        if($type eq 'POST' || $type eq 'PUT'){
            eval { encode_json($content) };
            if ($@) {
                return (0, {}, 'Cannot encode content');
            }
            $content = encode_json($content);
            $request->content($content);
        }

        my $response = $ua->request($request);
        foreach my $header ('X-Ratelimit-Limit', 'X-Ratelimit-Remaining', 'X-Per-Page', 'X-Total'){
            $self->{$header} = $response->headers->{$header} if $response->headers->{$header};
        }
        my $data = eval {decode_json ($response->decoded_content)} || { message => 'Cannot decode response', response => $response->decoded_content };
        if($response->is_success || ($type eq 'delete' && $response->code eq '204')){
            return (1, $data);
        }else{
            return (0, $data);
        }
    }

# Authorization
    # OAuth Functions
        sub get_url {
            my $self = shift;
            my %data = @_;
            $data{client_id} = $data{client_id} || $self->{client_id};
            my $url = Unsplash::Model::OAuthUrlAuthorize::Builder->new(%data);
            my ($s,$d,$m) = $url->validate();
            my $link_data;
            if($s){
                $link_data = {url => $url->oauth_link()};
            }
            return {status => $s, data => $link_data, message => $m};
        }

        sub get_access_key {
            my $self = shift;
            my %data = @_;
            $data{client_id} = $data{client_id} || $self->{client_id};
            $data{client_secret} = $data{client_secret} || $self->{client_secret};
            my $request = Unsplash::Model::OAuthUrlToken::Request->new(%data);
            my $resp;
            my ($s,$d,$m) = $self->_call('post',$Unsplash::Model::OAuthUrlToken::Request::oauthendpoint, $request);
            if($s){
                $resp = Unsplash::Model::OAuthUrlToken::Response->new(%{$d});
                $self->{access_key} = $resp->{access_key};
            }
            return ($s) ? $self : {status => $s, data => $resp, message => $m}; 
        }

# Main Functions
    # User
        # Get the user’s profile
        sub current_user {
            my $self = shift;
            my $user;
            my ($s,$d,$m) = $self->_call('get', 'me');
            $user = Unsplash::Model::User->new(%{$d}) if($s);
            return {status => $s, data => $user, message => $m};
        }
        # Update the current user’s profile
        sub update_current_user {
            my $self = shift;
            my %data = @_;
            my $request = Unsplash::Model::User::Update->new(%data);
            my $user;
            my ($s,$d,$m) = $self->_call('put','me', $request);
            if($s){
                $user = Unsplash::Model::User->new(%{$d}) if($s);
            }
            return {status => $s, data => $user, message => $m}; 
        }

    # Users
        # Get a user’s public profile
        sub get_user {
            my $self = shift;
            my %data = @_;
            my $user;
            my ($s,$d,$m) = $self->_call('get','users/:username', \%data);
            $user = Unsplash::Model::User->new(%{$d}) if($s);
            return {status => $s, data => $user, message => $m};
        }
        # Get a user’s portfolio link
        sub get_user_portfolio_link {
            my $self = shift;
            my %data = @_;
            my $link;
            my ($s,$d,$m) = $self->_call('get','users/:username/portfolio', \%data);
            $link = Unsplash::Model::Generic::Link->new(%{$d}) if ($s);
            return {status => $s, data => $link, message => $m};
        }
        # List a user’s photos
        sub get_user_photos {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','users/:username/photos', \%data);
            $return = Unsplash::Model::Photos->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # List a user’s liked photos
        sub get_user_liked_photos {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','users/:username/likes', \%data);
            $return = Unsplash::Model::Photos->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # List a user’s collections
        sub get_user_collections {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','users/:username/collections', \%data);
            $return = Unsplash::Model::Collections->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Get a user’s statistics
        sub get_user_statistics {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','users/:username/statistics', \%data);
            $return = Unsplash::Model::User::Statistics->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }

    # Photos
        # List photos
        sub get_photos {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','photos', \%data);
            $return = Unsplash::Model::Photos->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Get a photo
        sub get_photo {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','photos/:id', \%data);
            if ($s) {
                $return = Unsplash::Model::Photo->new(%{$d});
                delete $return->{links}->{download_location};
                $return->{links}->{download} = sub {
                    return $self->get_photo_download(id => $return->{id})
                };
            }
            return {status => $s, data => $return, message => $m};
        }
        # Get a random photo
        sub get_random_photo {
            my $self = shift;
            my %data = @_;
            $data{count} = 1 unless $data{count} && $data{count} >= 1 && $data{count} <= 30;
            my $return;
            my ($s,$d,$m) = $self->_call('get','photos/random', \%data);
            $return = Unsplash::Model::Photos->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Get a photo’s statistics
        sub get_photo_statistics {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','photos/:id/statistics', \%data);
            $return = Unsplash::Model::Photo::Statistics->new(%{$d}) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Track a photo download
        sub get_photo_download {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','photos/:id/download', \%data);
            $return = Unsplash::Model::Photo::Download->new(%{$d}) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Update a photo
        sub update_photo {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('put','photos/:id', \%data);
            $return = Unsplash::Model::Photo->new(%{$d}) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Like a photo
        sub like_photo {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('post','photos/:id/like', \%data);
            $return = Unsplash::Model::Photo->new(%{$d}) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Unlike a photo
        sub unlike_photo {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('delete','photos/:id/like', \%data);
            $return = Unsplash::Model::Photo->new(%{$d}) if ($s);
            return {status => $s, data => $return, message => $m};
        }

    # Search
        # Search photos
        sub search_photos {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','search/photos', \%data);
            $return = Unsplash::Model::Search::Photos->new(%{$d}) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Search collections
        sub search_collections {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','search/collections', \%data);
            $return = Unsplash::Model::Search::Collections->new(%{$d}) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Search users
        sub search_users {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','search/users', \%data);
            $return = Unsplash::Model::Search::Users->new(%{$d}) if ($s);
            return {status => $s, data => $return, message => $m};
        }

    # Collections
        # List collections
        sub get_collections {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','collections', \%data);
            $return = Unsplash::Model::Collections->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # List featured collections
        sub get_featured_collections {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','collections/featured', \%data);
            $return = Unsplash::Model::Collections->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Get a collection
        sub get_collection {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','collections/:id', \%data);
            $return = Unsplash::Model::Collection->new(%{$d}) if($s);
            return {status => $s, data => $return, message => $m};
        }
        # Get a collection’s photos
        sub get_collection_photos {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','collections/:id/photos', \%data);
            $return = Unsplash::Model::Photos->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # List a collection’s related collections
        sub get_related_collections {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','collections/:id/related', \%data);
            $return = Unsplash::Model::Collections->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Create a new collection
        sub create_collection {
            my $self = shift;
            my %data = @_;
            my $request = Unsplash::Model::Collections::Create->new(%data);
            my $resp;
            my ($s,$d,$m) = $self->_call('post','collections', $request);
            $resp = Unsplash::Model::collections::Collection->new(%{$d}) if ($s);
            return {status => $s, data => $resp, message => $m}; 
        }
        # Update an existing collection
        sub update_collection {
            my $self = shift;
            my %data = @_;
            my $request = Unsplash::Model::Collections::Update->new(%data);
            my $resp;
            my ($s,$d,$m) = $self->_call('put','collections/:id', $request);
            $resp = Unsplash::Model::collections::Collection->new(%{$d}) if ($s);
            return {status => $s, data => $resp, message => $m}; 
        }
        # Delete a collection
        sub delete_collection {
            my $self = shift;
            my %data = @_;
            my $request = Unsplash::Model::Collections::Delete->new(%data);
            my ($s,$d,$m) = $self->_call('delete','collections/:id', $request);
            return {status => $s, data => $d, message => $m};
        }
        # Add a photo to a collection
        sub add_to_collection {
            my $self = shift;
            my %data = @_;
            my $return;
            my $request = Unsplash::Model::Collections::Add->new(%data);
            my ($s,$d,$m) = $self->_call('get','collections/:collection_id/add', $request);
            $return = Unsplash::Model::Photo->new(%{$d}) if($s);
            return {status => $s, data => $return, message => $m};
        }
        # Remove a photo from a collection
        sub remove_from_collection {
            my $self = shift;
            my %data = @_;
            my $return;
            my $request = Unsplash::Model::Collections::Remove->new(%data);
            my ($s,$d,$m) = $self->_call('get','collections/:collection_id/remove', $request);
            $return = Unsplash::Model::Photo->new(%{$d}) if($s);
            return {status => $s, data => $return, message => $m};
        }

    # Stats
        # Totals
        sub get_totals_statistics {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','stats/total', \%data);
            $return = Unsplash::Model::Stats::Totals->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
        # Month
        sub get_month_statistics {
            my $self = shift;
            my %data = @_;
            my $return;
            my ($s,$d,$m) = $self->_call('get','stats/month', \%data);
            $return = Unsplash::Model::Stats::Month->new($d) if ($s);
            return {status => $s, data => $return, message => $m};
        }
    
# Utility Functions
    sub _status {
        my $self = shift;
        my $ua = LWP::UserAgent->new;
        my $response = $ua->get($self->{endPointService});
        return ($response->is_success) ? 1:0;
    }

1;

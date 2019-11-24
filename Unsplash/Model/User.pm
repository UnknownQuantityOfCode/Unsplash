package Unsplash::Model::User;

use parent 'Unsplash::Model';
use DateTime;

sub fields {
	my $self = shift;
	return {
		id => {
			required => 1,
		},
		updated_at => {

		},
		username => {
			required => 1,
		},
		name => {

		},
		first_name => {

		},
		last_name => {

		},
		twitter_username => {

		},
		instagram_username => {

		},
		followers_count => {

		},
		following_count => {

		},
		portfolio_url => {

		},
		bio => {

		},
		location => {

		},
		total_likes => {

		},
		total_photos => {

		},
		total_collections => {

		},
		followed_by_user => {

		},
		downloads => {

		},
		uploads_remaining => {

		},
		instagram_username => {

		},
		location => {

		},
		email => {

		},
		links =>{
			
		}
	};
}

sub updated {
	my $self = shift;
	if($self->{updated_at} =~ /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(.*)$/igm){
		my $dt = DateTime->new(year => $1, month => $2, day => $3, hour => $4, minute => $5, second => $6, time_zone => $7);
		return $dt;
	}
	return undef;
}

1;

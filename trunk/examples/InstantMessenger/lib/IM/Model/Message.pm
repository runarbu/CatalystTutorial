package IM::Model::Message;

use strict;
use warnings;

use base 'IM::Model::Base';
use HTML::Entities;
 use Digest::MD5 qw( md5_hex );

__PACKAGE__->table('messages');

__PACKAGE__->add_columns(qw(
    message_id
    author
    content
    posted
));

__PACKAGE__->set_primary_key('message_id');

sub parsed_content {
    my $self = shift;
    my $content = encode_entities( $self->content(), '<>&"' );
    $content =~ s{\[(b|bold)\](.*?)\[/(b|bold)\]}{<b>$2</b>}sg;
    $content =~ s{\[(i|italic)\](.*?)\[/(i|italic)\]}{<i>$2</i>}sg;
    $content =~ s{((http://|mailto:)([^\s"'&>]+))}{<a href="$1">$3</a>}sg;
    return $content;
}

sub _mk_opts {
	shift;
	return {
		order_by=>'posted DESC',
		@_,
	}
}

sub get_messages {
	my ( $self, @opts ) = @_;
	
	$self->search( {}, $self->_mk_opts( @opts ) );
}

sub get_messages_from {
	my ( $self, $from, @opts ) = @_;

	$from ||= 0;

	$self->search(
		{ message_id => { ">" => $from } },
		$self->_mk_opts( @opts ),
	);
}

sub hex_color {
    my( $self ) = @_;
    return substr( md5_hex($self->author), 5, 6 );
}

sub stamp {
    my( $self ) = @_;
    my @times = gmtime( $self->posted );
    return sprintf('%02d:%02d:%02d',$times[2],$times[1],$times[0]);
}

1;

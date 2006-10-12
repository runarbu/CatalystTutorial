package XML::Feed::Aggregate;

use base 'XML::Feed';
use XML::RSS::TimingBot;

our $VERSION='0.01';


=head1 NAME XML::Feed::Aggregate - Aggregate a set of rss feed

=head1 SYNOPSIS

  use XML::Feed::Aggregate;
  my $collection = XML::RAI::Agggregate->new(
      'http://thefeed.no/index.xml',
      'http://slashdot.org/index.xml');
  $collection->collect();
  my $items= $collection->items;
  my $channels = $collection->channels;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item new

Takes a list of feeds as a scalar ref, as well as an optional sort
function, and returns a new XML::RAI::Aggregate object.

=cut

sub new {
    my ($proto,$feeds,$sort_func) = @_;
    my $class= ref $proto || $proto;
    my $self=bless {},$class;
    $sort_func ||= sub {$b->created cmp $a->created};
    $self->{sort_func}=$sort_func;
    $self->{feeds}=$feeds;
    $self->{browser}=XML::RSS::TimingBot->new();
    return $self;
}

=item collect

Refetch all feeds as appropriate. Uses L<RSS::TimingBot> to determine
what's appropriate.

=cut

sub collect {
    my $self=shift;
    my (@items,$channels);
    my $browser=$self->{browser};
    foreach my $item ( @{$self->{feeds}} ) {
        my $content=$browser->get ($item);
        warn "could not fetch $item", next unless defined $content;
        my $rai=XML::RAI->parse($content);
        push @items,@{$rai->items};
        push @channels,$rai->channel;
    }
    $self->{items}=\@items;
    $self->{channels}=\@channels;
    $browser->commit;
}

=item items

Returns a sorted listref of all the aggregated elements
Will call collect if it hasn't been called yet.

=cut

sub items {
    my $self=shift;
    $self->collect unless $self->{items};
    my $sort=$self->{sort_func};
    return [ sort $sort @{$self->{items}} ];
}

=item channels

Returns an arrayref to the aggregated channels.

=cut

sub channels {
    my $self=shift;
    $self->collect unless $self->{channels};
    return [$self->{channels}];
}

=back

=head1 AUTHOR

Marcus Ramberg, C<mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;

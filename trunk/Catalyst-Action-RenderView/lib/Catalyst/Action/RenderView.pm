package Catalyst::Action::RenderView;

our $VERSION='0.04';

use base 'Catalyst::Action';

sub execute {
    my $self = shift;
    my ($controller, $c ) = @_;
    $self->NEXT::execute( @_ );
    if ($c->debug && $c->req->params->{dump_info}) {
	die "forced debug" 
    }
    if(! $c->response->content_type ) {
        $c->response->content_type( 'text/html; charset=utf-8' );
    }
    return 1 if $c->req->method eq 'HEAD';
    return 1 if length( $c->response->body );
    return 1 if scalar @{ $c->error } && !$c->stash->{template};
    return 1 if $c->response->status =~ /^(?:204|3\d\d)$/;
    my $view=$c->view() 
        || die "Catalyst::Action::RenderView could not find a view to forward to.\n";
    $c->forward( $view );
};
 
1;

=head1 NAME

Catalyst::Action::RenderView - Sensible default end action.

=head1 SYNOPSIS

    sub end : ActionClass('RenderView') {}

=head1 DESCRIPTION

This action implements a sensible default end action, which will forward
to the first available view, unless status is set to 3xx, or there is a
response body. It also allows you to pass C<dump_info=1> to the url in
order to force a debug screen, while in debug mode.

If you have more than one view, you can specify which one to use with
the C<default_view> config setting (see L<Catalyst/"$c->view($name)">.)

=head1 METHODS

=over 4

=item end

The default C<end> action. You can override this as required in your
application class; normal inheritance applies.

=head1 EXTENDING

To add something to an C<end> action that is called before rendering,
simply place it in the C<end> method:

    sub end : ActionClass('RenderView') {
      my ( $self, $c ) = @_;
      # do stuff here; the RenderView action is called afterwards
    }

To add things to an C<end> action that are called I<after> rendering,
you can set it up like this:

    sub render : ActionClass('RenderView') { }

    sub end : Private { 
      my ( $self, $c ) = @_;
      $c->forward('render');
      # do stuff here
    }

=back

=head1 AUTHOR

Marcus Ramberg <marcus@thefeed.no>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it
under the same terms as Perl itself.

=cut


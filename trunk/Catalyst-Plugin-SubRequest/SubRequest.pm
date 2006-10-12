package Catalyst::Plugin::SubRequest;

use strict;

our $VERSION = '0.11';

=head1 NAME

Catalyst::Plugin::SubRequest - Make subrequests to actions in Catalyst

=head1 SYNOPSIS

    use Catalyst 'SubRequest';

    $c->subreq('/test/foo/bar', { template => 'magic.tt' });

=head1 DESCRIPTION

Make subrequests to actions in Catalyst. Uses the  catalyst
dispatcher, so it will work like an external url call.

=head1 METHODS

=over 4 

=item subreq path, [stash as hash ref], [parameters as hash ref]

=item sub_request

Takes a full path to a path you'd like to dispatch to. Any additional
parameters are put into the stash.

=back 

=cut

*subreq = \&sub_request;

sub sub_request {
    my ( $c, $path, $stash, $params ) = @_;

    $path =~ s#^/##;

    $params ||= {};

    my %request_mods = (
        body => undef,
        action => undef,
        match => undef,
        parameters => $params,
    );

    if (ref $path eq 'HASH') {
        @request_mods{keys %$path} = values %$path;
    } else {
        $request_mods{path} = $path;
    }

    my $fake_engine = bless(
        {
            orig_request => $c->req,
            request_mods => \%request_mods,
        },
        'Catalyst::Plugin::SubRequest::Internal::FakeEngine'
    );

    my $class = ref($c);

    no strict 'refs';
    no warnings 'redefine';

    local *{"${class}::engine"} = sub { $fake_engine };

    my $inner_ctx = $class->prepare;

    $inner_ctx->stash($stash || {});

    $inner_ctx->dispatch;
    return $inner_ctx->response->body;
}

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Marcus Ramberg, C<mramberg@cpan.org>

=head1 THANK YOU

SRI, for writing the awesome Catalyst framework

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

package # hide from PAUSE
  Catalyst::Plugin::SubRequest::Internal::FakeEngine;

sub AUTOLOAD { return 1; } # yeah yeah yeah

sub prepare {
    my ($self, $c) = @_;
    my $req = $c->request;
    my %attrs = (%{$self->{orig_request}}, %{$self->{request_mods}});
    @{$req}{keys %attrs} = values %attrs;
}

1;

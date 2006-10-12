package CatalystX::Blog::Controller::Static;

use strict;
use base 'Catalyst::Base';

=head1 NAME

    CatalystX::Blog::Controller::Static - An extensible and portable Static
    Controller

=head1 SYNOPSIS

    package MyApp::Controller::Static;
    use base qw/CatalystX::Blog::Controller::Static/;

=head1 DESCRIPTION

=over4

=item end

=cut

sub end : Private {
    my ( $self, $c ) = @_;
    $c->response->header( 'Cache-Control' => 'max-age=86400' );
}

=item default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->serve_static;
}

=item css

=cut

sub css : Regex('(?i)\.(?:css)') {
    my ( $self, $c ) = @_;
    $c->serve_static("text/css");
}

=item ico

=cut

sub ico : Regex('(?i)\.(?:ico)') {
    my ( $self, $c ) = @_;
    $c->serve_static("image/vnd.microsoft.icon");
}

=item js

=cut

sub js : Regex('(?i)\.(?:js)') {
    my ( $self, $c ) = @_;
    $c->serve_static("application/x-javascript");
}

=back

=head1 AUTHOR

Christian Hansen <ch@ngmedia.com>

=head1 THANKS TO

Danijel Milicevic, Jesse Sheidlower, Marcus Ramberg, Sebastian Riedel,
Viljo Marrandi

=head1 SUPPORT

#catalyst on L<irc://irc.perl.org>

L<http://lists.rawmode.org/mailman/listinfo/catalyst>

L<http://lists.rawmode.org/mailman/listinfo/catalyst-dev>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

package Catalyst::Plugin::Compress::Zlib;

use strict;
use base 'Catalyst::Plugin::Compress::Gzip';

our $VERSION = '0.02';

1;

__END__

=head1 NAME

Catalyst::Plugin::Compress::Zlib - Zlib Compression for Catalyst

=head1 SYNOPSIS

    use Catalyst qw[Compress::Gzip];

    use Catalyst qw[Compress::Deflate];

=head1 DESCRIPTION

Compress response if client supports it.

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

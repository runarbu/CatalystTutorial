package Catalyst::Helper::JSAN;

use strict;
use File::Spec;
use Catalyst::Utils;
use Config;

=head1 NAME

Catalyst::Helper::JSAN - Helper to generate the JSAN shell

=head1 SYNOPSIS

    script/myapp_create.pl JSAN

=head1 DESCRIPTION

Helper to generate the JSAN shell.

=head2 METHODS

=over 4

=item mk_stuff

=back 

=cut

sub mk_stuff {
    my ( $self, $helper ) = @_;
    my $dir = File::Spec->catdir( $helper->{base}, 'root', 'static', 'js' );
    $helper->mk_dir($dir);
    my $prefix = Catalyst::Utils::appprefix( $helper->{app} );
    my $file   =
      File::Spec->catfile( $helper->{base}, 'script', "$prefix\_jsan.pl" );
    $helper->render_file( 'jsan', $file,
        { appprefix => $prefix, startperl => $Config{startperl} } );
    chmod 0700, $file;
}

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Test>, L<Catalyst::Request>,
L<Catalyst::Response>, L<Catalyst::Helper>

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut

1;
__DATA__

__jsan__
[% startperl %] -w

use strict;
use File::Spec;
use FindBin;

$ENV{JSAN_PREFIX} ||= File::Spec->catdir( $FindBin::Bin, '..', 'root', 'static', 'js' );

# JSAN shell
require JSAN;
JSAN->control;

1;

=head1 NAME

[% appprefix %]_jsan.pl - JSAN shell

=head1 SYNOPSIS

[% appprefix %]_jsan.pl [options]

 Examples:
   jsan> index
   jsan> install Test.Simple

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro


=head1 DESCRIPTION

Install JavaScript libraries from the JSAN shell.

=head1 SEE ALSO

L<JSAN>, L<http://openjsan.org>

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 COPYRIGHT

Copyright 2004 Sebastian Riedel. All rights reserved.

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

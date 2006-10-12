package Catalyst::Plugin::I18N;

use strict;
use NEXT;
use I18N::LangTags ();
use I18N::LangTags::Detect;

require Locale::Maketext::Simple;

our $VERSION = '0.05';

=head1 NAME

Catalyst::Plugin::I18N - I18N for Catalyst

=head1 SYNOPSIS

    use Catalyst 'I18N';

    print join ' ', @{ $c->languages };
    $c->languages( ['de'] );
    print $c->localize('Hello Catalyst');

Use a macro if you're lazy:

   [% MACRO l(text, args) BLOCK;
       c.localize(text, args);
   END; %]

   [% l('Hello Catalyst') %]
   [% l('Hello [_1]', 'Catalyst') %]
   [% l('lalala[_1]lalala[_2]', ['test', 'foo']) %]

=head1 DESCRIPTION

Supports mo/po files and Maketext classes under your applications I18N
namespace.

   # MyApp/I18N/de.po
   msgid "Hello Catalyst"
   msgstr "Hallo Katalysator"

   #MyApp/I18N/de.pm
   package MyApp::I18N::de;
   use base 'MyApp::I18N';
   our %Lexicon = ( 'Hello Catalyst' => 'Hallo Katalysator' );
   1;

=head2 EXTENDED METHODS

=head3 setup

=cut

sub setup {
    my $self = shift;
    $self->NEXT::setup(@_);
    my $calldir = $self;
    $calldir =~ s#::#/#g;
    my $file = "$calldir.pm";
    my $path = $INC{$file};
    $path =~ s#\.pm$#/I18N#;
    eval <<"";
      package $self;
      import Locale::Maketext::Simple Path => '$path', Export => '_loc', Decode => 1;


    if ($@) {
        $self->log->error(qq/Couldn't initialize i18n "$self\::I18N", "$@"/);
    }
    else {
        $self->log->debug(qq/Initialized i18n "$self\::I18N"/) if $self->debug;
    }
}

=head2 METHODS

=head3 languages

Contains languages.

   $c->languages(['de_DE']);
   print join '', @{ $c->language };

=cut

sub languages {
    my ( $c, $languages ) = @_;
    if ($languages) { $c->{languages} = $languages }
    else {
        $c->{languages} ||= [
            I18N::LangTags::implicate_supers(
                I18N::LangTags::Detect->http_accept_langs(
                    $c->request->header('Accept-Language')
                )
            ),
            'i-default'
        ];
    }
    no strict 'refs';
    &{ ref($c) . '::_loc_lang' }( @{ $c->{languages} } );
    return $c->{languages};
}

=head3 language

return selected locale in your locales list.

=cut

sub language {
    my $c = shift;
    my $class = ref $c || $c;

    my $lang = ref "$class\::I18N"->get_handle( @{ $c->languages } );
    $lang =~ s/.*:://;

    return $lang;
}

=head3 loc

=head3 localize

Localize text.

    print $c->localize( 'Welcome to Catalyst, [_1]', 'sri' );

=cut

*loc = \&localize;

sub localize {
    my $c = shift;
    $c->languages;
    no strict 'refs';
    return &{ ref($c) . '::_loc' }( $_[0], @{ $_[1] } )
      if ( ref $_[1] eq 'ARRAY' );
    return &{ ref($c) . '::_loc' }(@_);
}

=head1 SEE ALSO

L<Catalyst>.

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>

Brian Cassidy, C<bricas@cpan.org>

Christian Hansen, C<chansen@cpan.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

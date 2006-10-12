use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Catalyst::Plugin::Session::Store::DBIC',
    AUTHOR        => 'Daniel Westermann-Clark <danieltwc@cpan.org>',
    VERSION_FROM  => 'lib/Catalyst/Plugin/Session/Store/DBIC.pm',
    ABSTRACT_FROM => 'lib/Catalyst/Plugin/Session/Store/DBIC.pm',
    PREREQ_PM     => {
        'Catalyst'                         => '5.65',  # For setup_finished
        'Catalyst::Exception'              => 0,
        'Catalyst::Plugin::Session'        => 0,
        'Catalyst::Plugin::Session::Store' => 0,
        'Class::Data::Inheritable'         => 0,
        'DBIx::Class'                      => '0.05000',  # For update_or_create
        'FindBin'                          => 0,
        'MIME::Base64'                     => 0,
        'NEXT'                             => 0,
        'Storable'                         => 0,
        'Test::More'                       => 0,
    },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'Catalyst-Plugin-Session-Store-DBIC-* MANIFEST META.yml README' },
);


package MY;

sub postamble {
    return <<"...";
cover::
	cover -delete
	HARNESS_PERL_SWITCHES=-MDevel::Cover \$(MAKE) test
	cover

readme::
	perldoc -o text -d README \$(NAME)
...
}

1;

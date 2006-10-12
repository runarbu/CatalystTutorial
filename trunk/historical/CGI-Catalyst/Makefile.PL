#!perl

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'CGI::Catalyst',
    VERSION_FROM => 'lib/CGI/Catalyst.pm',
    PREREQ_PM    => {

        # Core
        CGI                               => 0,
        CGI::Cookie                       => 0,
        HTTP::Headers                     => 0,
        Class::Accessor::Fast             => 0,
        Class::Data::Inheritable          => 0,

        # Debug
        Data::Dumper                      => 0,
        HTML::Entities                    => 0,

        # Testing
        HTTP::Request                     => 0,
        HTTP::Response                    => 0,
        HTTP::Status                      => 0,
        Test::More                        => 0,
        URI                               => 0,
    },
    test => {
        TESTS => join ' ', (
            glob('t/*.t'), glob('t/*/*.t')
        )
    }
);

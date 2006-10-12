use strict;
use Catalyst::Build;

my $build = Catalyst::Build->new(
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'ServerDB',
    requires           => { 
        Catalyst => '5.23',
        'Catalyst::Plugin::FormValidator' => 0,
        'Catalyst::Plugin::Session::FastMmap' => 0,
        'Catalyst::Plugin::Static' => 0,
        'DBD::SQLite2' => 0,
        'Class::DBI::Plugin::Pager' => 0,
        'Class::DBI::FromForm' => '0.03',
        Plucene => 0,
        'Plucene::Plugin::Analyzer::SnowballAnalyzer' => 0,
        'Text::CSV_XS' => 0,
        'Tie::IxHash' => 0,
        'Digest::SHA' => 0,
        YAML => '0.39',
    },
    create_makefile_pl => 'passthrough',
    script_files       => [ glob('script/*') ],
    test_files         => [ glob('t/*.t'), glob('t/*/*.t') ]
);
$build->create_build_script;

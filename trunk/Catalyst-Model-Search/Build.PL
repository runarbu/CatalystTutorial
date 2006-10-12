use strict;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'Catalyst::Model::Search',
    requires           => { 
        'Catalyst'   => '5.33',
        'Class::Std' => 0,
    },
    recommends         => {
        'Plucene'       => '1.24',
        'Plucene::Plugin::Analyzer::SnowballAnalyzer' => '1.1',
        'Net::LuceneWS' => 0,
    },
    create_makefile_pl => 'passthrough',
    test_files   => [
        glob('t/*.t') 
    ]
);
$build->create_build_script;

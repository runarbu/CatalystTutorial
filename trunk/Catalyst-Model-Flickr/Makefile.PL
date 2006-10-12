use ExtUtils::MakeMaker;

WriteMakefile(
     NAME          => 'Catalyst::Model::Flickr',
     VERSION_FROM  => 'lib/Catalyst/Model/Flickr.pm',
     PREREQ_PM     => { 'Flickr::API'       => 0,
                        'Flickr::Upload'    => 0,
                        'Catalyst'          => 0,
                    },
);

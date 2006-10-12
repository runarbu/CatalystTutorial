use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Plugin::Email',
    AUTHOR    => 'Sebastian Riedel (sri@oook.de)',
    PREREQ_PM => {
        Catalyst             => '2.99',
        Email::Send          => 0,
        Email::MIME          => 0,
        Email::MIME::Creator => 0
    },
    VERSION_FROM => 'Email.pm'
);

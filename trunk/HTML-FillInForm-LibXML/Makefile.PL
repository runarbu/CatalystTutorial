#!perl

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'HTML::FillInForm::LibXML',
    VERSION_FROM => 'lib/HTML/FillInForm/LibXML.pm',
    PREREQ_PM    => {
        List::Util  => 0,
        XML::LibXML => 0
    }
);

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Catalyst::Plugin::Server::XMLRPC',
    'VERSION_FROM' => 'lib/Catalyst/Plugin/Server/XMLRPC.pm',
    'PREREQ_PM'    => { Catalyst => '5.66', 'RPC::XML' => 1 }
);

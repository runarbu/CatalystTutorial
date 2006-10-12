use inc::Module::Install;

name 'HTML-Widget-Constraint-DBIC';
all_from 'lib/HTML/Widget/Constraint/DBIC.pm';

requires 'HTML::Widget' => '1.05';
requires 'Scalar::Util';
requires 'Carp';

build_requires 'Test::MockObject';

no_index directory => 't/lib';

auto_install;
&WriteAll;

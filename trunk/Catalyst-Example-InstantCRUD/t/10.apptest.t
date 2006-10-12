use strict;
use warnings;
use Test::More; 

BEGIN {
use lib 't/tmp/My-App/lib';
}

eval "use Test::WWW::Mechanize::Catalyst 'My::App'";
if ($@){
    plan skip_all => "Test::WWW::Mechanize::Catalyst required for testing application";
}else{
    plan tests => 13;
}

my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get_ok("http://localhost/");

$mech->follow_link_ok({text => 'firsttable'}, "Click on firsttable");

$mech->follow_link_ok({text => 'Intfield'}, "sort by intfield");
$mech->content_contains("This is the row with the smallest int", "smallest int row found");

$mech->follow_link_ok({text => 'Intfield'}, "desc sort by intfield");
$mech->content_contains("This is the row with the biggest int", "biggest int row found");

$mech->follow_link_ok({text => '3'}, "desc sort by intfield page 3");
$mech->content_contains("This is the row with the smallest int", "smallest int row found");

$mech->get_ok("/firsttable/edit/2");
$mech->submit_form(
    form_number => 1,
    fields      => {
        intfield => '3',
        varfield => 'Changed varchar field',
    }
);
$mech->follow_link_ok({text => 'firsttable'}, "Click on firsttable");
$mech->content_contains("Changed varchar field");
$mech->get_ok("/firsttable/destroy/2");
$mech->submit_form( form_number => 1 );
$mech->content_lacks("Changed varchar field");
 

use strict;
use warnings;

use Test::More tests => 8;

use HTML::Widget;
use lib 't/lib';
use HTMLWidget::TestLib;

# widget

my $w = HTML::Widget->new( 'form', { class => 'myForm' } );

ok( exists $w->attributes->{class}, 'key exists' );

$w->attributes( onsubmit => 'foo' );
$w->attributes( { onclick => 'bar' } );

ok( exists $w->attributes->{onsubmit}, 'key exists' );
ok( exists $w->attributes->{onclick},  'key exists' );

#element

my $e = $w->element( 'Textfield', 'foo',
    { class => 'myText', disabled => 'disabled' } )->size(10);

ok( $e->attributes->{disabled}, 'key exists' );

$e->attributes( onsubmit => 'foo' );
$e->attributes( { onclick => 'bar' } );

ok( exists $w->attributes->{onsubmit}, 'key exists' );
ok( exists $w->attributes->{onclick},  'key exists' );

# delete attributes idiom

%{ $w->attributes } = ();

ok( !exists $w->attributes->{class}, 'key does not exist' );

%{ $e->attributes } = ();

ok( !exists $e->attributes->{disabled}, 'key does not exist' );


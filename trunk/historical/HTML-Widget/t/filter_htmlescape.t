use Test::More tests => 4;

use_ok("HTML::Widget");

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' )->value('foo')->size(30)->label('Foo');
$w->element( 'Textfield', 'bar' );

$w->constraint( 'Integer', 'foo' );
$w->constraint( 'Integer', 'bar' );

$w->filter( 'HTMLEscape', 'foo' );

# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => '<p>message</p>',
        bar => '<b>23</b>',
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label class="labels_with_errors" for="widget_foo" id="widget_foo_label">Foo<span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" size="30" type="text" value="&#38;lt;p&#38;gt;message&#38;lt;/p&#38;gt;" /></span></label><span class="error_messages" id="widget_foo_errors"><span class="integer_errors" id="widget_foo_error_integer">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" value="&#60;b&#62;23&#60;/b&#62;" /></span><span class="error_messages" id="widget_bar_errors"><span class="integer_errors" id="widget_bar_error_integer">Invalid Input</span></span></fieldset></form>
EOF
}

my $w2 = HTML::Widget->new;

$w2->element( 'Textfield', 'foo' )->value('foo')->size(30)->label('Foo');
$w2->element( 'Textfield', 'bar' );

$w2->constraint( 'Integer', 'foo' );
$w2->constraint( 'Integer', 'bar' );

$w2->filter('HTMLEscape');

# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => '<p>message</p>',
        bar => '<b>23</b>',
    });

    my $f = $w2->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label class="labels_with_errors" for="widget_foo" id="widget_foo_label">Foo<span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" size="30" type="text" value="&#38;lt;p&#38;gt;message&#38;lt;/p&#38;gt;" /></span></label><span class="error_messages" id="widget_foo_errors"><span class="integer_errors" id="widget_foo_error_integer">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" value="&#38;lt;b&#38;gt;23&#38;lt;/b&#38;gt;" /></span><span class="error_messages" id="widget_bar_errors"><span class="integer_errors" id="widget_bar_error_integer">Invalid Input</span></span></fieldset></form>
EOF
}

my $w3 = HTML::Widget->new;

$w3->element( 'Textfield', 'foo' )->value('foo')->size(30)->label('Foo');
$w3->element( 'Textfield', 'bar' );

$w3->constraint( 'Integer', 'foo' );
$w3->constraint( 'Integer', 'bar' );

$w3->filter('HTMLEscape');

# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => [ '<p>message1</p>', '<p>message2</p>' ],
        bar => [ '<b>23</b>',         '<b>32</b>' ]
    });

    my $f = $w3->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><label class="labels_with_errors" for="widget_foo" id="widget_foo_label">Foo<span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" size="30" type="text" value="&#38;lt;p&#38;gt;message1&#38;lt;/p&#38;gt;" /></span></label><span class="error_messages" id="widget_foo_errors"><span class="integer_errors" id="widget_foo_error_integer">Invalid Input</span><span class="integer_errors" id="widget_foo_error_integer">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_bar" name="bar" type="text" value="&#38;lt;b&#38;gt;23&#38;lt;/b&#38;gt;" /></span><span class="error_messages" id="widget_bar_errors"><span class="integer_errors" id="widget_bar_error_integer">Invalid Input</span><span class="integer_errors" id="widget_bar_error_integer">Invalid Input</span></span></fieldset></form>
EOF
}

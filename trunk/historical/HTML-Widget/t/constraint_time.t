use Test::More;

BEGIN {
  eval { require Date::Calc };
  if ($@ =~ m{Can.t locate Date/Calc.pm}) {
    plan skip_all => "The Date constraint requires Date::Calc";
  } else {
    plan tests => 3;
  }
}

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'hour' );
$w->element( 'Textfield', 'minute' );
$w->element( 'Textfield', 'second' );

$w->constraint( 'Time', 'hour', 'minute', 'second' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({
        hour => '6',
        minute => '12',
        second => '9',
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_hour" name="hour" type="text" value="6" /><input class="textfield" id="widget_minute" name="minute" type="text" value="12" /><input class="textfield" id="widget_second" name="second" type="text" value="9" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({
        hour => '6',
        minute => '400',
        second => '5',
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_hour" name="hour" type="text" value="6" /></span><span class="error_messages" id="widget_hour_errors"><span class="time_errors" id="widget_hour_error_time">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_minute" name="minute" type="text" value="400" /></span><span class="error_messages" id="widget_minute_errors"><span class="time_errors" id="widget_minute_error_time">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_second" name="second" type="text" value="5" /></span><span class="error_messages" id="widget_second_errors"><span class="time_errors" id="widget_second_error_time">Invalid Input</span></span></fieldset></form>
EOF
}

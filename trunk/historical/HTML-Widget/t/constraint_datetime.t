use Test::More;

BEGIN {
  eval { require Date::Calc };
  if ($@ =~ m{Can.t locate Date/Calc.pm}) {
    plan skip_all => "The Datetime constraint requires Date::Calc";
  } else {
    plan tests => 3;
  }
}

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'year' );
$w->element( 'Textfield', 'month' );
$w->element( 'Textfield', 'day' );
$w->element( 'Textfield', 'hour' );
$w->element( 'Textfield', 'month' );
$w->element( 'Textfield', 'second' );

$w->constraint( 'DateTime', 'year', 'month', 'day', 'hour', 'minute',
    'second' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({
        year   => '2005',
        month  => '12',
        day    => '9',
        hour   => '10',
        minute => '25',
        second => '13'
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_year" name="year" type="text" value="2005" /><input class="textfield" id="widget_month" name="month" type="text" value="12" /><input class="textfield" id="widget_day" name="day" type="text" value="9" /><input class="textfield" id="widget_hour" name="hour" type="text" value="10" /><input class="textfield" id="widget_month" name="month" type="text" value="12" /><input class="textfield" id="widget_second" name="second" type="text" value="13" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({
        year   => '2005',
        month  => '11',
        day    => '500',
        hour   => '10',
        minute => '15',
        second => '23'
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_year" name="year" type="text" value="2005" /></span><span class="error_messages" id="widget_year_errors"><span class="datetime_errors" id="widget_year_error_datetime">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_month" name="month" type="text" value="11" /></span><span class="error_messages" id="widget_month_errors"><span class="datetime_errors" id="widget_month_error_datetime">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_day" name="day" type="text" value="500" /></span><span class="error_messages" id="widget_day_errors"><span class="datetime_errors" id="widget_day_error_datetime">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_hour" name="hour" type="text" value="10" /></span><span class="error_messages" id="widget_hour_errors"><span class="datetime_errors" id="widget_hour_error_datetime">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_month" name="month" type="text" value="11" /></span><span class="error_messages" id="widget_month_errors"><span class="datetime_errors" id="widget_month_error_datetime">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_second" name="second" type="text" value="23" /></span><span class="error_messages" id="widget_second_errors"><span class="datetime_errors" id="widget_second_error_datetime">Invalid Input</span></span></fieldset></form>
EOF
}

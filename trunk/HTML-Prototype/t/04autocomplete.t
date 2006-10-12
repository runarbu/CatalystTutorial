use strict;
use Test::More tests => 3;
BEGIN { use_ok('HTML::Prototype') }

my @test_cases = (
	{
		case => '1 auto_complete_field test',
		id   => 'test',
		options => {},
		result => <<"RESULT",
<script type="text/javascript">
<!--
new Ajax.Autocompleter( 'test', 'test_auto_complete', '' )
//-->
</script>
RESULT
	},
	{
		case => '2 auto_complete_field test',
		id   => 'acomp',
		options => { url => '/autocomplete', indicator => 'acomp_stat' },
		result => <<"RESULT",
<script type="text/javascript">
<!--
new Ajax.Autocompleter( 'acomp', 'acomp_auto_complete', '/autocomplete', { indicator: 'acomp_stat' } )
//-->
</script>
RESULT
	}
);

my $prototype = HTML::Prototype->new();

foreach my $test (@test_cases) {
	my $auto_complete_field = $prototype->auto_complete_field($test->{id}, $test->{options});
	ok( $auto_complete_field eq $test->{result}, $test->{case} );
}

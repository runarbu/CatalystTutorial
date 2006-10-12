use strict;
use warnings;

use Test::More;

eval "use DBD::SQLite";
plan skip_all => 'needs DBD::SQLite for testing' if $@;

plan tests => 10;

use lib 't/lib';

use_ok('SweetTest');

my ( $pager, $it ) = SweetTest::CD->page(
    {},
    { order_by => 'title',
      rows => 3,
      page => 1 } );
      
cmp_ok( $pager->entries_on_this_page, '==', 3, "entries_on_this_page ok" );

cmp_ok( $pager->next_page, '==', 2, "next_page ok" );

is( $it->next->title, "Caterwaulin' Blues", "iterator->next ok" );

$it->next;
$it->next;

is( $it->next, undef, "next past end of page ok" );

( $pager, $it ) = SweetTest::CD->page(
    {},
    { rows => 2,
      page => 2,
      disable_sql_paging => 1 } );

cmp_ok( $pager->total_entries, '==', 5, "disable_sql_paging total_entries ok" );

cmp_ok( $pager->previous_page, '==', 1, "disable_sql_paging previous_page ok" );

is( $it->next->title, "Caterwaulin' Blues", "disable_sql_paging iterator->next ok" );

$it->next;

is( $it->next, undef, "disable_sql_paging next past end of page ok" );

# based on a failing criteria submitted by waswas
( $pager, $it ) = SweetTest::CD->page(
    { title => [
        -and => 
            {
                -like => '%bees'
            },
            {
                -not_like => 'Forkful%'
            }
        ]
    },
    { rows => 5 }
);
is( $it->count, 1, "complex abstract count ok" );

use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 2;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

$html = $m->markdown(<<"EOF");
This is an H1
=============

This is an H2
-------------

# This is an H1

## This is an H2

### This is an H3

#### This is an H4

##### This is an H5

###### This is an H6

# This is an H1 #

## This is an H2 ##

### This is an H3 ####

#### This is an H4 ####

##### This is an H5 #####

###### This is an H6 ######
EOF

is_string($html, <<"EOF");
<h1>This is an H1</h1>

<h2>This is an H2</h2>

<h1>This is an H1</h1>

<h2>This is an H2</h2>

<h3>This is an H3</h3>

<h4>This is an H4</h4>

<h5>This is an H5</h5>

<h6>This is an H6</h6>

<h1>This is an H1</h1>

<h2>This is an H2</h2>

<h3>This is an H3</h3>

<h4>This is an H4</h4>

<h5>This is an H5</h5>

<h6>This is an H6</h6>
EOF

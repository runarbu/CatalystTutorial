package IM::View::TT;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config({
    INCLUDE_PATH => [
        IM->path_to( 'root/templates' ),
    ],
    PRE_PROCESS => 'startup.tt',
});

1;

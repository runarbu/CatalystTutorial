package CatalystX::Blog::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
    INTERPOLATE  => 1,
    UNICODE      => 1,
);

1;

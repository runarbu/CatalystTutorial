package Nameless::Element::Button;

use strict;
use warnings;
use base 'Nameless::Element';

__PACKAGE__->mk_element('button');
__PACKAGE__->mk_attributes({
    type => {
        type     => Params::Validate::SCALAR,
        default  => 'submit',
        optional => 1
    },
    name => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    value => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    disabled => {
        type     => Params::Validate::BOOLEAN,
        optional => 1
    },
    tabindex => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    accesskey => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
});

1;

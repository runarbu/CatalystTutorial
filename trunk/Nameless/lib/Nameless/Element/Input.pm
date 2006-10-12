package Nameless::Element::Input;

use strict;
use warnings;
use base 'Nameless::Element';

__PACKAGE__->mk_element('input');
__PACKAGE__->mk_attributes({
    type => {
        type     => Params::Validate::SCALAR,
        default  => 'text',
        optional => 1,
        regex    => qr/^text|password|checkbox|radio|submit|reset|file|hidden|image|button$/
    },
    name => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    value => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    checked => {
        type     => Params::Validate::BOOLEAN,
        optional => 1
    },
    disabled => {
        type     => Params::Validate::BOOLEAN,
        optional => 1
    },
    readonly => {
        type     => Params::Validate::BOOLEAN,
        optional => 1
    },
    size => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    maxlength => {
        type     => Params::Validate::SCALAR,
        optional => 1
    },
    src => {
        type     => Params::Validate::SCALAR,
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

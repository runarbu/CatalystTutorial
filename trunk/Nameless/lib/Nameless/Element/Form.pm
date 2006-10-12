package Nameless::Element::Form;

use strict;
use warnings;
use base 'Nameless::Element';

__PACKAGE__->mk_element('form');
__PACKAGE__->mk_attributes({
    action => {
        type      => Params::Validate::SCALAR,
        optional  => 1
    },
    method => {
        type      => Params::Validate::SCALAR,
        default   => 'get',
        optional  => 1
    },
    enctype => {
        type      => Params::Validate::SCALAR,
        default   => 'application/x-www-form-urlencoded',
        optional  => 1
    },
    accept_charset => {
        type      => Params::Validate::SCALAR,
        optional  => 1,
        attribute => 'accept-charset'
    },
    accept => {
        type      => Params::Validate::SCALAR,
        optional  => 1
    },
    name => {
        type      => Params::Validate::SCALAR,
        optional  => 1
    },
    target => {
        type      => Params::Validate::SCALAR,
        optional  => 1
    }
});

1;

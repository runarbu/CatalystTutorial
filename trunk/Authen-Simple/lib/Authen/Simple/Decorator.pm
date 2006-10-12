package Authen::Simple::Decorator;

use strict;
use warnings;
use base 'Authen::Simple::Base';

use Authen::Simple::Log qw[];
use Carp                qw[];
use Params::Validate    qw[];

our $AUTOLOAD;

__PACKAGE__->options({
    decorated => {
        type     => Params::Validate::OBJECT,
        can      => 'authenticate',
        optional => 0
    },
    log => {
        type     => Params::Validate::OBJECT,
        can      => [ qw[debug info error warn] ],
        default  => Authen::Simple::Log->new,
        optional => 1
    }
});

sub can {
    return shift->decorated->can(@_) if ref $_[0];
    return UNIVERSAL::can(@_);
}

sub isa {
    return shift->decorated->isa(@_) if ref $_[0];
    return UNIVERSAL::isa(@_);
}

sub authenticate {
    Carp::croak( ref $_[0] || $_[0]  . qq/->authenticate is an abstract method/ );
}

sub AUTOLOAD {
    my $self   = shift;
    my $method = substr( $AUTOLOAD, rindex( $AUTOLOAD, ':' ) + 1 );
    return $self->decorated->$method(@_);
}

sub DESTROY { }

1;

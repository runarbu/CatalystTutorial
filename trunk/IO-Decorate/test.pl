#!/usr/bin/perl

use strict;
use warnings;
use lib './lib';

use IO::Decorate;
use IO::Decorate::Tie;
use IO::File;

my $handle = IO::File->new_from_fd( fileno(STDOUT), 'w' );
$handle->print("Pain, Boring!\n");

$handle = MyDecorator->new($handle);
$handle->say("Decorated, Better!");
$handle->printf( "Decorator: %s\n", ref $handle->decorator );
$handle->printf( "Decorated a %s\n", ref $handle->decorated );
$handle->say("Decorated isa IO::Handle!") if $handle->isa('IO::Handle');
$handle->say("Decorated isa IO::File!") if $handle->isa('IO::File');

$handle = IO::Decorate::Tie->new($handle);
print $handle "Tied, Nice!\n";
say $handle "Ok!";

package MyDecorator;

use strict;
use warnings;
use base 'IO::Decorate';

sub printf { shift->print( sprintf( shift, @_ ) ) }
sub say    { shift->print( @_, "\n" )             }

sub print {
    my $self   = shift;
    my $stamp  = scalar localtime();
    my $string = join( '', @_ );
    $self->decorated->printf( "%-20s : %s", $stamp, $string );
}

1;

package Isotope::Object;

BEGIN {
    require Moose;
}

use strict;
use warnings;
use base 'Moose::Object';

1;

package Isotope::TypeConstraints;

use strict;
use warnings;

use Moose::Util::TypeConstraints qw[as coerce from subtype via where];
use Params::Coerce               qw[];

subtype 'CollectionRef'
    => as 'Ref'
    => where { ref $_ eq 'ARRAY' || ref $_ eq 'HASH' };

subtype 'Isotope::Headers'
    => as 'Object'
    => where { $_->isa('Isotope::Headers') };

coerce 'Isotope::Headers'
    => from 'ArrayRef'
        => via { Isotope::Headers->new( @{ $_ } ) }
    => from 'HashRef'
        => via { Isotope::Headers->new( %{ $_ } ) }
    => from 'Object'
        => via {
             if ( $_->isa('Isotope::Headers') ) {
                 return $_;
             }
             if ( $_->isa('HTTP::Headers') ) {
                 return Isotope::Headers->new->merge($_);
             }
        };

subtype 'Method'
    => as Str
    => where { /^[\x21\x23-\x27\x2A\x2B\x2D\x2E\x30-\x39\x41-\x5A\x5E-\x7A\x7C\x7E]+$/ };

subtype 'Protocol'
    => as 'Str'
    => where { /^HTTP\/[0-9]+\.[0-9]+$/ };

subtype 'Uri'
    => as 'Object'
    => where { $_->isa('URI') };

coerce 'Uri'
    => from 'Object'
        => via {

            if ( $_->isa('URI') ) {
                return $_;
            }

            require Params::Coerce;
            return  Params::Coerce::coerce( 'URI', $_ );

        }
    => from 'Str'
        => via { URI->new( $_, 'http' )->canonical };

1;

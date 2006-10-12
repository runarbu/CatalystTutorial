package Authen::Simple::Adapter;

use strict;
use warnings;
use base 'Authen::Simple::Base';

use Authen::Simple::Log      qw[];
use Authen::Simple::Password qw[];
use Carp                     qw[];
use Params::Validate         qw[SCALAR UNDEF];

__PACKAGE__->options({
    log => {
        type     => Params::Validate::OBJECT,
        can      => [ qw[debug info error warn] ],
        default  => Authen::Simple::Log->new,
        optional => 1
    }
});

sub authenticate {
    my $self  = shift;
    my $class = ref($self) || $self;

    my ( $username, $password, @extra ) = Params::Validate::validate_with(
        params      => \@_,
        spec        => [ ( { type => SCALAR | UNDEF } ) x 2 ],
        called      => "$class\::authenticate",
        allow_extra => 1
    );

    unless ( defined $username && length $username ) {

        my $bad = defined $username ? 'empty' : 'null';

        $self->log->debug( qq/An attempt to authenticate with a $bad username./ )
          if $self->log;

        return 0;
    }

    unless ( defined $password && length $password ) {

        my $bad = defined $password ? 'empty' : 'null';

        $self->log->debug( qq/An attempt to authenticate with a $bad password./ )
          if $self->log;

        return 0;
    }

    return $self->check( $username, $password, @extra );
}

sub check {
    Carp::croak( __PACKAGE__ . qq/->check is an abstract method/ );
}

sub check_password {
    my $self = shift;
    return Authen::Simple::Password->check(@_);
}

1;

__END__

=head1 NAME

Authen::Simple::Adapter - Adapter class for implementations

=head1 SYNOPSIS

    package Authenticate::Simple::Larry;
    
    use strict;
    use base 'Authen::Simple::Adapter';
    
    __PACKAGE__->options({
        secret => {
            type     => Params::Validate::SCALAR,
            default  => 'wall',
            optional => 1
        }
    });
    
    sub check {
        my ( $self, $username, $password ) = @_;
        
        if ( $username eq 'larry' && $password eq $self->secret ) {
            
            $self->log->debug( qq/Successfully authenticated user '$username'./ );
            
            return 1;
        }
        
        $self->log->debug( qq/Failed to authenticate user '$username'. Reason: 'Invalid credentials'/ );
        
        return 0;
    }
    
    1;

=head1 DESCRIPTION

Adapter class for implementations.

=head1 METHODS

=over 4

=item * new ( %parameters )

If overloaded, this method should take a hash of parameters. The following 
options should be valid:

=over 8
    
=item * log ( $ )

An object that supports C<debug>, C<info>, C<error> and C<warn>. Defaults to an 
instance of L<Authen::Simple::Log>.

    log => Authen::Simple::Log->new
    log => Log::Log4perl->get_logger('Authen::Simple')
    log => $r->log
    log => $r->server->log

=back

=item * init ( \%parameters )

This method is called after construction. It should assign parameters and return 
the instance.

    sub init {
        my ( $self, $parameters ) = @_;
        
        # mock with parameters
        
        return $self->SUPER::init($parameters);
    }

=item * authenticate ( $username, $password )

End user method. Validates parameters and calls C<check>.

=item * check ( $username, $password )

This must be overridden in a subclass. Takes two parameters, username and 
password. Should return true on success and false on failure.

=item * check_password( $password, $encrypted )

Verifies password. Takes two parameters, password and encrypted password.
Return true on success and false on failure.

See L<Authen::Simple::Password> for supported password formats.

=item * options ( \%options )

Must be set in subclass, should be a valid L<Params::Validate> specification. 
Accessors for options will be created unless defined in sublcass.

    __PACKAGE__->options({
        host => {
            type     => Params::Validate::SCALAR,
            optional => 0
        },
        port => {
            type     => Params::Validate::SCALAR,
            default  => 80,
            optional => 1
        }
    });

=back

=head1 SEE ALSO

L<Authen::Simple>

L<Authen::Simple::Password>

L<Params::Validate>

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut

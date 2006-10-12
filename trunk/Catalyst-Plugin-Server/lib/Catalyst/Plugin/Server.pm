### plugin implementation
{   package Catalyst::Plugin::Server;

    use strict;
    use warnings;
    use base qw/Class::Data::Inheritable/;

    our $VERSION = '0.20';

    my $ReqClass = 'Catalyst::Plugin::Server::Request';

    __PACKAGE__->mk_classdata('server');

    sub setup_dispatcher {
        my $class = shift;
        $class->NEXT::setup_dispatcher(@_);

        ### Load Server class
        $class->server(Catalyst::Plugin::Server::Backend->new($class));

        ### Load our custom request_class
        $class->request_class( $ReqClass );
    }

    sub prepare_action {
        my $c = shift;

        ### since we have a custom request class now, we have to
        ### be sure no one changed it from underneath us!
        unless( UNIVERSAL::isa( $c->req, $ReqClass ) ) {
            $c->log->warn(  "Request class no longer inherits from " .
                            "$ReqClass -- this may break things!" );
        }
        $c->NEXT::prepare_action( @_ );
    }
}

### plugin backend object
{   package Catalyst::Plugin::Server::Backend;

    use strict;
    use warnings;
    use base qw/Class::Accessor::Fast/;

    sub new {
        my $class = shift;
        my $c = shift;
        my $self = $class->SUPER::new( @_ );
    }

    sub register_server {
        my ($self, $name, $class) = @_;
        return unless ($name && $class);

        $self->mk_accessors($name);
        $self->$name($class);
    }
}

### the request class addition ###
{   package Catalyst::Plugin::Server::Request;

    use strict;
    use warnings;
    use Data::Dumper;

    use base qw/Catalyst::Request Class::Accessor::Fast/;

    *params = *parameters;

    sub register_server {
        my ($self, $name, $class) = @_;
        return unless ($name && $class);

        $self->mk_accessors($name);
        $self->$name($class);
    }
}

1;

__END__

=head1 NAME

Catalyst::Plugin::Server - Base Server plugin for RPC-able protocols

=head1 SYNOPSIS

    use Catalyst qw/
            Server
            Server::XMLRPC
        /;

   MyAPP->register_server('soap', $blessed_reference);


=head1 DESCRIPTION

Base plugin for XMLRPC and our future SOAP server. For further information,
see one of the Server plugins

=head1 SEE ALSO

L<Catalyst::Plugin::Server::XMLRPC>, L<Catalyst::Manual>,
L<Catalyst::Request>, L<Catalyst::Response>,  L<RPC::XML>,
C<bin/rpc_client>

=head1 AUTHORS

Jos Boumans (kane@cpan.org)

Michiel Ootjers (michiel@cpan.org)

=head1 BUG REPORTS

Please submit all bugs regarding C<Catalyst::Plugin::Server> to
C<bug-catalyst-plugin-server@rt.cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

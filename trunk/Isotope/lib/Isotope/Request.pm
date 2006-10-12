package Isotope::Request;

use strict;
use warnings;
use base 'Isotope::Message';

use prefork 'HTTP::Body';
use prefork 'URI::QueryParam';


use Errno               qw[];
use File::Spec::Unix    qw[];
use Scalar::Util        qw[];
use URI                 qw[];
use Isotope::Upload     qw[];
use Isotope::Exceptions qw[throw];
use Moose               qw[after has];

has 'base'     => ( isa       => 'Uri',
                    is        => 'rw',
                    coerce    => 1 );

has 'uri'      => ( isa       => 'Uri',
                    is        => 'rw',
                    coerce    => 1 );

has 'method'   => ( isa       => 'Method',
                    is        => 'rw' );

has 'path'     => ( isa       => 'Str',
                    is        => 'rw',
                    lazy      => 1,
                    required  => 1,
                    default   => sub { $_[0]->parse_path } );

has 'query'    => ( isa       => 'HashRef',
                    reader    => 'get_query',
                    writer    => 'set_query',
                    predicate => 'has_query',
                    required  => 1,
                    lazy      => 1,
                    default   => sub { $_[0]->parse_query } );

has 'param'    => ( isa       => 'HashRef',
                    reader    => 'get_param',
                    writer    => 'set_param',
                    predicate => 'has_param',
                    required  => 1,
                    lazy      => 1,
                    default   => sub { $_[0]->parse_content; $_[0]->get_param; } );


has 'upload'   => ( isa       => 'HashRef',
                    reader    => 'get_upload',
                    writer    => 'set_upload',
                    predicate => 'has_upload',
                    required  => 1,
                    lazy      => 1,
                    default   => sub { $_[0]->parse_content; $_[0]->get_upload; } );

sub referer {
    return shift->headers->referer(@_);
}

sub user_agent {
    return shift->headers->user_agent(@_);
}

BEGIN {
    foreach my $param ( qw[param query upload] ) {
        
        my $code = sprintf( <<'EOC', $param );
sub {
    my $self  = shift;
    my $param = $self->get_%s;

    if ( @_ == 0 ) {
        return wantarray ? keys %%{ $param } : $param;
    }

    if ( @_ == 1 ) {

        unless ( exists $param->{ $_[0] } ) {
            return wantarray ? () : undef;
        }

        if ( ref $param->{ $_[0] } eq 'ARRAY' ) {
            return wantarray ? @{ $param->{ $_[0] } } : $param->{ $_[0] }->[0];
        }
        else {
            return wantarray ? ( $param->{ $_[0] } ) : $param->{ $_[0] };
        }
    }

    if ( @_ == 2 && ! defined $_[1] ) {
        return delete $param->{ $_[0] };
    }

    return $param->{ $_[0] } = @_ > 2 ? [ @_[ 1 .. $#_ ] ] : $_[1];
}
EOC

        my $sub = eval $code;
        
        die $@ if $@;
        
        __PACKAGE__->meta->add_method( $param, $sub );
    }
}

sub parse_content {
    my $self = shift;

    my $param  = {};
    my $upload = {};

    $self->set_param($param);
    $self->set_upload($upload);

    return
      unless $self->method eq 'POST'
          && $self->has_content
          && (    $self->content_type eq 'application/x-www-form-urlencoded'
               || $self->content_type eq 'multipart/form-data' );
               

    # XXX refactor this.
    require HTTP::Body;

    my $type    = $self->header('Content-Type');
    my $length  = $self->content_length;
    my $content = $self->content_ref;

    my $parser  = HTTP::Body->new( $type, $length );     

    if ( ref $content eq 'SCALAR' ) {
        $parser->add($$content);
    }
    elsif ( my $handle = Scalar::Util::openhandle($content) ) {

        my ( $buffer, $r, $bufsize ) = ( undef, 0, 1024 * 1024 );

        while () {

            $r = $handle->sysread( $buffer, $bufsize );

            unless ( defined $r ) {

                next if $! == Errno::EINTR;

                throw message => qq/Could not read from request content handle./,
                      payload => $!;
            }

            last unless $r;
            
            $parser->add($buffer);
        }
    }
    else {
        throw qq/Can't handle request content '$content'./;
    }
    
    unless ( $parser->state eq 'done' ) {
        throw message => qq/Truncated request body./,
              status  => 400;
    }
    
    $param  = $parser->param;
    $upload = $parser->upload;
    
    foreach ( values %{ $upload } ) {
        
        foreach ( ref $_ eq 'ARRAY' ? @{ $_ } : $_ ) {
            $_->{headers}->{'Content-Length'} = delete $_->{size};
            $_ = Isotope::Upload->new( %{ $_ } );
        }
    }

    $self->set_param($param);
    $self->set_upload($upload);
}

sub parse_path {
    my $self = shift;
    
    throw qq/Request is in invalid state, required attribute uri is not set./
      unless $self->uri;

    throw qq/Request is in invalid state, required attribute base is not set./
      unless $self->base;

    my $path = $self->uri->path;
    my $base = $self->base->path;
    
    require File::Spec::Unix;

    for ( $path, $base ) {
        s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        $_ = File::Spec::Unix->canonpath($_);
        $_ = File::Spec::Unix->catdir( File::Spec::Unix->no_upwards( File::Spec::Unix->splitdir($_) ) );
    }

    # If base is not a prefix something is horribly wrong
    $path =~ s|^\Q$base\E||
      or throw qq/Request path '$path' does not have request base '$base' as prefix./;

    $path = File::Spec::Unix->catdir( '/', $path );

    return defined wantarray ? $path : $self->path($path);
}

sub parse_query {
    my $self  = shift;
    my $param = {};

    throw qq/Request is in invalid state, required attribute uri is not set./
      unless $self->uri;

    if ( $self->uri->query ) {

        # Request-URI should never be altered by Isotope
        my $query = $self->uri->query;
        my $clone = $self->uri->clone;

        $query =~ s/;/&/g;
        $clone->query($query);

        require URI::QueryParam;

        $param = $clone->query_form_hash;
    }

    return defined wantarray ? $param : $self->set_query($param);
}

1;

__END__

=head1 NAME

Isotope::Request - Isotope Request Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 INHERITANCE

=over 2

=item L<Isotope::Object>

=over 2

=item L<Isotope::Message>

=over 2

=item L<Isotope::Request>

=back

=back

=back

=head1 METHODS

=over 4

=item base

=item uri

=item path

    +---------------------------+----------------------+-------------------+
    | $request->uri->path       | $request->base->path | $request->path    |
    +---------------------------+----------------------+-------------------+
    | /cgi-bin/script.cgi/a/b/c | /cgi-bin/script.cgi/ | /a/b/c            |
    +---------------------------+----------------------+-------------------+
    | /location/a/%20b/c        | /location/           | /a/ b/c           |
    +---------------------------+----------------------+-------------------+
    | /static/image.png         | /                    | /static/image.png |
    +---------------------------+----------------------+-------------------+
    | /./../../a/b/c            | /                    | /a/b/c            |
    +---------------------------+----------------------+-------------------+
    | /                         | /                    | /                 |
    +---------------------------+----------------------+-------------------+

The part of the uri path that is not part of the base path.

=item method

=item referer

=item user_agent

=item param

    # get
    my @names   = $request->param;
    my $param   = $request->param;    
    my $value   = $request->param($name);
    my @values  = $request->param($name);
    
    # set
    $request->param( $name => $value   );
    $request->param( $name => @values  );
    
    # remove
    $request->param( $name => undef    );

=item query

    # get
    my @names   = $request->query;
    my $value   = $request->query($name);
    my @values  = $request->query($name);

    # set
    $request->query( $name => $value   );
    $request->query( $name => @values  );
    
    # remove
    $request->query( $name => undef    );

=item upload

    # get
    my @names   = $request->upload;
    my $upload  = $request->upload($name);
    my @uploads = $request->upload($name);

    # set
    $request->upload( $name => $upload   );
    $request->upload( $name => @uploads  );
    
    # remove
    $request->upload( $name => undef     );

=back

=head1 SEE ALSO

L<Isotope::Message>.

L<Isotope::Transaction>.

L<Isotope::Connection>.

L<Isotope::Response>.

L<Isotope::Upload>.

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut

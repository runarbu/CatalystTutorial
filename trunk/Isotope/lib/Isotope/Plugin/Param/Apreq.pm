package Isotope::Plugin::Param::Apreq;

use strict;
use warnings;
use base 'Isotope::Plugin';

use Isotope::Exceptions qw[throw];
use Isotope::Plugin     qw[OK DECLINED];
use Isotope::Upload     qw[];

sub register {
    my $self = shift;

    unless ( $self->engine->isa('Isotope::Engine::ModPerl') ) {
        return DECLINED;
    }

    if ( Isotope::Engine::ModPerl::MP10 ) {

        unless ( $INC{'Apache/Request.pm'} ) {

            eval {
                require Apache::Request;
            };

            if ( $@ ) {
                $self->log->warn("Could not load required class Apache::Request. Reason: '$@'.");
                return DECLINED;
            }
        }

        $self->register_hook( 'before_request_content' => 'parse_mp10' );

        return OK;
    }

    if ( Isotope::Engine::ModPerl::MP20 ) {

        unless ( Isotope::Engine::ModPerl->has_module('mod_apreq2.c') ) {
            $self->log->warn("Required Apache module mod_apreq2 is not loaded.");
            return DECLINED;
        }

        unless ( $INC{'Apache2/Request.pm'} ) {

            eval {
                require Apache2::Request;
                require Apache2::Upload;
            };

            if ( $@ ) {
                $self->log->warn("Could not load required class Apache2::Request. Reason: '$@'.");
                return DECLINED;
            }
        }

        $self->register_hook( 'before_request_content' => 'parse_mp20' );

        return OK;
    }
}

sub parse_mp10 {
    my ( $self, $t, $r ) = @_;

    return DECLINED
      unless $t->request->method eq 'POST'
          && (    $t->request->content_type eq 'application/x-www-form-urlencoded'
               || $t->request->content_type eq 'multipart/form-data' );

    $r = Apache::Request->new( $r, TEMP_DIR => $self->engine->tempdir );

    my $status = $r->parse;

    throw message => 'Could not parse request body.',
          payload => $r->notes('error-notes'),
          status  => $status
      unless $status == Isotope::Engine::ModPerl::OK;

    my $param  = {};
    my $upload = {};

    $r->param->do( sub {
        push @{ $param->{ $_[0] } }, $_[1];
        return 1;
    });

    for my $u ( $r->upload ) {

        my $object = Isotope::Upload->new(
            headers   => { 'Content-Length' => $u->size },
            filename  => $u->filename,
            tempname  => $u->tempname
        );

        $u->info->do( sub {
            $object->headers->add( $_[0] => $_[1] );
            return 1;
        });

        push( @{ $upload->{ $u->name } }, $object );
    }

    $t->request->set_param($param);
    $t->request->set_upload($upload);

    return OK;
}

sub parse_mp20 {
    my ( $self, $t, $r ) = @_;

    return DECLINED
      unless $t->request->method eq 'POST'
          && (    $t->request->content_type eq 'application/x-www-form-urlencoded'
               || $t->request->content_type eq 'multipart/form-data' );

    $r = Apache2::Request->new( $r, TEMP_DIR => $self->engine->tempdir );
    $r->discard_request_body;

    throw message => 'Could not parse request body.',
          status  => $r->body_status
      unless $r->body_status == Isotope::Engine::ModPerl::OK;

    my $param  = {};
    my $upload = {};

    $r->body->do( sub {
        push @{ $param->{ $_[0] } }, $_[1];
        return 1;
    });

    $r->upload->do( sub {

        my $object = Isotope::Upload->new(
            headers  => { 'Content-Length' => $_[1]->size },
            filename => $_[1]->filename,
            tempname => $_[1]->tempname
        );

        $_[1]->info->do( sub {
            $object->headers->add( $_[0] => $_[1] );
            return 1;
        });

        push @{ $upload->{ $_[0] } }, $object;

        return 1;
    });

    $t->request->set_param($param);
    $t->request->set_upload($upload);

    return OK;
}

1;

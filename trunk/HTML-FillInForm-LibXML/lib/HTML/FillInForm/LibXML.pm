package HTML::FillInForm::LibXML;

use strict;
use warnings;

use List::Util  qw[first];
use XML::LibXML qw[];

our $VERSION = 0.01;

sub new { bless( { ignore => {}, param => {}, objects => [] }, $_[0] ) }

sub fill {
    my ( $self, %option ) = @_;

    if ( my $fdat = $option{fdat} ) {
        local ( $self->{param} = $fdat );
    }

    if ( my $objects = $option{fobject} ) {
        $objects = [$objects] unless ref($objects) eq 'ARRAY';
        local( $self->{objects} = $objects );
    }

    if ( my $ignore = $option{ignore_fields} ) {
        $ignore = [$ignore] unless ref($ignore) eq 'ARRAY';
        local( $self->{ignore} = { map { $_ => 1 } @{$ignore} } );
    }

    my $document = $self->_parse_xhtml(%option);

    if ( my $target = $option{target} ) {

        my $xpath = sprintf( '//form[ @name = "%s" ]', $target );

        foreach my $form ( $document->findnodes($xpath) ) {
            $self->_populate($form);
        }
    }
    else {
        $self->_populate($document);
    }

    return $document->toString;
}

sub _parse_html {
    my ( $self, %options ) = @_;

    #local $SIG{__WARN__} = sub { };

    if ( my $file = $options{file} ) {
        return $self->_parser->parse_html_file($file);
    }
    elsif ( my $scalarref = $options{scalarref} ) {
        return $self->_parser->parse_html_string($$scalarref);
    }
    elsif ( my $arrayref = $options{arrayref} ) {
        return $self->_parser->parse_html_string("@$arrayref");
    }
}

sub _parse_xhtml {
    my ( $self, %options ) = @_;

    if ( my $file = $options{file} ) {
        return $self->_parser->parse_file($file);
    }
    elsif ( my $scalarref = $options{scalarref} ) {
        return $self->_parser->parse_string($$scalarref);
    }
    elsif ( my $arrayref = $options{arrayref} ) {
        return $self->_parser->parse_string("@$arrayref");
    }
}

sub _parser {
    my $self = shift;

    if (@_) {
        $self->{parser} = shift;
    }

    unless ( $self->{parser} ) {
        $self->{parser} = XML::LibXML->new;
        $self->{parser}->recover(1);
    }

    return $self->{parser};
}

sub _param {
    my ( $self, $param ) = @_;

    return () if exists $self->{ignore}->{$param};

    if ( exists $self->{param}->{$param} ) {
        return ( ref( $self->{param}->{$param} ) eq 'ARRAY' )
          ? @{ $self->{param}->{$param} }
          : $self->{param}->{$param};
    }

    foreach my $object ( @{ $self->{objects} } ) {

        if ( my @values = $object->param($param) ) {
            return @values;
        }
    }

    return ();
}

sub _populate {
    my ( $self, $parent ) = @_;

    my $xpath = '  descendant::input[    @type = "checkbox"
                                      or @type = "hidden"
                                      or @type = "text"
                                      or @type = "radio"
                                      or @type = "password" ]
                 | descendant::select
                 | descendant::textarea';

    foreach my $node ( $parent->findnodes($xpath) ) {

        my $name  = $node->getAttribute('name');
        my @param = $self->_param($name);

        next unless @param;

        if ( $node->nodeName eq 'input' ) {

            if ( $node->getAttribute('type') =~ /^hidden|password|text$/ ) {
                $node->setAttribute( 'value' => $param[0] );
            }
            elsif ( $node->getAttribute('type') eq 'checkbox' ) {

                unless ( $node->hasAttribute('value') ) {
                    $node->setAttribute( 'value' => 'on' );
                }

                if ( defined first { $node->getAttribute('value') eq $_ } @param ) {
                    $node->setAttribute( 'checked' => 'checked' );
                }
                else {
                    $node->removeAttribute('checked');
                }
            }
            elsif ( $node->getAttribute('type') eq 'radio' ) {

                unless ( $node->hasAttribute('value') ) {
                    $node->setAttribute( 'value' => 'on' );
                }

                if ( $node->getAttribute('value') eq $param[0] ) {
                    $node->setAttribute( 'checked' => 'checked' );
                }
                else {
                    $node->removeAttribute('checked');
                }
            }
        }
        elsif ( $node->nodeName eq 'select' ) {

            my $multiple = $node->hasAttribute('multiple');
            my $selected = 0;

            unless ($multiple) {
                @param = ( $param[0] );
            }

            foreach my $option ( $node->findnodes('descendant::option') ) {

                my $value = $option->hasAttribute('value')
                  ? $option->getAttribute('value')
                  : $option->textContent;

                if ( !$selected && defined first { $value eq $_ } @param ) {
                    $option->setAttribute( 'selected' => 'selected' );
                    $selected++ unless $multiple;
                }
                else {
                    $option->removeAttribute('selected');
                }
            }
        }
        elsif ( $node->nodeName eq 'textarea' ) {
            $node->removeChildNodes;
            $node->appendTextNode( $param[0] );
        }
    }
}

1;

__END__

=head1 NAME

HTML::FillInForm::LibXML - HTML::FillInForm::LibXML

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4 

=item new

Constructor.

=item fill

=back

=head1 BUGS

=head1 AUTHOR

Christian Hansen, C<ch@ngmedia.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

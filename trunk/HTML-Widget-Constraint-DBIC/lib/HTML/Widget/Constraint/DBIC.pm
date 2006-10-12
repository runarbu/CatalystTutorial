package HTML::Widget::Constraint::DBIC;

use warnings;
use strict;
use base 'HTML::Widget::Constraint';
use Carp qw( croak carp );

use Scalar::Util qw( looks_like_number );
require bytes;

__PACKAGE__->mk_accessors(qw/ class column /);

*col = \&column;

our $VERSION = '0.01';

=head1 NAME

HTML::Widget::Constraint::DBIC - DBIx::Class Column Constraints

=head1 SYNOPSIS

    my $widget = HTML::Widget->new;
    
    $widget->element( 'Textfield', 'name' );
    
    # Assuming that DBIC::Person is our DBIx::Class resultset classname
    
    $widget->constraint( 'DBIC', 'name' )->class( 'DBIC::Person' );

=head1 DESCRIPTION

DBIx::Class column constraints to ensure your user input can safely be
stored in your database.

=head1 METHODS

=head2 class

    $widget->constraint('DBIC', 'field')->class('OurClass');

We need to pass our resultset class.

=head2 column

=head2 col

    $widget->constraint('DBIC', 'field')->class('OurClass')->column('foo');

If our database columnname differs from the formfield name, we need to
set it.

C<col> is an alias to C<column>.

=head2 validate

=cut

sub validate {
    my ( $self, $value ) = @_;
    
    my $class = $self->class      or croak "class() required";
    my ($col) = @{ $self->names } or croak "column() required";
    
    my $column_info;
    eval { $column_info = $class->column_info( $col ) };
    croak $@ if $@;
    
    # Return valid on an empty value
    return 1 unless defined($value);
    return 1 if ($value eq '');
    
    my $datatype = $column_info->{data_type};
    my $callback;
    
    if ($datatype =~ /(char|text|binary)$/) {
        # char, varchar, *text, binary, varbinary
        $callback = $self->_string_callback( $column_info );
    }
    elsif ($datatype =~ /int$/) {
        $callback = $self->_int_callback( $column_info );
    }
    elsif ($datatype =~ /date|time/) { # date/datetime/time/timestamp
        carp "unimplemented";
    }
    elsif ($datatype =~ /^(enum|set)/) {
        $callback = $self->_set_callback( $column_info );
    }
    elsif ($datatype =~ /^decimal/) {
        $callback = $self->_decimal_callback( $column_info );
    }
    elsif ($datatype =~ /^(float|double)/) {
        $callback = $self->_float_callback( $column_info );
    }
    else {
        # default to char
        $callback = $self->_string_callback( $column_info );
    }
    
    return $callback->($value);
}

sub _string_callback {
    my ( $self, $column_info ) = @_;

    return sub {
        my ($value) = @_;
        
        $value =~ s/ +$//
            if $column_info->{ignore_trailing_spaces};
        
        my $maximum = $column_info->{size};
        my $failed  = 0;
        
        if ($maximum) {
            my $length = $column_info->{length_in_bytes} 
                       ? bytes::length( $value ) 
                       : length( $value );
        
            $failed++ unless ( $length <= $maximum );
        }
        return !$failed;
    }
}

sub _int_callback {
    my ( $self, $column_info ) = @_;

    return sub {
        my ($value) = @_;
        
        my $minimum = $column_info->{range_min};
        my $maximum = $column_info->{range_max};
        
        $value =~ /^-?[0-9]*$/
            or return;
        
        my $failed = 0;
        
        $failed++ if $column_info->{is_unsigned}
                     && $value < 0;
        
        $failed++ if $value < $minimum;
        $failed++ if $value > $maximum;

        return !$failed;
    }
}

sub _set_callback {
    my ( $self, $column_info ) = @_;

    return sub {
        my ($value) = @_;
        
        my $valids = $column_info->{data_set};
        
        return 1 unless @$valids;
        
        my $failed = 1;
        
        for my $try (@$valids) {
            $failed = 0 if $value eq $try;
        }
        
        return !$failed;
    }
}

sub _decimal_callback {
    my ( $self, $column_info ) = @_;

    return sub {
        my ($value) = @_;
        
        my $size   = $column_info->{size};
        my $digits = $column_info->{decimal_digits};
        my $int    = $size - $digits;
        my $regex;
        
        if ($column_info->{decimal_high_positive}) {
            $regex = qr/^
                        (?:
                          -[0-9]{0,$int}
                          |
                          [0-9]{0,$int+1}
                        )
                        (?:
                          \.[0-9]{0,$digits}
                        )?
                        $/x;
        }
        elsif ($column_info->{decimal_literal_range}) {
            $int -= 2;
            $regex = qr/^
                        (?:
                          -[0-9]{0,$int}
                          |
                          [0-9]{0,$int+1}
                        )
                        (?:
                          \.[0-9]{0,$digits}
                        )?
                        $/x;
        }
        else {
            $regex = qr/^
                        -?[0-9]{0,$int}
                        (?:
                          \.[0-9]{0,$digits}
                        )?
                        $/x;
        }
        
        return $value =~ $regex;
    }
}

sub _float_callback {
    my ( $self, $column_info ) = @_;

    return sub {
        my ($value) = @_;
        
        return looks_like_number( $value );
    }
}

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

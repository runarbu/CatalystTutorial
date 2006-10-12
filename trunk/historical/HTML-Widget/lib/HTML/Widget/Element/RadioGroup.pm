package HTML::Widget::Element::RadioGroup;

use warnings;
use strict;
use base 'HTML::Widget::Element';

__PACKAGE__->mk_accessors(qw/comment label options values labels comments value _current_subelement/);

=head1 NAME

HTML::Widget::Element::RadioGroup - Radio Element grouping

=head1 SYNOPSIS

    my $e = $widget->element( 'RadioGroup', 'foo', [qw/choice1 choice2/] );
    $e->comment('(Required)');
    $e->label('Foo'); # label for the whole thing
    $e->values([qw/foo bar gorch/]);
    $e->labels([qw/Fu Bur Garch/]); # defaults to ucfirst of values
    $e->comments([qw/funky/]); # defaults to empty
    $e->value("foo"); # the currently selected value

=head1 DESCRIPTION

RadioGroup Element.

An implicit L<In Constraint|HTML::Widget::Constraint::In> is
automatically added to every RadioGroup to ensure that only values
in C<$e->values> are considered valid.

=head1 METHODS

=head2 comment

Add a comment to this Element.

=head2 label

This label will be placed next to your Element.

=head2 values

List of form values for radio checks. Will also be used as labels if not otherwise specified viar L<labels>.

=head2 labels

The labels for corresponding l<values>.

=head2 options

A list of options in key => value format. Each key is the unique id of an
option tag, and its corresponding value is the text displayed in the element.

=head2 selected

A list of keys (unique option ids) which will be pre-set to "selected".

=cut

sub new {
    my ( $class, $opts ) = @_;

    my $self = $class->NEXT::new($opts);

    my $values = $opts->{values};

    $self->values($values);

    $self;
}

=head2 $self->prepare( $widget, $value )

=cut

sub prepare {
    my ( $self, $w, $value ) = @_;
    
    my $name = $self->name;
    
    # return if there's already an All constraint for this element
    for my $c ( $w->get_constraints(type => 'All') ) {
        if ($c->names && $c->names->[0] eq $name) {
            return;
        }
    }
    
    my %seen;
    my @uniq = grep { $seen{$_}++ == 0 ? $_ : 0 } @{ $self->values };
    
    $w->constraint( 'In', $name )->in( @uniq )
        if @uniq;
    
    return;
}

=head2 $self->containerize( $widget, $value, $errors )

=cut

sub containerize {
    my ( $self, $w, $value, $errors ) = @_;

    $value ||= $self->value || '';

    my $name = $self->name;
    my @values = @{ $self->values || [] };
    my @labels = @{ $self->labels || [] };
    @labels = map { ucfirst } @values unless @labels;
    my @comments = @{ $self->comments || [] };

    my $i;
    my @radios = map {
        $self->_current_subelement(++$i); # yucky hack

        my $radio = $self->mk_input( $w, {
            type    => 'radio',
            ($_ eq $value ? (checked => "checked" ) : () ),
            value   => $_,
        });

        $radio->attr( class => "radio" );

        my $label = $self->mk_label( $w, shift @labels, shift @comments );
        $label->unshift_content( $radio );

        $label;
    } @values;

    $self->_current_subelement( undef );

    #my $error = $self->mk_error( $w, $errors );

    # this should really be a legend attr for field
    my $l = $self->mk_label( $w, $self->label, $self->comment, $errors );
    $l->attr( for => undef ) if $l;

    return $self->container({
        element => HTML::Element->new('span')->push_content(@radios),
        error => scalar $self->mk_error( $w, $errors ),
		label => $l
    });
}

sub id {
	my ( $self, $w ) = @_;
	my $id = $self->SUPER::id( $w );
	my $subelem = $self->_current_subelement;

	return $subelem
		? "${id}_$subelem"
		: $id;
}


=head1 AUTHOR

Jess Robinson

Yuval Kogman

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

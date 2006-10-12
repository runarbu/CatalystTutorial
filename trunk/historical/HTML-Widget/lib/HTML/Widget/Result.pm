package HTML::Widget::Result;

use warnings;
use strict;
use base qw/HTML::Widget::Accessor/;
use HTML::Widget::Container;
use HTML::Widget::Error;
use HTML::Element;
use Storable 'dclone';

__PACKAGE__->mk_accessors(qw/attributes container legend subcontainer strict submitted element_container_class/);
__PACKAGE__->mk_attr_accessors(qw/action enctype id method empty_errors/);

use overload '""' => sub { return shift->as_xml }, fallback => 1;

*attrs       = \&attributes;
*name        = \&id;
*error       = \&errors;
*has_error   = \&has_errors;
*have_errors = \&has_errors;
*element     = \&elements;
*parameters  = \&params;
*tag         = \&container;
*subtag      = \&subcontainer;
*is_submitted = \&submitted;

=head1 NAME

HTML::Widget::Result - Result Class

=head1 SYNOPSIS

see L<HTML::Widget>

=head1 DESCRIPTION

Result Class.

=head1 METHODS

=head2 $self->action($action)

Contains the form action.

=head2 $self->as_xml

Returns xml.

=cut

sub as_xml {
    my $self = shift;

    my $element_container_class = $self->{element_container_class};

    my $c = HTML::Element->new( $self->container, id => $self->name );
    $self->attributes( {} ) unless $self->attributes;
    $c->attr( $_ => ${ $self->attributes }{$_} )
      for ( keys %{ $self->attributes } );

    my $params = dclone $self->{_params};

    my %javascript;
    if ( @{ $self->{_embedded} } ) {
        for my $embedded ( @{ $self->{_embedded} } ) {
            for my $js_callback ( @{ $self->{_js_callbacks} } ) {
                my $javascript = $js_callback->( $embedded->name );
                for my $key ( keys %$javascript ) {
                    $javascript{$key} .= $javascript->{$key}
                      if $javascript->{$key};
                }
            }
            next unless $embedded->{_elements};
            my $sc =
              HTML::Element->new( $self->subcontainer, id => $embedded->name );
            if ( my $legend = $embedded->legend ) {
                my $l =
                  HTML::Element->new( 'legend',
                    id => $embedded->name . "\_legend" );
                $l->push_content($legend);
                $sc->push_content($l);
            }
            my $oldname = $embedded->name;
            my $element_container_class = $embedded->{element_container_class} || $element_container_class;
            for my $element ( @{ $embedded->{_elements} } ) {
                local $element->{container_class} = $element->container_class;
                $element->{container_class} = $element_container_class if $element_container_class;
                my $value = undef;
                my $name  = $element->{name};
                $value = $params->{$name} if ( $name && $params );
                my $container =
                  $element->containerize( $embedded, $value,
                    $self->{_errors}->{$name} );
                $params->{$name} = $value;
                $container->{javascript} ||= '';
                $container->{javascript} .= $javascript{$name}
                  if $javascript{$name};
                $sc->push_content( $container->as_list )
                  unless $element->passive;
            }
            $embedded->name($oldname);
            $c->push_content($sc);
        }
    }
    else {
        for my $js_callback ( @{ $self->{_js_callbacks} } ) {
            my $javascript = $js_callback->( $self->name );
            for my $key ( keys %$javascript ) {
                $javascript{$key} .= $javascript->{$key} if $javascript->{$key};
            }
        }
        my $sc = HTML::Element->new( $self->subcontainer );
        if ( my $legend = $self->legend ) {
            my $id = $self->name;
            my $l = HTML::Element->new( 'legend', id => "$id\_legend" );
            $l->push_content($legend);
            $sc->push_content($l);
        }
        for my $element ( @{ $self->{_elements} } ) {
            local $element->{container_class} = $element->container_class;
            $element->{container_class} = $element_container_class if $element_container_class;
            my $value = undef;
            my $name  = $element->{name};
            $value = $params->{$name} if ( defined($name) && $params );
            my $container =
              $element->containerize( $self, $value, $self->{_errors}->{$name} );
            $params->{$name} = $value;
            $container->{javascript} ||= '';
            $container->{javascript} .= $javascript{$name}
              if $javascript{$name};
            $sc->push_content( $container->as_list ) unless $element->passive;
        }
        $c->push_content($sc);
    }
    return $c->as_XML;
}

=head2 $self->container($tag)

Contains the container tag.

=head2 $self->enctype($enctype)

Contains the form encoding type.

=head2 $self->error( $name, $type )

=head2 $self->errors( $name, $type )

Returns a list of L<HTML::Widget::Error> objects.

    my @errors = $form->errors;
    my @errors = $form->errors('foo');
    my @errors = $form->errors( 'foo', 'ASCII' );

=cut

sub errors {
    my ( $self, $name, $type ) = @_;

    return 0 if $name && !$self->{_errors}->{$name};
    
    my $errors = [];
    my @names = $name || keys %{ $self->{_errors} };
    for my $n (@names) {
        for my $error ( @{ $self->{_errors}->{$n} } ) {
            next if $type &&  $error->{type} ne $type;
            push @$errors, $error;
        }
    }
    return @$errors;
}

=head2 $self->element($name)

=head2 $self->elements($name)

Returns a L<HTML::Widget::Container> object for element
or a list of L<HTML::Widget::Container> objects for form.

    my @form = $f->element;
    my $age  = $f->element('age');

=cut

sub elements {
    my ( $self, $name ) = @_;

    my $element_container_class = $self->{element_container_class};
	
    my %javascript;
    for my $js_callback ( @{ $self->{_js_callbacks} } ) {
        my $javascript = $js_callback->( $self->name );
        for my $key ( keys %$javascript ) {
            $javascript{$key} .= $javascript->{$key} if $javascript->{$key};
        }
    }
    my $params = dclone $self->{_params};
    my @form;
    for my $element ( @{ $self->{_elements} } ) {
        local $element->{container_class} = $element->container_class;
        $element->{container_class} = $element_container_class if $element_container_class;
        my $value = undef;
        my $ename = $element->{name};
        next if ( defined($name) && ( $ename ne $name ) );
        $value = $params->{$ename} if ( $ename && $params );
        my $container =
          $element->containerize( $self, $value, $self->{_errors}->{$ename} );
        $params->{$ename} = $value;
        $container->{javascript} ||= '';
        $container->{javascript} .= $javascript{$ename} if $javascript{$ename};
        return $container if $name;
        push @form, $container;
    }
    return @form;
}

=head2 $self->empty_errors(1)

Create spans for errors even when there's no errors.. (For AJAX validation validation)

=head2 $self->has_error($name);

=head2 $self->has_errors($name);

=head2 $self->have_errors($name);

Returns a list of element names.

    my @names = $form->has_errors;
    my $error = $form->has_errors($name);

=cut

sub has_errors {
    my ( $self, $name ) = @_;
    my @names = keys %{ $self->{_errors} };
    return @names unless $name;
    return 1 if grep { /$name/ } @names;
    return 0;
}

=head2 $self->id($id)

Contains the widget id.

=head2 $self->legend($legend)

Contains the legend.

=head2 $self->method($method)

Contains the form method.

=head2 $self->param($name)

Returns valid parameters with a CGI.pm-compatible param method. (read-only)

=cut

sub param {
    my $self = shift;

    if ( @_ == 1 ) {

        my $param = shift;

        my $valid = $self->valid($param);
        if ( !$valid || ( !exists $self->{_params}->{$param} ) ) {
            return wantarray ? () : undef;
        }

        if ( ref $self->{_params}->{$param} eq 'ARRAY' ) {
            return (wantarray)
              ? @{ $self->{_params}->{$param} }
              : $self->{_params}->{$param}->[0];
        }
        else {
            return (wantarray)
              ? ( $self->{_params}->{$param} )
              : $self->{_params}->{$param};
        }
    }

    return $self->valid;
}

=head2 $self->params($params)

=head2 $self->parameters($params)

Returns validated params as hashref.

=cut

sub params {
    my $self  = shift;
    my @names = $self->valid;
    my %params;
    for my $name (@names) {
        my @values = $self->param($name);
        if (@values > 1) {
            $params{$name} = \@values;
        } else {
            $params{$name} = $values[0];
        }
    }
    return \%params;
}

=head2 $self->subcontainer($tag)

Contains the subcontainer tag.

=head2 $self->strict($strict)

Only consider parameters that pass at least one constraint valid.

=head2 $self->valid

Returns a list of element names.

    my @names = $form->valid;
    my $valid = $form->valid($name);

=cut

sub valid {
    my ( $self, $name ) = @_;
    my @errors = $self->has_errors;
    my @names;
    if ( $self->strict ) {
        for my $constraint ( @{ $self->{_constraints} } ) {
            my $names = $constraint->names;
            push @names, @$names if $names;
        }
    }
    else {
        @names = keys %{ $self->{_params} };
    }
    my %valid;
  CHECK: for my $name (@names) {
        for my $error (@errors) {
            next CHECK if $name eq $error;
        }
        $valid{$name}++;
    }
    my @valid = keys %valid;
    return @valid unless $name;
    return 1 if grep { /$name/ } @valid;
    return 0;
}

=head2 add_valid <key>,<value>

Adds another valid value to the hash.

=cut 

sub add_valid {
    my  ($self, $key, $value ) = @_;
    $self->{_params}->{$key}=$value;
    return $value;
}

=head2 add_error

    $result->add_error({ name => 'foo' });

This allows you to add custom error messages after the widget has processed
the input params.

Accepts 'name', 'type' and 'message' arguments.
The 'name' argument is required. The default value for 'type' is 'Custom'.
The default value for 'message' is 'Invalid Input'.

An example of use.

    if ( ! $result->has_errors ) {
        my $user = $result->valid('username');
        my $pass = $result->valid('password');
        
        if ( ! $app->login( $user, $pass ) ) {
            $result->add_error({
                name => 'password',
                message => 'Incorrect Password',
            });
        }
    }

In this example, the C<$result> initially contains no errors. If the login()
is unsuccessful though, add_error() is used to add an error to the password
Element. If the user is shown the form again using C<$result->as_xml()>,
they will be shown an appropriate error message alongside the password
field.

=cut 

sub add_error {
    my ( $self, $args ) = @_;
    
    die "name argument required" unless defined $args->{name};
    
    $args->{type} = 'Custom' if not exists $args->{type};
    $args->{message} = 'Invalid Input' if not exists $args->{message};
    
    my $error = HTML::Widget::Error->new( $args );
    
    push @{ $self->{_errors}->{$args->{name}} }, $error;
    
    return $error;
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

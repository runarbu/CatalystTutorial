package HTML::Widget;

use warnings;
use strict;
use base 'HTML::Widget::Accessor';
use HTML::Widget::Result;
use Scalar::Util 'blessed';
use Carp qw/croak/;

# For PAR
use Module::Pluggable::Fast
  search =>
  [qw/HTML::Widget::Element HTML::Widget::Constraint HTML::Widget::Filter/],
  require => 1;

__PACKAGE__->plugins;

__PACKAGE__->mk_accessors(
    qw/container indicator legend query subcontainer uploads strict empty_errors element_container_class/
);
__PACKAGE__->mk_attr_accessors(qw/action enctype id method/);

use overload '""' => sub { return shift->attributes->{id} }, fallback => 1;

*const  = \&constraint;
*elem   = \&element;
*name   = \&id;
*tag    = \&container;
*subtag = \&subcontainer;
*result = \&process;
*indi   = \&indicator;

our $VERSION = '1.07';

=head1 NAME

HTML::Widget - HTML Widget And Validation Framework

=head1 SYNOPSIS

    use HTML::Widget;

    # Create a widget
    my $w = HTML::Widget->new('widget')->method('get')->action('/');

    # Add some elements
    $w->element( 'Textfield', 'age' )->label('Age')->size(3);
    $w->element( 'Textfield', 'name' )->label('Name')->size(60);
    $w->element( 'Submit', 'ok' )->value('OK');

    # Add some constraints
    $w->constraint( 'Integer', 'age' )->message('No integer.');
    $w->constraint( 'Not_Integer', 'name' )->message('Integer.');
    $w->constraint( 'All', 'age', 'name' )->message('Missing value.');

    # Add some filters
    $w->filter('Whitespace');

    # Process
    my $result = $w->process;
    my $result = $w->process($query);


    # Check validation results
    my @valid_fields   = $result->valid;
    my $is_valid       = $result->valid('foo');
    my @invalid_fields = $result->have_errors;
    my $is_invalid     = $result->has_errors('foo');;

    # CGI.pm-compatible! (read-only)
    my $value  = $result->param('foo');
    my @params = $result->param;

    # Catalyst::Request-compatible
    my $value = $result->params->{foo};
    my @params = keys %{ $result->params };


    # Merge widgets (constraints and elements will be appended)
    $widget->merge($other_widget);


    # Embed widgets (as fieldset)
    $widget->embed($other_widget);


    # Get list of elements
    my @elements = $widget->get_elements;

    # Get list of constraints
    my @constraints = $widget->get_constraints;

    # Get list of filters
    my @filters = $widget->get_filters;


    # Complete xml result
    [% result %]
    [% result.as_xml %]


    # Iterate over elements
    <form action="/foo" method="get">
    [% FOREACH element = result.elements %]
        [% element.field_xml %]
        [% element.error_xml %]
    [% END %]
    </form>


    # Iterate over validation errors
    [% FOREACH element = result.have_errors %]
        <p>
        [% element %]:<br/>
        <ul>
        [% FOREACH error = result.errors(element) %]
            <li>
                [% error.name %]: [% error.message %] ([% error.type %])
            </li>
        [% END %]
        </ul>
        </p>
    [% END %]

    <p><ul>
    [% FOREACH element = result.have_errors %]
        [% IF result.error( element, 'Integer' ) %]
            <li>[% element %] has to be an integer.</li>
        [% END %]
    [% END %]
    </ul></p>

    [% FOREACH error = result.errors %]
        <li>[% error.name %]: [% error.message %] ([% error.type %])</li>
    [% END %]


    # XML output looks like this (easy to theme with css)
    <form action="/foo/bar" id="widget" method="post">
        <fieldset>
            <label for="widget_age" id="widget_age_label"
              class="labels_with_errors">
                Age
                <span class="label_comments" id="widget_age_comment">
                    (Required)
                </span>
                <span class="fields_with_errors">
                    <input id="widget_age" name="age" size="3" type="text"
                      value="24" class="Textfield" />
                </span>
            </label>
            <span class="error_messages" id="widget_age_errors">
                <span class="Regex_errors" id="widget_age_error_Regex">
                    Contains digit characters.
                </span>
            </span>
            <label for="widget_name" id="widget_name_label">
                Name
                <input id="widget_name" name="name" size="60" type="text"
                  value="sri" class="Textfield" />
                <span class="error_messages" id="widget_name_errors"></span>
            </label>
            <input id="widget_ok" name="ok" type="submit" value="OK" />
        </fieldset>
    </form>

=head1 DESCRIPTION

Create easy to maintain HTML widgets!

Everything is optional, use validation only or just generate forms,
you can embed and merge them later.

The API was designed similar to other popular modules like
L<Data::FormValidator> and L<FormValidator::Simple>,
L<HTML::FillInForm> is also built in (and much faster).

This Module is very powerful, don't misuse it as a template system!

=head1 METHODS

=head2 new( [$name] )

Create a new HTML::Widget object. The name parameter will be used as the 
id of the form created by the to_xml method.

=cut

sub new {
    my ( $self, $name ) = @_;
    $self = bless {}, ( ref $self || $self );
    $self->container('form');
    $self->subcontainer('fieldset');
    $self->name( $name || 'widget' );
    return $self;
}

=head1 $self->action($action)

Get/Set the action associated with the form.

=head2 $self->container($tag)

Get/Set the tag used to contain the XML output when as_xml is called on the
HTML::Widget object.
Defaults to C<form>.

=head2 $self->element_container_class($class_name)

Get/Set the container_class override for all elements in this widget. If set to
non-zero value, process will call $element->container_class($class_name) for
each element. Defaults to not set.

See L<HTML::Widget::Element::container_class>.

=head2 $self->elem( $type, $name )

=head2 $self->element( $type, $name )

Add a new element to the Widget. Each element must be given at least a type, 
and a name. The name is used for an id attribute on the field created for the 
element. An L<HTML::Widget::Element> object is returned, which can be used to
set further attributes, please see the individual element classes for the 
methods specific to each one.

The type can be one of the following:

=over 4

=item L<HTML::Widget::Element::Button>

    my $e = $widget->element( 'Button', 'foo' );
    $e->value('bar');

Add a button element.

    my $e = $widget->element( 'Button', 'foo' );
    $e->value('bar');
    $e->content('<b>arbitrary markup</b>');
    $e->type('submit');

Add a button element which uses a C<button> html tag rather than an 
C<input> tag. The value of C<content> is not html-escaped, so may contain 
html markup.

=item L<HTML::Widget::Element::Checkbox>

    my $e = $widget->element( 'Checkbox', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->checked('checked');
    $e->value('bar');

Add a standard checkbox element.

=item L<HTML::Widget::Element::Hidden>

    my $e = $widget->element( 'Hidden', 'foo' );
    $e->value('bar');

Add a hidden field. This field is mainly used for passing previously gathered
data between multiple page forms.

=item L<HTML::Widget::Element::Password>

    my $e = $widget->element( 'Password', 'foo' );
    $e->comment('(Required)');
    $e->fill(1);
    $e->label('Foo');
    $e->size(23);
    $e->value('bar');

Add a password field. This is a text field that will not show the user what
they are typing, but show asterisks instead.

=item L<HTML::Widget::Element::Radio>

    my $e = $widget->element( 'Radio', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->checked('checked');
    $e->value('bar');

Add a radio button to a group. Radio buttons with the same name will work as
a group. That is, only one item in the group will be "on" at a time.

=item L<HTML::Widget::Element::RadioGroup>

    my $e = $widget->element( 'RadioGroup', 'name', ['foo', 'bar', 'baz'] );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->checked('bar');
    $e->value('bar');

This is a shortcut to add multiple radio buttons with the same name at the
same time. See above. (Note that the C<checked> method has a different meaning
here).

=item L<HTML::Widget::Element::Reset>

    $e = $widget->element( 'Reset', 'foo' );
    $e->value('bar');

Create a reset button. The text on the button will default to "Reset", unless
you call the value() method. This button resets the form to its original
values.

=item L<HTML::Widget::Element::Select>

    my $e = $widget->element( 'Select', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->size(23);
    $e->options( foo => 'Foo', bar => 'Bar' );
    $e->selected(qw/foo bar/);

Create a dropdown  or multi-select list element with multiple options. Options 
are supplied in a key => value list, in which the keys are the actual selected
IDs, and the values are the strings displayed in the dropdown.

=item L<HTML::Widget::Element::Span>

    my $e = $widget->element( 'Span', 'foo' );
    $e->content('bar');

Create a simple span tag, containing the given content. Spans cannot be
constrained as they are not entry fields.

=item L<HTML::Widget::Element::Submit>

    $e = $widget->element( 'Submit', 'foo' );
    $e->value('bar');

Create a submit button. The text on the button will default to "Submit", unless
you call the value() method. 

    $e = $widget->element( 'Submit', 'foo' );
    $e->value('bar');
    $e->src('image.png');
    $e->width(100);
    $e->height(35);

Create an image submit button. The button will be displayed as an image, 
using the file at url C<src>.

=item L<HTML::Widget::Element::Textarea>

    my $e = $widget->element( 'Textarea', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->cols(30);
    $e->rows(40);
    $e->value('bar');
    $e->wrap('wrap');

Create a textarea field. This is a multi-line input field for text.

=item L<HTML::Widget::Element::Textfield>

    my $e = $widget->element( 'Textfield', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->size(23);
    $e->maxlength(42);
    $e->value('bar');

Create a single line text field.

=item L<HTML::Widget::Element::Upload>

    my $e = $widget->element( 'Upload', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->accept('text/html');
    $e->maxlength(1000);
    $e->size(23);

Create a field for uploading files. This will probably be rendered as a
textfield, with a button for choosing a file.

Adding an Upload element automatically calls
C<$widget->enctype('multipart/form-data')> for you.

=back

=cut

sub element {
    my ( $self, $type, $name ) = @_;
    my $element =
      $self->_instantiate( "HTML::Widget::Element::$type", { name => $name } );

    push @{ $self->{_elements} }, $element;

    return $element;
}

=head2 $self->get_elements()

    my @elements = $self->get_elements;
    
    my @elements = $self->get_elements( type => 'Textfield' );
    
    my @elements = $self->get_elements( name => 'username' );

Returns a list of all elements added to the widget.

If a 'type' argument is given, only returns the elements of that type.

If a 'name' argument is given, only returns the elements with that name.

=cut

sub get_elements {
    my ( $self, %opt ) = @_;

    if ( exists $opt{type} ) {
        my $type = "HTML::Widget::Element::$opt{type}";

        return grep { $_->isa($type) } @{ $self->{_elements} };
    }
    elsif ( exists $opt{name} ) {
        my $name = $opt{name};

        return grep { $_->name eq $name } @{ $self->{_elements} };
    }

    return @{ $self->{_elements} };
}

=head2 $self->const($tag)

=head2 $self->constraint( $type, @names )

Set up a constraint on one or more elements. When process() is called on the
Widget object, with a $query object, the parameters of the query are checked 
against the specified constraints. The L<HTML::Widget::Constraint> object is 
returned to allow setting of further attributes to be set. The string 'Not_' 
can be prepended to each type name to negate the effects. Thus checking for a 
non-integer becomes 'Not_Integer'.

Constraint checking is done after L<HTML::Widget::Filter>s have been applied.

@names should contain a list of element names that the constraint applies to. 
The type of constraint can be one of:

=over 4

=item L<HTML::Widget::Constraint::All>

    my $c = $widget->constraint( 'All', 'foo', 'bar' );

The fields passed to the "All" constraint are those which are required fields
in the form.

=item L<HTML::Widget::Constraint::AllOrNone>

    my $c = $widget->constraint( 'AllOrNone', 'foo', 'bar' );

If any of the fields passed to the "AllOrNone" constraint are filled in, then 
they all must be filled in.

=item L<HTML::Widget::Constraint::ASCII>

    my $c = $widget->constraint( 'ASCII', 'foo' );

The fields passed to this constraint will be checked to make sure their 
contents contain ASCII characters.

=item L<HTML::Widget::Constraint::Any>

    my $c = $widget->constraint( 'Any', 'foo', 'bar' );

At least one or more of the fields passed to this constraint must be filled.

=item L<HTML::Widget::Constraint::Callback>

    my $c = $widget->constraint( 'Callback', 'foo' )->callback(sub { 
        my $value=shift;
        return 1;
    });

This constraint allows you to provide your own callback sub for validation.

=item L<HTML::Widget::Constraint::Date>

    my $c = $widget->constraint( 'Date', 'year', 'month', 'day' );

This constraint ensures that the three fields passed in are a valid date. The
L<Date::Calc> module is required.

=item L<HTML::Widget::Constraint::DateTime>

    my $c =
      $widget->constraint( 'DateTime', 'year', 'month', 'day', 'hour',
        'minute', 'second' );

This constraint ensures that the six fields passed in are a valid date and 
time. The L<Date::Calc> module is required.

=item L<HTML::Widget::Constraint::DependOn>

    my $c =
      $widget->constraint( 'DependOn', 'foo', 'bar' );

If the first field listed is filled in, all of the others are required.

=item L<HTML::Widget::Constraint::Email>

    my $c = $widget->constraint( 'Email', 'foo' );

Check that the field given contains a valid email address, according to RFC
2822, using the L<Email::Valid> module.

=item L<HTML::Widget::Constraint::Equal>

    my $c = $widget->constraint( 'Equal', 'foo', 'bar' );

The fields passed to this constraint must contain the same information, or
be empty.

=item L<HTML::Widget::Constraint::HTTP>

    my $c = $widget->constraint( 'HTTP', 'foo' );

This constraint checks that the field(s) passed in are valid URLs. The regex
used to test this can be set manually using the ->regex method.

=item L<HTML::Widget::Constraint::In>

    my $c = $widget->constraint( 'In', 'foo' );
    $c->in( 'possible', 'values' );

Check that a value is one of a specified set.

=item L<HTML::Widget::Constraint::Integer>

    my $c = $widget->constraint( 'Integer', 'foo' );

Check that the field contents are an integer.

=item L<HTML::Widget::Constraint::Length>

    my $c = $widget->constraint( 'Length', 'foo' );
    $c->min(23);
    $c->max(50);

Ensure that the contents of the field are at least $min long, and no longer
than $max.

=item L<HTML::Widget::Constraint::Maybe>

    my $c = $widget->constraint( 'Maybe', 'foo', 'bar' );

=item L<HTML::Widget::Constraint::Printable>

    my $c = $widget->constraint( 'Printable', 'foo' );

The contents of the given field must only be printable characters. The regex
used to test this can be set manually using the ->regex method.

=item L<HTML::Widget::Constraint::Range>

    my $c = $widget->constraint( 'Range', 'foo' );
    $c->min(23);
    $c->max(30);

The contents of the field must be numerically within the given range.

=item L<HTML::Widget::Constraint::Regex>

    my $c = $widget->constraint( 'Regex', 'foo' );
    $c->regex(qr/^\w+$/);

Tests the contents of the given field(s) against a user supplied regex.

=item L<HTML::Widget::Constraint::String>

    my $c = $widget->constraint( 'String', 'foo' );

The field must only contain characters in \w. i.e. [a-zaZ0-9_]

=item L<HTML::Widget::Constraint::Time>

    my $c = $widget->constraint( 'Time', 'hour', 'minute', 'second' );

The three fields passed to this constraint must constitute a valid time. The
L<Date::Calc> module is required.

=back

=cut

sub constraint {
    my ( $self, $type, @names ) = @_;
    croak('constraint requires a constraint type') unless $type;
    my $not = 0;
    if ( $type =~ /^Not_(\w+)$/i ) {
        $not++;
        $type = $1;
    }
    my $constraint = $self->_instantiate( "HTML::Widget::Constraint::$type",
        { names => \@names } );
    $constraint->not($not);
    push @{ $self->{_constraints} }, $constraint;
    return $constraint;
}

=head2 $self->get_constraints()

    my @constraints = $self->get_constraints;
    
    my @constraints = $self->get_constraints( type => 'Integer' );

Returns a list of all constraints added to the widget.

If a 'type' argument is given, only returns the constraints of that type.

=cut

sub get_constraints {
    my ( $self, %opt ) = @_;

    if ( exists $opt{type} ) {
        my $type = "HTML::Widget::Constraint::$opt{type}";

        return grep { $_->isa($type) } @{ $self->{_constraints} };
    }

    return @{ $self->{_constraints} };
}

=head2 $self->embed(@widgets)

Insert the contents of another widget object into this one. Each embedded
object will be represented as another set of fields (surrounded by a fieldset
tag), inside the created form. No copy is made of the widgets to embed, thus
calling as_xml on the resulting object will change data in the widget objects.

=cut

sub embed {
    my ( $self, @widgets ) = @_;
    for my $widget (@widgets) {
        push @{ $self->{_embedded} }, $widget;
        push @{ $self->{_embedded} }, @{ $widget->{_embedded} }
          if $widget->{_embedded};
        push @{ $self->{_constraints} }, @{ $widget->{_constraints} }
          if $widget->{_constraints};
        push @{ $self->{_filters} }, @{ $widget->{_filters} }
          if $widget->{_filters};
        my $sc_id = $self->name . '_' . $widget->name;
        $widget->name($sc_id);
    }
    return $self;
}

=head2 $self->empty_errors(1)

After validation, if errors are found, a span tag is created with the id 
"fields_with_errors". Set this value to cause the span tag to always be 
generated.

=head2 $self->enctype($enctype)

Set/Get the encoding type of the form. This can be either "application/x-www-form-urlencoded" which is the default, or "multipart/form-data".
See L<http://www.w3.org/TR/html4/interact/forms.html#h-17.13.4>.

If the widget contains an Upload element, the enctype is automatically set to
'multipart/form-data'.

=head2 $self->filter( $type, @names )

Add a filter. Like constraints, filters can be applied to one or more elements.
These are applied to actually change the contents of the fields, supplied by
the user before checking the constraints. It only makes sense to apply filters
to fields that can contain text - Password, Textfield, Textarea, Upload.

There are currently two types of filter:

=over 4

=item L<HTML::Widget::Filter::Whitespace>

    my $f = $widget->filter( 'Whitespace', 'foo' );

Removes all whitespace from the given field(s).

=item L<HTML::Widget::Filter::TrimEdges>

    my $f = $widget->filter( 'TrimEdges', 'foo' );

Removes whitespace from the beginning and end of the given field(s).

=back


Returns a L<HTML::Widget::Filter> object.

=cut

sub filter {
    my ( $self, $type, @names ) = @_;
    my $filter =
      $self->_instantiate( "HTML::Widget::Filter::$type",
        { names => \@names } );
    $filter->init($self);
    push @{ $self->{_filters} }, $filter;
    return $filter;
}

=head2 $self->get_filters()

    my @filters = $self->get_filters;
    
    my @filters = $self->get_filters( type => 'Integer' );

Returns a list of all filters added to the widget.

If a 'type' argument is given, only returns the filters of that type.

=cut

sub get_filters {
    my ( $self, %opt ) = @_;

    if ( exists $opt{type} ) {
        my $type = "HTML::Widget::Filter::$opt{type}";

        return grep { $_->isa($type) } @{ $self->{_filters} };
    }

    return @{ $self->{_filters} };
}

=head2 $self->id($id)

Contains the widget id.

=head2 $self->indi($indicator)

=head2 $self->indicator($indicator)

Set/Get a boolean field. This is a convenience method for the user, so they 
can keep track of which of many Widget objects were submitted. It is also
used by L<Catalyst::Plugin::HTML::Wdget>

=head2 $self->legend($legend)

Set/Get a legend for this widget. This tag is used to label the fieldset. 

=head2 $self->merge(@widget)

Merge elements, constraints and filters from other widgets, into this one. The
elements will be added to the end of the list of elements that have been set
already.

=cut

sub merge {
    my ( $self, @widgets ) = @_;
    for my $widget (@widgets) {
        push @{ $self->{_elements} }, @{ $widget->{_elements} }
          if $widget->{_elements};
        push @{ $self->{_constraints} }, @{ $widget->{_constraints} }
          if $widget->{_constraints};
        push @{ $self->{_filters} }, @{ $widget->{_filters} }
          if $widget->{_filters};
    }
    return $self;
}

=head2 $self->method($method)

Set/Get the method used to submit the form. an be set to either "post" or
"get". The default is "post".

=head2 $self->result( $query, $uploads )

=head2 $self->process( $query, $uploads )

After finishing setting up the widget and all its elements, call either 
process() or result() to create an L<HTML::Widget::Result>. If passed a $query
it will run filters and validation on the parameters. The Result object can
then be used to produce the HTML.

=cut

sub process {
    my ( $self, $query, $uploads ) = @_;

    my $errors = {};
    $query   ||= $self->query;
    $uploads ||= $self->uploads;

    # Some sane defaults
    if ( $self->container eq 'form' ) {
        $self->attributes->{action} ||= '/';
        $self->attributes->{method} ||= 'post';
    }

    for my $element ( @{ $self->{_elements} } ) {
        $element->prepare($self);
        $element->init($self) unless $element->{_initialized};
        $element->{_initialized}++;
    }
    for my $filter ( @{ $self->{_filters} } ) {
        $filter->prepare($self);
        $filter->init($self) unless $filter->{_initialized};
        $filter->{_initialized}++;
    }
    for my $constraint ( @{ $self->{_constraints} } ) {
        $constraint->prepare($self);
        $constraint->init($self) unless $constraint->{_initialized};
        $constraint->{_initialized}++;
    }
    if ( $self->{_embedded} ) {
        for my $embedded ( @{ $self->{_embedded} } ) {
            for my $element ( @{ $embedded->{_elements} } ) {
                $element->prepare($self);
                $element->init($self) unless $element->{_initialized};
                $element->{_initialized}++;
            }
        }
    }

    my @js_callbacks;
    for my $constraint ( @{ $self->{_constraints} } ) {
        push @js_callbacks, sub { $constraint->process_js( $_[0] ) };
    }
    my %params;
    if ($query) {
        croak "Invalid query object"
          unless blessed($query)
          and $query->can('param');
        my @params = $query->param;
        for my $param (@params) {
            my @values = $query->param($param);
            $params{$param} = @values > 1 ? \@values : $values[0];
        }
        for my $element ( @{ $self->{_elements} } ) {
            my $results = $element->process( \%params, $uploads );
            for my $result ( @{$results} ) {
                my $name  = $result->name;
                my $class = ref $element;
                $class =~ s/^HTML::Widget::Element:://;
                $class =~ s/::/_/g;
                $result->type($class) if not defined $result->type;
                push @{ $errors->{$name} }, $result;
            }
        }
        for my $filter ( @{ $self->{_filters} } ) {
            $filter->process( \%params, $uploads );
        }
        for my $constraint ( @{ $self->{_constraints} } ) {
            my $results = $constraint->process( $self, \%params, $uploads );
            for my $result ( @{$results} ) {
                my $name  = $result->name;
                my $class = ref $constraint;
                $class =~ s/^HTML::Widget::Constraint:://;
                $class =~ s/::/_/g;
                $result->type($class);
                push @{ $errors->{$name} }, $result;
            }
        }
    }

    return HTML::Widget::Result->new(
        {
            attributes    => $self->attributes,
            container     => $self->container,
            _constraints  => $self->{_constraints},
            _elements     => $self->{_elements},
            _embedded     => $self->{_embedded} || [],
            _errors       => $errors,
            _js_callbacks => \@js_callbacks,
            _params       => \%params,
            legend        => $self->legend,
            subcontainer  => $self->subcontainer,
            strict        => $self->strict,
            empty_errors  => $self->empty_errors,
            submitted     => ( $query ? 1 : 0 ),
            element_container_class => $self->element_container_class,
        }
    );
}

=head2 $self->query($query)

Set/Get the query object to use for validation input. The query object can also
be passed to the process method directly.

=head2 $self->strict($strict)

Only consider parameters that pass at least one constraint valid.

=head2 $self->subcontainer($tag)

Set/Get the subcontainer tag to use.
Defaults to C<fieldset>.

=head2 $self->uploads($uploads)

Contains an arrayref of L<Apache2::Upload> compatible objects.

=cut

sub _instantiate {
    my ( $self, $class, @args ) = @_;
    eval "require $class";
    croak qq/Couldn't load class "$class", "$@"/ if $@;
    return $class->new(@args);
}

=head1 SEE ALSO

L<Catalyst> L<Catalyst::Plugin::HTML::Widget> L<HTML::Element>

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

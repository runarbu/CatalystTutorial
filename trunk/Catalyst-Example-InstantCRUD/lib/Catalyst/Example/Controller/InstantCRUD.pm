package Catalyst::Example::Controller::InstantCRUD;
use version; $VERSION = qv('0.0.6');
my $LOCATION; 
BEGIN { use File::Spec; $LOCATION = File::Spec->rel2abs(__FILE__) }

use warnings;
use strict;
use Carp;
use base 'Catalyst::Base';
use URI::Escape;
use HTML::Entities;
use Catalyst::Utils;
use HTML::Widget;
use Path::Class;
use Data::Dumper;
use DBIx::Class::Schema::Loader::Generic;

sub auto : Local {
    my ( $self, $c ) = @_;
    my $viewclass = ref $c->comp('^'.ref($c).'::(V|View)::');
    no strict 'refs';
    my $root   = $c->config->{root};
    my $libroot = file($LOCATION)->parent->subdir('templates');
    my @additional_paths = ("$root/" . lc $self->model_name, "$root", $libroot);
    $c->stash->{additional_template_paths} = \@additional_paths;
    my $table = $c->model( 'DBICSchemamodel' )->source( $self->model_name() );
    my @columns = $table->columns;
    my %labels = map { $_ => $table->column_info($_)->{label} } @columns;
    my %rels = map { $_ => $self->_relationship_attrs($table, $_) } $table->relationships;
    my %meth;
    for (keys %rels) {
	if ($rels{$_}{type} eq 'many_to_many') {
            $labels{$_} = $rels{$_}{label};
	    $meth{$_} = $rels{$_}{other_method};
	} elsif ($rels{$_}{type} eq 'has_many') {
            $labels{$_} = $rels{$_}{label};
	}
    }
    $c->stash->{columns} = \@columns;
    $c->stash->{rels} = \%rels;
    $c->stash->{labels} = \%labels;
    $c->stash->{meth} = \%meth;
    my @primary_keys = $table->primary_columns();
    $c->stash->{primary_key} = $primary_keys[0];
    for my $pkcol (@primary_keys){
        $c->stash->{pk}{$pkcol} = 1;
    }
    1;
}

sub model_name {
    my $self = shift;
    my $class = ref $self;
    $class =~ /([^:]*)$/;
    return $1;
}


sub index: Private {
    my ( $self, $c ) = @_;
    $c->forward('list');
}

sub destroy : Local {
    my ( $self, $c, $id ) = @_;
    if ( $c->req->method eq 'POST' ){
        my $model_object = $c->model('DBICSchemamodel::' . $self->model_name());
        $model_object->find($id)->delete;
        $c->forward('list');
    }else{
        my $w = HTML::Widget->new('widget')->method('post');
        $w->action ( $c->uri_for ( 'destroy', $id ));
        $w->element( 'Submit', 'ok' )->value('Delete ?');
        $c->stash->{destroywidget} = $w->process;
        $c->stash->{template} = 'destroy';
    }
}

sub do_add : Local {
    my ( $self, $c ) = @_;
    my $model        = $c->model( 'DBICSchemamodel' );
    my $table        = $model->source( $self->model_name() );
    my $model_object = $model->resultset( $self->model_name() );
    my $widget = $self->_build_widget($c);
    my $result = $widget->process($c->request);
    if($result->have_errors){
        $c->stash->{widget} = $result; 
        $c->stash->{template} = 'edit';
    }else{
        my %vals;
        foreach my $col ( @{$c->stash->{columns}} ) {
            next if $c->stash->{pk}{$col};
            $vals{$col} = $c->request->param( $col );
        }
	# Lets create a transaction because we are creating
	# items in diferent tables;
	my $item;
	$model->schema->txn_do( sub {
            $item = $model_object->create( \%vals );
	    # create the related items
	    for my $attrs ( map $self->_relationship_attrs($table, $_), $table->relationships ) {
	        if ($attrs->{type} eq 'many_to_many') {
	            for my $id ($c->req->param( $attrs->{rel_name} )) {
			next unless $id;
	                $item->create_related($attrs->{rel_name}, {
	    		    $attrs->{foreign_col}    => $item->id,
	    		    $attrs->{other_self_col} => $id,
	    	        });
	            }
	        } elsif ($attrs->{type} eq 'has_many') {
	            $model->resultset($attrs->{class})->search(
		      { $attrs->{self_col} => [ $c->req->param( $attrs->{rel_name} ) ] }
		    )->update({ $attrs->{foreign_col} => $item->id });
	        }
	    }
	});
        $c->forward('view', [ $item->id ] );
    }
}

sub _relationship_attrs {
    my ( $self, $table, $rel ) = @_;
    my $rel_info = $table->relationship_info($rel);
    my %attrs = ( %$rel_info, rel_name => $rel );
    @attrs{'foreign_col', 'self_col'} = %{$rel_info->{cond}};
    $attrs{foreign_col} =~ s/foreign\.//;
    $attrs{self_col} =~ s/self\.//;
    my $source = $table->schema->source($rel_info->{source}); 
    if ( $rel_info->{attrs}{accessor} eq 'multi' ) {
        my %rels = map { $_ => 1 } $source->relationships;
	# many-to-many ?
        if (keys %rels == 2 && delete $rels{$table->from}) {
	    $attrs{type} = 'many_to_many';
            my $other_rel_info = $source->relationship_info(keys %rels);
	    $attrs{"other_$_"} = $other_rel_info->{$_} for keys %$other_rel_info;
            @attrs{'other_foreign_col', 'other_self_col'} = %{$other_rel_info->{cond}};
	    $attrs{other_foreign_col} =~ s/foreign\.//;
	    $attrs{other_self_col} =~ s/self\.//;
            $attrs{other_method} = DBIx::Class::Schema::Loader::Generic->new
	      ->_inflect_relname($table->schema->class($attrs{other_class})->table);
            $attrs{label} = join ' ', map { ucfirst } split '_', $attrs{other_method};
	} else {
	    $attrs{type} = 'has_many';
            $attrs{label} = DBIx::Class::Schema::Loader::Generic->new
	      ->_inflect_relname($table->schema->class($attrs{class})->table);
            $attrs{label} = join ' ', map { ucfirst } split '_', $attrs{label};
	}
    } else {	
        $attrs{type} = 'belongs_to';
    }
    return \%attrs;
}

sub add: Local {
    my ( $self, $c ) = @_;
    my $w = $self->_build_widget($c);
    $w->action ( $c->uri_for ( 'do_add' ));
    $c->stash->{widget} = $w->process;
    $c->stash->{template} = 'edit';
}


sub _build_widget {
    my ( $self, $c, $id, $item ) = @_;
    my $model = $c->model( 'DBICSchemamodel' );
    my $table = $model->source( $self->model_name() );
    my $w = HTML::Widget->new($table->from)->method('post');
    for my $column ($table->columns){
        next if ( $column eq $c->stash->{primary_key} );
	my $info = $table->column_info($column);
	# Do we have belongs_to relationships?
        if ($table->relationship_info($column)) {
            my $rel_info = $table->relationship_info($column);
            my $rel_name = $rel_info->{class};
            my $ref_pk = ($model->source($rel_name)->primary_columns)[0];
            my @options = (0, '');
            foreach my $ref_item ($model->resultset($rel_name)->search) {
                push @options, $ref_item->$ref_pk(), "$ref_item";
            }
	    my $label = $info->{label} || join ' ', map { ucfirst } split '_', $column;
	    my $w_element = (ref $info->{widget_element} eq 'ARRAY' 
	      ? $info->{widget_element}[0] : $info->{widget_element})
	      || 'Select';
	    $w_element = 'Select' unless "HTML::Widget::Element::$w_element"->can('options');
            my $element = $w->element($w_element, $column)->label($label);
            $element->options(@options);
            $element->selected($item->$column->$ref_pk()) if $item;
	    next; # We don't want constrainsts in relations
        }
	# Is this a password field?
        elsif ( $column =~ /password|passwd/ ) {
	    my $label = $info->{label} || join ' ', map { ucfirst } split '_', $column;
	    my $size = $info->{size} || 40;
	    $size = 40 if $size > 40;
            $w->element('Password', $column)->label($label)->size($size);
            $w->element('Password', "$column\_2")->label($label)->size($size)->comment('(Confirm)');
        }
        else {
	    $self->_build_element($w, $column, $info, $item);
        }
	next if $table->relationship_info($column);
        for my $c ( @{ $info->{constraints} || [] } ){
		my $col = $c->{column}||'';
		my $msg = $c->{message}||'';
		warn "column: $col msg: $msg\n";
            my $const = $w->constraint( $c->{constraint}, ($column), $c->{args} ? @{$c->{args}} : () );
            $c->{$_} and $const->$_($c->{$_}) for qw/min max regex callback in message/;
        }
    }
    # has_many and many-to-many relationships
    for my $attrs ( map $self->_relationship_attrs($table, $_), $table->relationships ) {
	next if $attrs->{type} eq 'belongs_to'; # Already handled 
	my $class = $attrs->{type} eq 'many_to_many'
	  ? $attrs->{other_class} : $attrs->{class};
	my $label = $class;
	my @options = (0, '');
        my $ref_pk = ($model->source($class)->primary_columns)[0];
        foreach my $ref_item ($model->resultset($class)->search) {
		#warn "Option - value: " . $ref_item->$ref_pk . " name: $ref_item\n";
	    push @options, $ref_item->$ref_pk(), "$ref_item";
	}
	#my $w_element = (ref $info->{widget_element} eq 'ARRAY' 
	#  ? $info->{widget_element}[0] : $info->{widget_element})
	#  || 'Select';
	my $w_element = 'Select';
	$w_element = 'Select' unless "HTML::Widget::Element::$w_element"->can('options');
        my $element = $w->element($w_element, $attrs->{rel_name})->multiple(1)->size(5)->label($label);
        $element->options(@options);
        if ($item) {
	    my @selected = $item->search_related($attrs->{rel_name});
	    $element->selected([ map $_->$ref_pk, @selected ]);
        }
    }
    my $w1 = HTML::Widget->new('widget')->method('post');
    my $button = HTML::Widget->new('submit');
    if($id){
        $button->element( 'Submit', 'ok' )->value('Update');
        $w1->action ( $c->uri_for ( 'do_edit', $id ));
    }else{
        $button->element( 'Submit', 'ok' )->value('Create');
        $w1->action ( $c->uri_for ( 'do_add' ));
    }
    $w1->embed($w)->embed($button);
    return $w1;
}

sub _build_element {
    my ( $self, $w, $column, $info, $item ) = @_;
    my ($w_element, %attrs);
    my $label = $info->{label} || join ' ', map { ucfirst } split '_', $column;
    my $size = $info->{size} || 40;
    if (ref $info->{widget_element} eq 'ARRAY') {
	    $w_element = $info->{widget_element}[0];
	    %attrs = %{ $info->{widget_element}[1] } if ref $info->{widget_element}[1] eq 'HASH';
    } 
    $w_element ||= $size > 40 ? 'Textarea' : 'Textfield';
    if ($w_element eq 'Textarea') {
	$attrs{cols} ||= 40;
	$attrs{rows} ||= 5;
    }
    elsif ($w_element eq 'Textfield') {
	$attrs{size} ||= $size;
	$attrs{maxlength} ||= $size;
    }
    my $element = $w->element($w_element, $column)->label($label);
    $element->$_($attrs{$_}) for keys %attrs;
    $element->value($item->$column) if $item;
} 

sub do_edit : Local {
    my ( $self, $c, $id ) = @_;
    my $model        = $c->model( 'DBICSchemamodel' );
    my $table        = $model->source( $self->model_name() );
    my $model_object = $model->resultset( $self->model_name() );
    my $result = $self->_build_widget($c, $id)->process($c->request);
    if($result->have_errors){
        $c->stash->{widget} = $result; 
        $c->stash->{template} = 'edit';
    }else{
        my $item = $model_object->find($id);
        foreach my $col ( @{$c->stash->{columns}} ) {
            next if $c->stash->{pk}{$col};
            $item->$col ( $c->request->param( $col ) ) ;
        }
	
	# Lets create a transaction because we are updating
	# diferent tables;
	$model->schema->txn_do( sub {
	    for my $attrs ( map $self->_relationship_attrs($table, $_), $table->relationships ) {
	        if ($attrs->{type} eq 'many_to_many') {
		    $item->delete_related($attrs->{rel_name});
	            for my $id ($c->req->param( $attrs->{rel_name} )) {
			next unless $id;
	                $item->create_related($attrs->{rel_name}, {
	    		    $attrs->{foreign_col}    => $item->id,
	    		    $attrs->{other_self_col} => $id,
	    	        });
	            }
	        } elsif ($attrs->{type} eq 'has_many') {
		    my $related_objs = $item->search_related($attrs->{rel_name}, { 
			#$attrs->{foreign_col} => $item->id,
		        $attrs->{self_col} => { -not_in => [ $c->req->param( $attrs->{rel_name} ) ] },
		    });
	            # Let's try to put a NULL in the related objects FK
		    eval { $related_objs->update({ $attrs->{foreign_col} => undef }) } 
                    # If the relation can't be NULL the related objects must be deleted
		      || $related_objs->delete;
		    $model->resultset($attrs->{class})->search({
		        $attrs->{self_col} => [ grep $_, $c->req->param( $attrs->{rel_name} ) ]
		    })->update({ $attrs->{foreign_col} => $item->id });
		}
	    }
            $item->update;
	});
	
        $c->forward('view');
    }
}


sub edit : Local {
    my ( $self, $c, $id ) = @_;
    my $model_object = $c->model('DBICSchemamodel::' . $self->model_name());
    my $item = $model_object->find($id);
    my $w = $self->_build_widget($c, $id, $item)->process();
    $c->stash->{widget} = $w;
    $c->stash->{template} = 'edit';
}


sub create_page_link {
    my ( $c, $page, $origparams ) = @_;
    my %params = %$origparams;          # So that we don't change the params for good
    $params{page} = $page;
    my $result = '<a href="' . $c->uri_for( 'list?', \%params );
    $result .= '">' . $page . '</a>';
    return $result;
}

sub create_col_link {
    my ( $c, $column, $origparams ) = @_;
    my %params = %$origparams;          # So that we don't change the params for good
    delete $params{o2};
    delete $params{page};
    no warnings 'uninitialized';
    if(($origparams->{'order'} eq $column) and !$origparams->{'o2'}){
        $params{o2} = 'desc';
    }
    $params{order} = $column;
    my $result = '<a href="' . $c->uri_for( 'list?', \%params );
    $result .= '">' . $c->stash->{labels}{$column} . '</a>';
    if($origparams->{'order'} and $column eq $origparams->{'order'}){
        if($origparams->{'o2'}){
            $result .= "&darr;";
        }else{
            $result .= "&uarr;";
        }
    }
    return $result;
}

sub list : Local {
    my ( $self, $c ) = @_;
    my $params = $c->request->params;
    my $order = $params->{'order'};
    $order .= ' DESC' if $params->{'o2'};
    my $maxrows = 10;                             # number or rows on page
    my $page = $params->{'page'} || 1;
#    die  $self->model_name();
    my $model_object = $c->model('DBICSchemamodel::' . $self->model_name());
    $c->stash->{objects} = [
        $model_object->search(
            {},
            { 
                page => $page,
                order_by => $order,
                rows => $maxrows,
            },
        ) ];
    my $count = $model_object->count();
    $c->stash->{pages} = int(($count - 1) / $maxrows) + 1;
    $c->stash->{order_by_column_link} = sub {
        my $column = shift;
        return create_col_link($c, $column, $params);
    };
    $c->stash->{page_link} = sub {
        my $page = shift;
        return create_page_link($c, $page, $params );
    };
    $c->stash->{template} = 'list';
}

sub view : Local {
    my ( $self, $c, $id ) = @_;
    my $model_object = $c->model('DBICSchemamodel::' . $self->model_name());
    $c->stash->{item} = $model_object->find($id);
    $c->stash->{template} = 'view';
}


1; # Magic true value required at end of module
__END__

=head1 NAME

Catalyst::Example::Controller::InstantCRUD - Catalyst CRUD example Controller


=head1 VERSION

This document describes Catalyst::Example::Controller::InstantCRUD version 0.0.1


=head1 SYNOPSIS

    use base Catalyst::Example::Controller::InstantCRUD;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=head2 METHODS

=over 4

=item model_name
Class method for finding name of corresponding database table.

=item auto
This automatically called method puts on the stash path to templates
distributed with this module

=item add
Method for displaying form for adding new records

=item create_col_link
Subroutine placed on stash for templates to use.

=item create_page_link
Subroutine placed on stash for templates to use.

=item index
Forwards to list

=item destroy
Deleting records.

=item do_add
Method for adding new records

=item do_edit
Method for editin existing records

=item edit
Method for displaying form for editing a record.

=item list
Method for displaying pages of records

=item view
Method for diplaying one record

=back

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Catalyst::Example::Controller::InstantCRUD requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-catalyst-example-controller-instantcrud@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

<Zbigniew Lukasiak>  C<< <<zz bb yy @ gmail.com>> >>
<Lars Balker Rasmussen>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2005, <Zbigniew Lukasiak> C<< <<zz bb yy @ gmail.com>> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

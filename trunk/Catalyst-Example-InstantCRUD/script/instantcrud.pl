#!/usr/bin/perl -w

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;
use Getopt::Long;
use Pod::Usage;
use YAML 'LoadFile';
use File::Spec;
use File::Slurp;
use Catalyst::Helper;
use Catalyst::Utils;
use DBIx::Class::Schema::Loader;
use DBIx::Class::Schema::Loader::Generic;
use Data::Dumper;

my $help    = 0;
my $nonew   = 0;
my $scripts = 0;
my $short   = 0;
my $dsn;
my $duser;
my $dpassword;
my $appname;

GetOptions(
    'help|?'  => \$help,
    'nonew'   => \$nonew,
    'scripts' => \$scripts,
    'short'   => \$short,
    'name=s'    => \$appname,
    'dsn=s'     => \$dsn,
    'user=s'    => \$duser,
    'password=s'=> \$dpassword
);


pod2usage(1) if ( $help || !$appname );

my $helper =
  Catalyst::Helper->new(
    { '.newfiles' => !$nonew, 'scripts' => $scripts, 'short' => $short } );
pod2usage(1) unless $helper->mk_app( $appname );

my $appdir = $appname;
$appdir =~ s/::/-/g;
local $FindBin::Bin = File::Spec->catdir($appdir, 'script');
$helper->mk_component ( $appname, 'view', 'TT', 'TT');

$helper->mk_component ( $appname, 'model', 'DBICSchemamodel', 'DBIC::Schema', 
    'DBSchema',
    $dsn, $duser, $dpassword
);
$helper->mk_component ( $appname, 'controller', 'InstantCRUD', 'InstantCRUD',
    $dsn, $duser, $dpassword
);

my @appdirs = split /::/, $appname;
my $rootcontrl = File::Spec->catdir ( $appdir, 'lib',  @appdirs, ($short ? 'C' : 'Controller'), 'Root.pm') ;

my $rootcontrlcont = read_file($rootcontrl);
my $default = q{
sub default : Private {
    my ( $self, $c ) = @_;
    $c->response->status(404);
    $c->response->body("404 Not Found");
};
sub index : Private{
    my ( $self, $c ) = @_;
    my @additional_paths = ( $c->config->{root} );
    $c->stash->{additional_template_paths} = \@additional_paths;
    $c->stash->{template} = 'home';
}
};

$rootcontrlcont =~ s/sub default : Private [^}]*\}/$default/es;

#$rootcontrlcont =~ s{use base .*}{use base 'Catalyst::Example::Controller::InstantCRUD';};

write_file($rootcontrl, $rootcontrlcont) or die "Cannot write main application file";

#my @appdirs = split /::/, $appname;
$appdirs[$#appdirs] .= '.pm';
my $appfile = File::Spec->catdir ( $appdir, 'lib',  @appdirs ) ;
my $appfilecont = read_file($appfile);

$appfilecont =~ s{use Catalyst qw/(.*)/}
                 {use Catalyst qw/$1 DefaultEnd/};

write_file($appfile, $appfilecont) or die "Cannot write main application file";

my $config = q{
View::TT:
    WRAPPER: 'wrapper'
};

my $configname = Catalyst::Utils::appprefix ( $appname ) . '.yml';
my $appconfig = File::Spec->catdir ( $appdir, $configname ) ;
write_file( $appconfig, {append => 1}, $config) or die "Cannot uppend to $appconfig: $!";

{
  package DBSchema;
  use base qw/DBIx::Class::Schema::Loader/;
  __PACKAGE__->loader_options(relationships => 1, exclude => qr/^sqlite_sequence$/);
}
my $schema = DBSchema->connect($dsn, $duser, $dpassword);
    
my $sdir = File::Spec->catdir ( $appdir, 'lib', 'DBSchema' );
mkdir $sdir or die "Cannot create directory $sdir: $!";

my (%models, %models_content, %rels, %many_to_many_relation_table);

for my $s ( $schema->sources ) {
    my $source = $schema->source($s);
    my $c = $schema->class($s);
    my $table = $c->table;
    my @relationships = $c->relationships;
    my @pk = $source->primary_columns();
    my %columns;
    for my $col ($source->columns) {
	#$columns{$col} = $c->result_source->column_info($col);
        $columns{$col} = $source->column_info($col);
        delete $columns{$col}{$_} for grep /^_/, keys %{$columns{$col}};
        $columns{$col}{name} = $col;
        $columns{$col}{label} = join ' ', map { ucfirst } split '_', $col;
	#$columns{$col}{is_autoincrement} = 0;
        #$columns{$col}{is_foreign_key} = 0;
        # Let's create the constraints
        $columns{$col}{constraints} = [];
        if ( $columns{$col}{data_type} =~ /int/i ) {
            push @{$columns{$col}{constraints}},  {
                constraint => 'Integer',
                message => 'Should be a number',
            }
        }
        #if ( $source->storage->dbh->{Driver}->{Name} eq 'Pg' &&
        #    $columns{$col}{data_type} =~ /int/i ){
        #    $columns{$col}{size} = int( $columns{$col}{size} * 12 / 5 );
        #}
        if ( $columns{$col}{size} ){
            push @{$columns{$col}{constraints}},  {
                constraint => 'Length',
                message => "Should be shorten than $columns{$col}{size} characters",
                max => $columns{$col}{size},
            };
	    if ( $columns{$col}{size} > 40 ) {
                $columns{$col}{widget_element} = [
		    'Textarea' => { rows => 5, cols => 40 }
		];
            }
	    else {
                $columns{$col}{widget_element} = [
		    'Textfield' => { 
		        size      => $columns{$col}{size},
		        maxlength => $columns{$col}{size},
	             }
		];
            }
        }
        if ( !$columns{$col}{is_nullable} && !$columns{$col}{is_auto_increment}){
            push @{$columns{$col}{constraints}},  {
                constraint => 'All',
                message => "The field is required",
            }
        }
        if ( $col =~ /password|passwd/ ) {
            push @{$columns{$col}{constraints}},  {
                constraint => 'Equal',
		args => [ $col, "$col\_2" ],
		column => "$col\_2",
                message => "Passwords must match",
            }, {
                constraint => 'AllOrNone',
		args => [ $col, "$col\_2" ],
		column => "$col\_2",
                message => "Confirm the password",
            };
        }

    }
    (my $columns = Dumper \%columns) =~ s/^\$VAR1 = {|\s*};$//g;

    # And now the relationships
    my (@rel_type, @rel_info);
    for my $rel (@relationships) {
        my $info = $source->relationship_info($rel);
        push @rel_info, $info;
        my $d = Data::Dumper->new([@$info{qw(class cond)}]);
        $d->Purity(1)->Terse(1)->Deepcopy(1)->Indent(0);
        my $relationship = $info->{attrs}{accessor} eq 'multi' ? 'has_many' : 'belongs_to';
        push @rel_type, $relationship;
        $rels{$c} .= 
          "__PACKAGE__->$relationship('$rel', " . join(', ',$d->Dump) . ");\n";
    }
    my @cols = $source->columns;

    # Let's check if this table is for a many-to-many relationship.
    # If so then we create a many-to-many relationship in the related classes.
    # NOTE: This just handles the most common and simple case where exists a
    # table that has 2FK's to other two related tables,
    # both with a has_many relationship with first the table.
    if (scalar(@relationships) == 2 && scalar(@cols) == 2 &&
        scalar(grep {/belongs_to/} @rel_type) == 2) {
	my $inflector = DBIx::Class::Schema::Loader::Generic->new;
        my $other_class1 = $schema->class($rel_info[0]->{class});
        my $other_class2 = $schema->class($rel_info[1]->{class});
        my $other_rel_name = $inflector->_inflect_relname($table);
        my $other_rel_info1 = $other_class1->relationship_info($other_rel_name) ;
        my $other_rel_info2 = $other_class2->relationship_info($other_rel_name) ;
        if ($other_rel_info1 && $other_rel_info2) {
            $many_to_many_relation_table{$table} = 1;
            my $new_rel_name1 = $inflector->_inflect_relname($other_class1->table);
            my $new_rel_name2 = $inflector->_inflect_relname($other_class2->table);
            $rels{$other_class1} .= 
              "__PACKAGE__->many_to_many('$new_rel_name2', '$other_rel_name' => '$relationships[1]');\n";
            $rels{$other_class2} .= 
              "__PACKAGE__->many_to_many('$new_rel_name1', '$other_rel_name' => '$relationships[0]');\n";
        }
    }
    my $overload_method = $source->has_column('name') ? 'name' : $pk[0];
    $models_content{$c} = qq{package $c;

use strict;
use warnings;
use base 'DBIx::Class';
# Stringifies to the first primary key.
# Change it to what makes more sense.
# Is that value that appears in HTML Select's and things like that.
use overload '""' => sub {\$_[0]->$overload_method}, fallback => 1;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('$table');
__PACKAGE__->add_columns($columns);
__PACKAGE__->set_primary_key(qw/@pk/);
%s
1;};
}

# Write the files
for my $c ( map $schema->class($_), $schema->sources ) {
    my $table = $c->table;
    $c =~ /\W*(\w+)$/;
    my $modelfile = File::Spec->catdir ( $appdir, 'lib', 'DBSchema', "$1.pm" );
    $models{$table} = $1;
    write_file( $modelfile, sprintf $models_content{$c}, $rels{$c})
      or die "Cannot write to $modelfile: $!";
}

#my @models = values %models;
my $dbschema = qq{package DBSchema;

use base qw/DBIx::Class::Schema/;
__PACKAGE__->load_classes;
1;
};

my $schemafile =  File::Spec->catdir ( $appdir, 'lib', 'DBSchema.pm');
write_file( $schemafile, $dbschema ) or die "Cannot write to $schemafile: $!";

my $tfile =  File::Spec->catdir ( $appdir, 't', 'controller_InstantCRUD.t' );
unlink $tfile or die "Cannot remove $tfile - the wrong test file: $!";
my $table_menu = '| <a href="[% base %]">Home</a> |';
for my $table (grep !$many_to_many_relation_table{$_}, keys %models){
    $table_menu .= ' <a href="[% base %]' . lc $models{$table} . "\">$table</a> |";
}
my $table_menu_file = File::Spec->catdir ( $appdir, 'root', 'table_menu' );
write_file( $table_menu_file, $table_menu ) or die "Cannot write to $table_menu_file: $!";

my $home = q{
This is an application generated by  
<a href="http://search.cpan.org/~zby/Catalyst-Example-InstantCRUD-v0.0.9/lib/Catalyst/Example/InstantCRUD.pm">Catalyst::Example::InstantCRUD</a>
- a generator of simple database applications for the 
<a href="http://catalyst.perl.org">Catalyst</a> framework.
See also 
<a href="http://cpansearch.perl.org/dist/Catalyst/lib/Catalyst/Manual/Intro.pod">Catalyst::Manual::Intro</a>
and
<a href="http://cpansearch.perl.org/dist/Catalyst/lib/Catalyst/Manual/Tutorial.pod">Catalyst::Manual::Tutorial</a>
};

my $home_file = File::Spec->catdir ( $appdir, 'root', 'home' );
write_file( $home_file, $home) or die "Cannot write to $home_file: $!";

my $wrapper = q{
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>
            [% appname %]
        </title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <link title="Maypole" href="[%base%]static/pagingandsort.css" type="text
/css" rel="stylesheet"/>
    </head>
    <body>
        <div class="table_menu">
            [% PROCESS table_menu %]
        </div>
        <div class="content">
            [% content %]
        </div>
    </body>
</html>
};

my $wrapper_file = File::Spec->catdir ( $appdir, 'root', 'wrapper' );
write_file( $wrapper_file, $wrapper) or die "Cannot write to $wrapper_file: $!";


1;

__END__

=head1 NAME

instantcrud.pl - Bootstrap a Catalyst application example

=head1 SYNOPSIS

instantcrud.pl [options] 

 Options:
   -help       display this help and exits
   -nonew      don't create a .new file where a file to be created exists
   -scripts    update helper scripts only
   -short      use short types, like C instead of Controller...
   -name       application-name
   -dsn        dsn
   -user       database user
   -password   database password

 application-name must be a valid Perl module name and can include "::"

 Examples:
    instantcrud.pl -name=My::App -dsn='dbi:Pg:dbname=CE' -user=zby -password='pass'



=head1 DESCRIPTION

The C<catalyst.pl> script bootstraps a Catalyst application example, creating 
a directory structure populated with skeleton files.  

The application name must be a valid Perl module name.  The name of the
directory created is formed from the application name supplied, with double
colons replaced with hyphens (so, for example, the directory for C<My::App> is
C<My-App>).

Using the example application name C<My::App>, the application directory will
contain the following items:

=over 4

=item README

a skeleton README file, which you are encouraged to expand on

=item Build.PL

a C<Module::Build> build script

=item Changes

a changes file with an initial entry for the creation of the application

=item Makefile.PL

an old-style MakeMaker script.  Catalyst uses the C<Module::Build> system so
this script actually generates a Makeifle that invokes the Build script.

=item lib

contains the application module (C<My/App.pm>) and
subdirectories for model, view, and controller components (C<My/App/M>,
C<My/App/V>, and C<My/App/C>).  

=item root

root directory for your web document content.  This is left empty.

=item script

a directory containing helper scripts:

=over 4

=item C<my_app_create.pl>

helper script to generate new component modules

=item C<my_app_server.pl>

runs the generated application within a Catalyst test server, which can be
used for testing without resorting to a full-blown web server configuration.

=item C<my_app_cgi.pl>

runs the generated application as a CGI script

=item C<my_app_fastcgi.pl>

runs the generated application as a FastCGI script


=item C<my_app_test.pl>

runs an action of the generated application from the comand line.

=back

=item t

test directory

=back


The application module generated by the C<catalyst.pl> script is functional,
although it reacts to all requests by outputting a friendly welcome screen.


=head1 NOTE

Neither C<catalyst.pl> nor the generated helper script will overwrite existing
files.  In fact the scripts will generate new versions of any existing files,
adding the extension C<.new> to the filename.  The C<.new> file is not created
if would be identical to the existing file.  

This means you can re-run the scripts for example to see if newer versions of
Catalyst or its plugins generate different code, or to see how you may have
changed the generated code (although you do of course have all your code in a
version control system anyway, don't you ...).



=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Manual::Intro>

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>,
Andrew Ford, C<A.Ford@ford-mason.co.uk>
Zbigniew Lukasiak, C<zz bb yy@gmail.com> - modifications
Jonathan Manning

=head1 COPYRIGHT

Copyright 2004-2005 Sebastian Riedel. All rights reserved.

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut


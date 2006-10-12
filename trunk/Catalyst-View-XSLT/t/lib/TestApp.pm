package TestApp;

use strict;
use warnings;

use Catalyst; # qw/-Debug/;
use Path::Class;

our $VERSION = '0.01';

my $default_message = 'Hi, Catalyst::View::XSLT user';

__PACKAGE__->config(
    name                  => 'TestApp',
    default_message       => $default_message,
);

__PACKAGE__->setup;

sub default : Private {
    my ($self, $c) = @_;

    $c->response->redirect($c->uri_for('testParams'));
}

sub testRegisterFunction : Local {

	 my ($self, $c) = @_;
	 
	 $c->stash->{additional_register_function} = [
		{
			uri => 'urn:catalyst',
			name => 'test',
			subref => sub { return $default_message },
		},
	];
	
	$c->stash->{xml} = '<dummy-root/>';
	$c->stash->{template} = $c->request->param('template');
	
}

sub testParams : Local {
    my ($self, $c) = @_;

	$c->stash->{xml} = '<dummy-root/>';
    $c->stash->{template} = $c->request->param('template');
	my $message = $c->request->param('message') || $c->config->{default_message};
    $c->stash->{message} = $message;
}

sub testIncludePath : Local {
    my ($self, $c) = @_;

	$c->stash->{xml} = '<dummy-root/>';
    $c->stash->{template} = $c->request->param('template');
	my $message = $c->request->param('message') || $c->config->{default_message};
    $c->stash->{message} = $message;
	
    if ( $c->request->param('additionalpath') ){
        my $additionalpath = Path::Class::dir($c->config->{root}, $c->request->param('additionalpath'));
        $c->stash->{additional_template_paths} = ["$additionalpath"];
    }
}

sub testNoXSLT : Local {
    my ($self, $c) = @_;

	$c->stash->{xml} = '<dummy-root/>';
	my $message = $c->request->param('message') || $c->config->{default_message};
    $c->stash->{message} = $message;
}

sub end : Private {
    my ($self, $c) = @_;

    return 1 if $c->response->status =~ /^3\d\d$/;
    return 1 if $c->response->body;

    my $view = 'View::XSLT::' . ($c->request->param('view') || $c->config->{default_view});
    $c->forward($view);
}

1;

package Catalyst::Log::Log4perl;

=head1 NAME

Catalyst::Log::Log4perl - Log::Log4perl logging for Catalyst

=head1 SYNOPSIS

In MyApp.pm:

    use Catalyst::Log::Log4perl;

	# then we create a custom logger object for catalyst to use.
	# If we dont supply any arguments to new, it will work almost
	# like the default catalyst-logger.
	
    __PACKAGE__->log(Catalyst::Log::Log4perl->new());

	# But the real power of Log4perl lies in the configuration, so
	# lets try that. example.conf is included in the distribution,
	# alongside the README and Changes.
	
	__PACKAGE__->log(Catalyst::Log::Log4perl->new('example.conf'));
	
And later...

    $c->log->debug("This is using log4perl!");

=head1 DESCRIPTION

This module provides a L<Catalyst::Log> implementation that uses 
L<Log::Log4perl> as the underlying log mechanism.  It provides all
the methods listed in L<Catalyst::Log>, with the exception of:

    levels
    enable
    disable

These methods simply return 0 and do nothing, as similar functionality
is already provided by L<Log::Log4perl>.

These methods will all instantiate a logger with the component set to 
the package who called it.  For example, if you were in the 
MyApp::C::Main package, the following:

    package MyApp::C::Main;

    sub default : Private {
        my ( $self, $c ) = @_;
        my $logger = $c->log;
        $logger->debug("Woot!");
    }

Would send a message to the Myapp.C.Main L<Log::Log4perl> component.

See L<Log::Log4perl> for more information on how to configure different 
logging mechanisms based on the component.

=head1 METHODS

=over 4

=cut

use strict;
use Log::Log4perl;
use Log::Log4perl::Layout;
use Log::Log4perl::Level;
use Params::Validate;

our $VERSION = '0.4';

{
    my @levels = qw[ debug info warn error fatal ];

    for (my $i = 0; $i < @levels; $i++) {

        my $name  = $levels[$i];
        my $level = 1 << $i;

        no strict 'refs';
        *{$name} = sub {
            my ($self, @message) = @_;
            my ($package, $filename, $line) = caller;
            my $depth = $Log::Log4perl::caller_depth;
            unless ($depth > 0) {
                $depth = 1;
            }
            $self->_log([ $package, $name, $depth, \@message ]);
            return 1;
        };

        *{"is_$name"} = sub {
            my ($self, @message) = @_;
            my ($package, $filename, $line) = caller;
            my $logger = Log::Log4perl->get_logger($package);
            my $func   = "is_" . $name;
            return $logger->$func;
        };
    }
}

sub _log {
    my $self = shift;
    push @{ $self->{log4perl_stack} }, @_;
}

=item new($config, [%options])

This builds a new L<Catalyst::Log::Log4perl> object.  If you provide an argument
to new(), it will be passed directly to Log::Log4perl::init.  

The second (optional) parameter is a hash with extra options. Currently 
only two additional parameters are defined:

  'autoflush'   - Set it to a true value to disable abort(1) support.
  'watch_delay' - Set it to a true value to use L<Log::Log4perl>'s init_and_watch

Without any arguments, new() will initialize a root logger with a single appender,
L<Log::Log4perl::Appender::Screen>, configured to have an identical layout to
the default L<Catalyst::Log> object.

=cut

sub new {
    my $self    = shift;
    my $config  = shift;
    my %options = @_;

    my %foo;
    my $ref = \%foo;

    my $watch_delay = 0;
    if (exists($options{'watch_delay'})) {
        if ($options{'watch_delay'}) {
            $watch_delay = $options{'watch_delay'};
        }
    }
    unless (Log::Log4perl->initialized) {
        if (defined($config)) {
            if ($watch_delay) {
                Log::Log4perl::init_and_watch($config, $watch_delay);
            } else {
                Log::Log4perl::init($config);
            }
        } else {
            my $log      = Log::Log4perl->get_logger("");
            my $layout   = Log::Log4perl::Layout::PatternLayout->new("[%d] [catalyst] [%p] %m%n");
            my $appender = Log::Log4perl::Appender->new(
                "Log::Log4perl::Appender::Screen",
                'name'   => 'screenlog',
                'stderr' => 1,
            );
            $appender->layout($layout);
            $log->add_appender($appender);
            $log->level($DEBUG);
        }
    }

    $ref->{autoflush} = $options{autoflush} || 0;

    $ref->{abort}          = 0;
    $ref->{log4perl_stack} = [];

    bless $ref, $self;
    return $ref;
}

=item _flush()

Flushes the cache. Much like the way Catalyst::Log does it.

=cut

sub _flush {
    my ($self) = @_;

    my @stack = @{ $self->{log4perl_stack} };
    $self->{log4perl_stack} = [];
    if (!$self->{autoflush} and $self->{abort}) {
        $self->{abort} = 0;
        return 0;
    }

    foreach my $logmsg (@stack) {
        my ($package, $type, $depth, $message) = @$logmsg;
        local $Log::Log4perl::caller_depth = $depth;
        my $logger = Log::Log4perl->get_logger($package);
        $logger->$type(@$message);
    }
}

=item abort($abort)

Causes the current log-object to not log anything, effectivly shutting
up this request, making it disapear from the logs.

=cut

sub abort {
    my $self  = shift;
    my $abort = shift;
    $self->{abort} = $abort;
    return $self->{abort};
}

=item debug($message)

Passes it's arguments to $logger->debug.

=item info($message)

Passes it's arguments to $logger->info.

=item warn($message)

Passes it's arguments to $logger->warn.

=item error($message)

Passes it's arguments to $logger->error.

=item fatal($message)

Passes it's arguments to $logger->fatal.

=item is_debug()

Calls $logger->is_debug.

=item is_info()

Calls $logger->is_info.

=item is_warn()

Calls $logger->is_warn.

=item is_error()

Calls $logger->is_error.

=item is_fatal()

Calls $logger->is_fatal.

=item levels()

This method does nothing but return "0".  You should use L<Log::Log4perl>'s
built in mechanisms for setting up log levels.

=cut

sub levels {
    return 0;
}

=item enable()

This method does nothing but return "0".  You should use L<Log::Log4perl>'s
built in mechanisms for enabling log levels.

=cut

sub enable {
    return 0;
}

=item disable()

This method does nothing but return "0".  You should use L<Log::Log4perl>'s
built in mechanisms for disabling log levels.

=cut

sub disable {
    return 0;
}

1;

__END__

=back

=head1 SEE ALSO

L<Log::Log4perl>, L<Catalyst::Log>, L<Catalyst>.

=head1 AUTHOR

Adam Jacob, C<adam@stalecoffee.org>
Andreas Marienborg, C<omega@palle.net>
Gavin Henry, C<ghenry@suretecsystems.com> (Typos)

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

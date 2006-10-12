package Catalyst::Engine::JobQueue::POE;

use warnings;
use strict;
use base 'Catalyst::Engine::CGI';
use Carp;
use Data::Dumper;
use IO::File;
use Scalar::Util qw/refaddr/;

use POE;
use POE::Component::Cron;
use DateTime::Event::Cron;
use DateTime::Event::Random;

use Catalyst::Exception;

use version; our $VERSION = qv('0.0.1');

# Enable for helpful debugging information
sub DEBUG { $ENV{CATALYST_POE_DEBUG} || 0 } 

sub CGI_ENV_DEFAULTS {
    {
        REMOTE_ADDR     => '127.0.0.1',
        REMOTE_HOST     => 'localhost',
        REQUEST_METHOD  => 'GET',
        SERVER_NAME     => '127.0.0.1',
        SERVER_PORT     => 80,
        SERVER_PROTOCOL => 'HTTP/1.0',
    }
}

sub run { 
    my ( $self, $class, @args ) = @_;
    
    $self->spawn( $class, @args );
    
    POE::Kernel->run;
}

sub spawn {
    my ( $self, $class, $options ) = @_;
   
    $self->{config} = {
        appclass => $class,
        crontab  => $options->{crontab},
    };
    
    POE::Session->create(
        object_states => [
            $self => [
                qw/_start
                   _stop
                   shutdown
                   dump_state
                   
                   process

                   handle_prepare
                   prepare_done

                   handle_finalize
                   finalize_done

                   run_job
               /
           ],
       ],
   );
   
   return $self;
} 

# start the server
sub _start {
    my ( $kernel, $self, $session ) = @_[ KERNEL, OBJECT, SESSION ];

    $kernel->alias_set( 'catalyst-jobqueue-poe' );
    
    # make a copy of %ENV
    $self->{global_env} = \%ENV;

    # dump our state if we get SIGUSR1
    $kernel->sig( 'USR1', 'dump_state' );

    # shutdown on INT
    $kernel->sig( 'INT', 'shutdown' );

    DEBUG && print "Job Queue started\n";
    DEBUG && print "Parsing cron file $self->{config}{crontab}\n";
    $self->{config}{cron_entries} = _parse_crontab($self->{config}{crontab});

    DEBUG && print Dumper($self->{config}{cron_entries});
    foreach my $cron_entry (@{$self->{config}{cron_entries}}) {

        my $ID = refaddr($cron_entry);
        $self->{jobs}->{$ID} = $cron_entry;

        $cron_entry->{sched} = POE::Component::Cron->add(
            $session,
            'run_job',
            DateTime::Event::Cron->from_cron($cron_entry->{cronspec})->iterator( 
                span =>
                DateTime::Span->from_datetimes( 
                    start => DateTime->now,
                    end   => DateTime::Infinite::Future->new,
                ),
            ),
            $ID,
        );
        DEBUG && print "Job ID: $ID\n Data: " , Dumper($cron_entry);
    }
    
}

sub _stop { }

sub shutdown {
    my ( $kernel, $self ) = @_[ KERNEL, OBJECT ];

    $kernel->alias_remove( 'catalyst-jobqueue-poe' );

    DEBUG && warn "Shutting down...\n";
}

sub dump_state {
    my ( $kernel, $self ) = @_[ KERNEL, OBJECT ];

    my $job_count = scalar keys %{$self->{jobs}};
    warn "-- POE JobQueue state --";
    warn Dumper($self);
    warn "Active jobs: $job_count\n";
}

sub process {
    my ( $kernel, $self, $ID ) = @_[ KERNEL, OBJECT, ARG0 ];

    DEBUG && print "Processing request for job $ID\n";
    my $job = $self->{jobs}->{$ID};
    my $status = $self->{config}->{appclass}->handle_request( $ID );
    DEBUG && print "Got status $status from handler\n";
    $job->{last_status} = $status;

    # remove request specific data
    foreach my $key (qw/context env _prepare_done _finalize_done/) {
        delete $job->{$key};
    }

    if ($status >= 400 or $status == 0) {
        $kernel->yield( 'job_done', $ID);
    }
    else {
        # success
    }
}

sub prepare {
    my ( $self, $c, $ID ) = @_;

    DEBUG && print "Preparing for job $ID\n";

    # store ID in context (must retrieve from there in finalize)
    $c->{_POE_JOB_ID} = $ID;
    
    my $job = $self->{jobs}->{$ID};
    $job->{context} = $c;

    $job->{_prepare_done} = 0;

    $poe_kernel->yield( 'handle_prepare', 'prepare_request', $ID );
    $poe_kernel->yield( 'handle_prepare', 'prepare_connection', $ID );
    $poe_kernel->yield( 'handle_prepare', 'prepare_query_parameters', $ID );
    $poe_kernel->yield( 'handle_prepare', 'prepare_headers', $ID );
    $poe_kernel->yield( 'handle_prepare', 'prepare_cookies', $ID );
    $poe_kernel->yield( 'handle_prepare', 'prepare_path', $ID );

    # XXX Skip on-demand parsing stage 

    $poe_kernel->yield( 'prepare_done', $ID );

    # Wait until all prepare processing has completed, or we will return too
    # early
    # XXX: Is there a better way to handle this?
    while ( !$job->{_prepare_done} ) {
        $poe_kernel->run_one_timeslice();
    } 
}

sub finalize {
    my ( $self, $c ) = @_;

    my $ID = $c->{_POE_JOB_ID};
    my $job = $self->{jobs}->{$ID};

    $job->{_finalize_done} = 0;

    $poe_kernel->yield( 'handle_finalize', 'finalize_uploads', $ID );

    if ( $#{ $c->error } >= 0 ) {
        $poe_kernel->yield( 'handle_finalize', 'finalize_error', $ID );
    }

    $poe_kernel->yield( 'handle_finalize', 'finalize_headers', $ID );

    $poe_kernel->yield( 'handle_finalize', 'finalize_body', $ID );

    $poe_kernel->yield( 'finalize_done', $ID );

    while ( !$job->{_finalize_done} ) {
        $poe_kernel->run_one_timeslice();
    }
   
    return $c->response->status;
}

# handle_prepare localizes our per-client %ENV and calls $c->$method
# Allows plugins to do things during each step 
sub handle_prepare {
    my ( $kernel, $self, $method, $ID ) = @_[ KERNEL, OBJECT, ARG0, ARG1 ];

    DEBUG && warn "[Job $ID] - $method\n";
    my $job = $self->{jobs}->{$ID};
    
    {
        local (*ENV) = $job->{env};
        $job->{context}->$method();
    }     
}

sub prepare_done {
    my ( $kernel, $self, $ID ) = @_[ KERNEL, OBJECT, ARG0 ];

    DEBUG && warn "[Job $ID] prepare_done\n";
    my $job = $self->{jobs}->{$ID};

    $job->{_prepare_done} = 1;
}

sub handle_finalize {
    my ( $kernel, $self, $method, $ID ) = @_[ KERNEL, OBJECT, ARG0, ARG1 ];

    DEBUG && warn "[Job $ID] - $method\n";
    my $job = $self->{jobs}->{$ID};
   
    # Skip nulling response body on HEAD requests (doesn't make sense)

    $job->{context}->$method();
}

sub finalize_done {
    my ( $kernel, $self, $ID ) = @_[ KERNEL, OBJECT, ARG0 ];

    DEBUG && warn "[Job $ID] - finalize_done\n";
    my $job = $self->{jobs}->{$ID};

    $job->{_finalize_done} = 1;
}

sub job_done {
    my ( $kernel, $self, $ID ) = @_[ KERNEL, OBJECT, ARG0 ];

    my $job = $self->{jobs}->{$ID};
    DEBUG && warn "[Job $ID] STATUS: $job->{last_status}\n";

    # remove from scheduler cleanup job 
    $job->{sched}->delete();
    delete $self->{jobs}->{$ID};

    DEBUG && warn "[Job $ID] job_done\n";
}

sub run_job {
    my ( $kernel, $self, $ID ) = @_[ KERNEL, OBJECT, ARG0 ];

    my $job = $self->{jobs}->{$ID};
    
    DEBUG && print "Running request $job->{request}[0] as $job->{user}\n";
    DEBUG && print "Setting up CGI Env for request\n";
    $job->{env} = _make_cgi_env($job->{request}, $self->{global_env});
    $kernel->yield( 'process' , $ID );

}

sub _make_cgi_env
{
    my ( $request, $global_env ) = @_;

    my @req_copy = @{$request};
    my $path = shift @req_copy;
    my $query_string = join('&', @req_copy);

    my %env = %{ CGI_ENV_DEFAULTS() };
    $env{PATH_INFO}     = $path || '';
    $env{QUERY_STRING}  = $query_string;

    # merge with global env
    @env{ keys %{ $global_env } } = values %{ $global_env };

    return \%env;

}

sub _parse_crontab
{
    my $filename = shift;

    my $file = IO::File->new($filename, O_RDONLY) or
        Catalyst::Exception->throw( message => qq/ Couldn't open "$filename" 
            for reading, "$!"/  );

    my (@cron_entries);
    while(my $line = <$file>) {
        chomp $line;
        $line =~ s/#.*$//;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        next unless length $line;
        my @cron_line = split(/\s+/, $line);
        push @cron_entries, {
            cronspec => join(' ', splice (@cron_line, 0, 5)),
            user     => shift @cron_line,
            request  => \@cron_line,
        }
    }
    return \@cron_entries;
}

1; # Magic true value required at end of module
__END__

=head1 NAME

Catalyst::Engine::JobQueue::POE - Cron-like job runner engine


=head1 VERSION

This document describes Catalyst::Engine::JobQueue::POE version 0.0.1


=head1 SYNOPSIS

    use Catalyst::Engine::JobQueue::POE;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


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
  
Catalyst::Engine::JobQueue::POE requires no configuration files or environment variables.


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
C<bug-catalyst-engine-jobqueue-poe@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Kiki  C<< <kiki@abc.ro> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2006, Kiki C<< <kiki@abc.ro> >>. All rights reserved.

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

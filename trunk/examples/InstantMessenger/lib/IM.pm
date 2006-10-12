package IM;

use strict;
use warnings;

use Catalyst qw(
    -Debug

    DefaultEnd

    Unicode
    I18N

    Session
    Session::Store::DBI
    Session::State::Cookie

    Static::Simple

    Scheduler
);

__PACKAGE__->config->{session} = {
    expires     => 365*24*60*60,
    dbi_dsn     => 'dbi:SQLite:dbname='.IM->path_to('im.db'),
    dbi_user    => '',
    dbi_pass    => '',
    dbi_table   => 'sessions',
};

our $VERSION = 0.01;

__PACKAGE__->setup;

__PACKAGE__->schedule(
    at      => '0 0 1 * *',
    event   => '/cron/clean_sessions',
);

sub index : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'login.tt';
}

sub login : Local {
    my ( $self, $c ) = @_;
    $c->session->{author} = $c->req->params->{author} || 'anonymous';
    $c->model("Message")->create(
        {
            author  => 'im',
            content => $c->session->{author}.' has logged in.',
            posted  => time(),
        }
    );
    $c->res->redirect('/messages');
}

1;
__END__

=head1 NAME

IM - A Catalyst messageing application.

=head1 SYNOPSIS

  PerlHandler IM

=head1 DATABASE

Included in this distribution is an im.sql file.  Based on this create an SQLite 
database with the command:

  cat im.sql | sqlite3 im.db

Your web server will need read and write access to both the im.db file and the 
folder it resides in (your app path).  Sessions and messages will be stored in this 
database.

=head1 SESSIONS

Sessions have a life span of 1 year and are cleaned out every month useing 
L<Catalyst::Plugin::Scheduler>.  The sessions are managed useing 
L<Catalyst::Plugin::Session>, L<Catalyst::Plugin::Session::Store::DBI>, 
and L<Catalyst::Plugin::Session::State::Cookie>.

The session is used to store the login name (author), so that the next time 
someone comes back they IM will remember it.

=head1 SCHEDULER

The scheduler will need write access to a file called scheduler.state in your 
app path.  If you've set your app directory with write access for apache then 
this file will be created automatically.

=head1 AUTHORS

bluefeet and nothingmuch

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.


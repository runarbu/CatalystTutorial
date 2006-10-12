package Catalyst::Plugin::Timer;

use strict;
use Time::HiRes qw/gettimeofday tv_interval/;

our $VERSION = 0.1;

=head1 NAME

Catalyst::Plugin::Timer - Timer for profiling catalyst applications.

=head1 SYNOPSIS

    use Catalyst qw/-Debug Timer/;

    ... in an action somewhere ...

    $c->start_timer("foo");

    ...

    $c->stop_timer("foo");

    $c->timer("bar");

    ...

    $c->timer("bar");

=head1 DESCRIPTION

Simple timer for simple profiling of catalyst applications.

Bracket parts of your code that you suspect may be slow with
start_timer and stop_timer calls and you will see additional lines in
your debug output showing you how much time that chunk of code took.

If the same name is reused -- either because you used it twice, or
because it lies within a loop, or a subroutine which is called more
than once -- then just a single total accumulated time is displayed.

=head1 METHODS

=over 4

=item start_timer

=item stop_timer

=item timer

Starts and stops the timer. timer is an alias for lazy people who
don't like to type five more characters. It automatically calls start
or stop as appropriate.

=cut


our $timers;

sub start_timer {
  my ($c, $timername) = @_;
  my $actionname = "/".$c->action."#".$timername;
  $timers->{$actionname}->{start} = [gettimeofday];
}

sub stop_timer {
  my ($c, $timername) = @_;
  my $actionname = "/".$c->action."#".$timername;
  my $time = tv_interval (delete $timers->{$actionname}->{start});
  $timers->{$actionname}->{accum} += $time;
  $timers->{$actionname}->{count} ++;
}

sub timer {
  my ($c, $timername) = @_;
  my $actionname = "/".$c->action."#".$timername;
  if ($timers->{$actionname}->{start}) {
    stop_timer(@_);
  } else {
    start_timer(@_);
  }
}

sub finalize {
  my $c = shift;

  while (my ($name,$timer) = each %$timers) {
    my $statsline;
    if ($timer->{count} > 1) {
      $statsline = [$name." [total of ".$timer->{count}." calls]",
		    sprintf("%fs",$timer->{accum})];
    } else {
      $statsline = [$name,sprintf("%fs",$timer->{accum})];
    }
    push @{$c->{stats}},$statsline;
  }
  $timers = {};

  $c->NEXT::finalize(@_);
}

1;

=head1 SEE ALSO

L<Catalyst>

=head1 AUTHOR

Jules Bean, <jules@jellybean.co.uk>

=head1 THANKS

All the members of #catalyst for encouragement and advice.

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

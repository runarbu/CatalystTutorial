package Catalyst::Plugin::C3;

use strict;
use warnings;
use NEXT;
use Class::C3;

our $VERSION = '0.01000_05';

=head1 NAME

Catalyst::Plugin::C3 - Catalyst Plugin to subvert NEXT to use Class::C3

=head1 SYNOPSIS

Use it in an application:

  package MyCatApp;
  use Catalyst qw/ -Debug C3 Static::Simple /;

Use it in another plugin:

  package Catalyst::Plugin::FooBar;
  use base qw/ Catalyst::Plugin::C3 /;

=head1 DESCRIPTION

*** WARNING *** THIS MODULE IS NOT FOR GENERAL PUBLIC CONSUMPTION JUST YET.

This module is related to the possible transition of Catalyst from NEXT
to Class::C3.  This module is a developer release only, and is not intended
for any sort of production use by anyone at this time.  This module will
be upgraded to 0.02 and released if/when it seems like a good idea for
people other than Catalyst module developers to look at it and/or use it.

This module makes the use of the following idiom:

  use NEXT;

  sub foo {
    my $self = shift->NEXT::foo(@_);
  }

actually accomplish something more like:

  use Class::C3;

  sub foo {
    my $self = shift->next::method(@_);
  }

It does this by essentially pre-pending some functionality to
L<NEXT/AUTOLOAD> which transforms the call into L<Class::C3>'s
C<next::method> call, but only when certain specific conditions
are met.

Those conditions are that the object C<-E<gt>NEXT> is being
used on is a Catalyst-related object of some sort, and that the
inheritance heirarchy of the object's class is C3-compatible.

If either of those conditions do not hold true, the C<-E<gt>NEXT>
call should do things the normal L<NEXT> way.

If you are going to place this module in your plugins list for
a Catalyst app, it is best placed at the top of the list, above
all other plugins.  A good reason to stick this in your plugins
list is that it can give a noticeable performance boost in the
case that you're using lots of Plugins and other Catalyst
components which still use L<NEXT> rather than L<Class::C3>.

Some other plugins that have real end-user functionality may
require this plugin as a base-class in order to transition themselves
to L<Class::C3> without worrying about being broken by other plugins
which haven't made the transition.  Most plugins will *not* need
to do so.  Any that do would have wierd hacks involving C<*{NEXT::NEXT}>
in them prior to their C3 conversion, so you'd know it.

Or in other words, a plugin should only base on this plugin if it
needed L<NEXT> hacks to work right under L<NEXT>, and you're
transitioning it to use L<Class::C3>.

=head1 METHODS

=cut

# Hack NEXT::AUTOLOAD to use C3's ->next::method iff the object
#  ->isa Catalyst object of some sort AND the object has a C3-valid
#  inheritance heirarchy.
{
    my %__c3_mro_warn_once;
    my $__saved_next_autoload = \&NEXT::AUTOLOAD;

    sub __hacked_next_autoload {
        # $class is the class of the object ->NEXT::methodname was used on
        my $class = ref $_[0] || $_[0];

        my $wanted = $Catalyst::Plugin::C3::AUTOLOAD || 'NEXT::AUTOLOAD';
        my ($wanted_class, $wanted_method) = $wanted =~ m{(.*)::(.*)}g;
        goto &__saved_next_autoload if ! $class->isa('Catalyst::Component')
                                    && ! $class->isa('Catalyst::Action')
                                    && ! $class->isa('Catalyst::Request')
                                    && ! $class->isa('Catalyst::Response')
                                    && ! $class->isa('Catalyst::Engine')
                                    && ! $class->isa('Catalyst::Dispatcher')
                                    && ! $class->isa('Catalyst::DispatchType')
                                    && ! $class->isa('Catalyst::Exception')
                                    && ! $class->isa('Catalyst::Log');

        eval { Class::C3::calculateMRO($class) };
        if($@) {
            warn "Class::C3::calculateMRO('$class') Error: $@; Falling"
               . ' back to plain NEXT.pm behavior for this class'
                if ! $__c3_mro_warn_once{$class}++;
            goto &$__saved_next_autoload;
        }

        goto &next::method if $wanted_class =~ /^NEXT:.*:ACTUAL/;
        goto &next::method_ifcan; # XXX See Below
    }
}

# XXX This makes ->next::method_ifcan, which we need for goto/caller reasons
#   TODO: get a convenience method like this into the real Class::C3
package   # hide me from PAUSE
    next;

sub method_ifcan {
    return if !($_ = _find($_[0], 0));
    goto &$_;
}

package Catalyst::Plugin::C3;

=head2 handle_request

This plugin hooks into the C<handle_request> method, sets up a C<local>
override of the standard version of L<NEXT/AUTOLOAD> for the entire 
request, and then calls up the chain to the next class on the list.

=cut

sub handle_request {
    no warnings 'redefine';
    local *NEXT::AUTOLOAD = \&__hacked_next_autoload;
    shift->next::method(@_);
}

=head1 AUTHOR

Brandon Black C<blblack@gmail.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

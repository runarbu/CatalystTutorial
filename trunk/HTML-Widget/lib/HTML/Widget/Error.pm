package HTML::Widget::Error;

use warnings;
use strict;
use base 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw/name message type/);

use overload '""' => sub { return shift->message }, fallback => 1;

=head1 NAME

HTML::Widget::Error - Error

=head1 SYNOPSIS

    my @errors = $form->errors('foo');
    for my $error (@errors) {
        print $error->type;
        print $error->message;
    }
    
=head1 DESCRIPTION

Error.

=head1 METHODS

=head2 name

Arguments: $name

Return Value: $name

=head2 message

Arguments: $message

Return Value: $message

=head2 type

Arguments: $type

Return Value: $type

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

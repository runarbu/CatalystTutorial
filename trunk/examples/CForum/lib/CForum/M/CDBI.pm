package CForum::M::CDBI;

use strict;
use base 'Catalyst::Model::CDBI';

__PACKAGE__->config(
    dsn           => 'dbi:SQLite2:/home/marcus/src/CForum/db/cforum.db',
    user          => '',
    password      => '',
    options       => { },
    additional_classes      => qw/Class::DBI::Plugin::CountSearch/,
    relationships => 1
);

=head1 NAME

CForum::M::CDBI - CDBI Model Component


=head1 DESCRIPTION

The CDBI Loader component

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;

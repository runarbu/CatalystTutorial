package TestApp::Model::DBIC::User;

eval { require DBIx::Class }; return 1 if $@;
@ISA = qw/TestApp::Model::DBIC/;
use strict;

__PACKAGE__->table( 'user' );
__PACKAGE__->add_columns( qw/id username password session_data/ );
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    map_user_role => 'TestApp::Model::DBIC::UserRole' => 'user' );

*DBIx::Class::ResultSet::auto_create = sub {
    my ($self,$id,$password) = @_;
    return $self->create({ username => $id, password => $password });
};

eval { require Storable; require MIME::Base64 };
unless ($@) {
    __PACKAGE__->inflate_column(
        session_data => {
            inflate => sub { Storable::thaw(MIME::Base64::decode_base64(shift)) },
            deflate => sub { MIME::Base64::encode_base64(Storable::freeze(shift)) },
        }
    );
}

1;

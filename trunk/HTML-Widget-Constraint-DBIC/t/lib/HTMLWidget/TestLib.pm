package 
    HTMLWidget::TestLib;

use warnings;
use strict;
use Test::MockObject;

our %COLUMN;

sub fake_column {
    my ( $self, $spec ) = @_;
    
    my $col = delete $spec->{column} 
        or die "column required";
    
    $COLUMN{$col} = $spec;
}

sub column_info {
    my ( $class, $col ) = @_;
    
    return $COLUMN{$col};
}

sub mock_query {
    my ( $self, $data ) = @_;
    
    die "argument must be a hash-ref"
        if defined $data && ref($data) ne 'HASH';
    
    my $query = Test::MockObject->new;
    
    $query->mock( 'param',
       sub {
           my ( $self, $param ) = @_;
           if ( @_ == 1 ) { return keys %$data }
           else {
               unless ( exists $data->{$param} ) {
                   return wantarray ? () : undef;
               }
               if ( ref $data->{$param} eq 'ARRAY' ) {
                   return (wantarray)
                     ? @{ $data->{$param} }
                     : $data->{$param}->[0];
               }
               else {
                   return (wantarray)
                     ? ( $data->{$param} )
                     : $data->{$param};
               }
           }
       } 
    );
    
    return $query;
}

1;

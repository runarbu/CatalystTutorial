package Isotope::Log;

use strict;
use warnings;
use base 'Exporter';

BEGIN {
    my @levels    = qw[debug info warn error fatal];
    my %constants = ();

    for ( my $i = 0 ; $i < @levels ; $i++ ) {

        my $name = $levels[$i];
        my $mask = 1 << $i;

        no strict 'refs';

        *{$name} = sub {
            my $self = shift;

            if ( $self->level & $mask ) {
                $self->log( $name => @_ );
            }
        };

        *{"is_$name"} = sub {
            return $_[0]->level & $mask;
        };

        $constants{ 'LOG_' . uc $name } = $mask;
    }

    require constant;
    constant->import(\%constants);

    our @EXPORT_OK   = keys %constants;
    our %EXPORT_TAGS = ( levels => [ keys %constants ] );
}

sub new {
    my $class  = ref $_[0] ? ref shift : shift;
    my %params = ( level => LOG_DEBUG | LOG_INFO | LOG_WARN | LOG_ERROR | LOG_FATAL, @_ );
    return bless( \%params, $class );
}

sub category {
    return $_[0]->{category};
}

sub has_category {
    return defined $_[0]->{category} ? 1 : 0;
}

sub level {
    return $_[0]->{level};
}

sub log {
    my ( $self, $level, @message ) = @_;
    $self->output( $self->format( $level, "@message" ) );
}

sub format {
    my ( $self, $level, $message ) = @_;

    chomp($message);

    if ( $self->has_category ) {
        return sprintf "[%s] [%s] [%s] %s\n", scalar localtime(), $level, $self->category, $message;
    }
    else {
        return sprintf "[%s] [%s] %s\n", scalar localtime(), $level, $message;
    }
}

sub output {
    my ( $self, $message ) = @_;
    CORE::warn($message);
}

1;

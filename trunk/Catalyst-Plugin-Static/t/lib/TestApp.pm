package TestApp;

use Catalyst qw[-Engine=Test Static];
use File::Spec::Functions qw[catpath splitpath rel2abs];

__PACKAGE__->config(
    root => rel2abs( catpath( ( splitpath($0) )[0,1], '' ) )
);

    sub default : Private {
        my ( $self, $c ) = @_;
        $c->serve_static;
    }

__PACKAGE__->setup();

1;

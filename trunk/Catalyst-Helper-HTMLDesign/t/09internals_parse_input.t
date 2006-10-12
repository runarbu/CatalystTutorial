use Test::More tests => 4;

BEGIN { use_ok('Catalyst::Helper::HTMLDesign') };

{
    my %in = Catalyst::Helper::HTMLDesign::_parse_input();
    
    my %out = (
        layout => 'single',
        colour => 'default',
    );
    
    is_deeply( \%in, \%out );
}

{
    my %in = Catalyst::Helper::HTMLDesign::_parse_input(
        'header',
        colour => 'corporate',
    );
    
    my %out = (
        layout => 'single',
        colour => 'corporate',
        header => 1,
    );
    
    is_deeply( \%in, \%out );
}

{
    my %in = Catalyst::Helper::HTMLDesign::_parse_input(
        layout => '3design',
        'header',
        'footer',
    );
    
    my %out = (
        layout => '3design',
        colour => 'default',
        header => 1,
        footer => 1,
    );
    
    is_deeply( \%in, \%out );
}

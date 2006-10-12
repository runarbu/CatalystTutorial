#!/usr/bin/perl

use strict;
use warnings;

use CatalystX::Blog::Model::Article;
use DateTime;
use Text::Lorem;

CatalystX::Blog::Model::CDBI->connection('DBI:mysql:test:luther.ngmedia.net');

my $text = Text::Lorem->new;

for ( my $i = 0 ; $i < 100 ; $i++ ) {

    my $datetime = DateTime->from_day_of_year(
        day_of_year => int( rand(365) ) + 1,
        year        => 2005
    );
    
    my $content =  "<p>" . $text->paragraphs(10) . "</p>";
    $content =~ s|\n\n|</p>\n\n<p>|g;
    
    my $article = CatalystX::Blog::Model::Article->create({
        author           => $text->words(2),
        title            => $text->words(5),
        summary          => $text->words(25),
        content          => $content,
        publication_date => $datetime
    });
}

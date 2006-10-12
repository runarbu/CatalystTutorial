#!/usr/bin/perl

use strict;
use warnings;
use lib './lib';

use Image::Simple;

Image::Simple->adaptor('Imlib2');

my $image = Image::Simple->open( shift(@ARGV) || '/Users/chansen/Pictures/IMG_0426.JPG');

$image->rotate(90)->save('rotate090.jpg')->rotate(90)->save('rotate180.jpg')->rotate(90)->save('rotate270.jpg');

printf( "image %dx%d\n", $image->width, $image->height );

my $crop = $image->crop( 100, 100, 100, 100 );

printf( "croped %dx%d\n", $crop->width, $crop->height );

$crop->save('./croped.jpg');

my $scale = $image->scale( 200, 75 );
printf( "scaled %dx%d\n", $scale->width, $scale->height );

$scale->save('./scaled.jpg');

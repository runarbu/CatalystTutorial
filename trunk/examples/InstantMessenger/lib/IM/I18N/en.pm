package IM::I18N::en;
use strict;
use warnings;

use base qw( IM::I18N );

our %Lexicon;
our $l = \%Lexicon;

$l->{site_title} =      q|IM #hurp-zerg !gaph!|;

$l->{login_title} =     q|Login|;
$l->{login_content} = q|
    My 15 (++) Minute IM Client/Server<p>
    Powered by Catalyst ([_1]) and DBIx::Class.<p>
    Enter your username and click login.
|;
$l->{login_button} =    q|Login|;

$l->{messages_title} =  q|Messages|;
$l->{source_code} =     q|Source code|;
$l->{format_rules} =    q|You can use ~[b~]bold~[/b~], ~[i~]italic~[/i~] and http and mailto links will be auto-highlighted.|;
$l->{send_button} =     q|Send|;

$l->{history_title} =   q|History|;
$l->{previous} =        q|Previous|;
$l->{next} =            q|Next|;

1;

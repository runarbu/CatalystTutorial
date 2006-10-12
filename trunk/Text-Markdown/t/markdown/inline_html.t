use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 2;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

# This test is based on the descriptions in
# http://daringfireball.net/projects/markdown/syntax#html

$html = $m->markdown(<<"EOF");
This is a regular paragraph.

<table>
    <tr>
        <td>*notemphasisinblock*</td>
    </tr>
</table>

<div>*notemphasisinblock*</div>

<pre>*notemphasisinblock*</pre>

<p>*notemphasisinblock*</p>

<ul>
    <li>*notemphasisinblock*</li>
</ul>

<span>*emphasis*</span>

<cite>*emphasis*</cite>

<del>*emphasis*</del>

This is *ano<a href="*foo*">th</a>er* regular paragraph.
EOF

is_string($html, <<"EOF");
<p>This is a regular paragraph.</p>

<table>
    <tr>
        <td>*notemphasisinblock*</td>
    </tr>
</table>

<div>*notemphasisinblock*</div>

<pre>*notemphasisinblock*</pre>

<p>*notemphasisinblock*</p>

<ul>
    <li>*notemphasisinblock*</li>
</ul>

<p><span><em>emphasis</em></span></p>

<p><cite><em>emphasis</em></cite></p>

<p><del><em>emphasis</em></del></p>

<p>This is <em>ano<a href="*foo*">th</a>er</em> regular paragraph.</p>
EOF

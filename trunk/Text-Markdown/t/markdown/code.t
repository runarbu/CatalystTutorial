use Test::More;

eval 'use Test::LongString';
if ($@) {
    plan skip_all => 'Test::LongString required';
} else {
    plan tests => 9;
};

use_ok('Text::Markdown');

my $m = Text::Markdown->new;
my $html;

$html = $m->markdown(<<"EOF");
This is a normal paragraph:

    This is a code block.
EOF

is_string($html, <<"EOF");
<p>This is a normal paragraph:</p>

<pre><code>This is a code block.
</code></pre>
EOF

$html = $m->markdown(<<"EOF");
Here is an example of AppleScript:

    tell application "Foo"
        beep
    end tell
EOF

is_string($html, <<"EOF");
<p>Here is an example of AppleScript:</p>

<pre><code>tell application "Foo"
    beep
end tell
</code></pre>
EOF

$html = $m->markdown(<<"EOF");
    <div class="footer">
        &copy; 2004 Foo Corporation
        *emph*
    </div>
EOF

is_string($html, <<"EOF");
<pre><code>&lt;div class="footer"&gt;
    &amp;copy; 2004 Foo Corporation
    *emph*
&lt;/div&gt;
</code></pre>
EOF

$html = $m->markdown(<<"EOF");
Use the `printf()` function.
EOF

is_string($html, <<"EOF");
<p>Use the <code>printf()</code> function.</p>
EOF

$html = $m->markdown(<<"EOF");
`There is a literal backtick (\\\\`) here.`
EOF

is_string($html, <<"EOF");
<p><code>There is a literal backtick (`) here.</code></p>
EOF

$html = $m->markdown(<<"EOF");
``There is a literal backtick (`) here.``
EOF

is_string($html, <<"EOF");
<p><code>There is a literal backtick (`) here.</code></p>
EOF

$html = $m->markdown(<<"EOF");
Please don't use any `<blink>` tags.
EOF

is_string($html, <<"EOF");
<p>Please don't use any <code>&lt;blink&gt;</code> tags.</p>
EOF

$html = $m->markdown(<<"EOF");
`&#8212;` is the decimal-encoded equivalent of `&mdash;`.
EOF

is_string($html, <<"EOF");
<p><code>&amp;#8212;</code> is the decimal-encoded equivalent of <code>&amp;mdash;</code>.</p>
EOF



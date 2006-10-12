#!/usr/bin/perl

use strict;
use warnings;

use Benchmark                qw[cmpthese];
use HTML::FillInForm         qw[];
use HTML::FillInForm::LibXML qw[];

my $params = {
    checkbox  => [ 'A', 'B' ],
    radio     => 'C',
    select    => [ 'A', 'B' ],
    select2   => [ 'B', 'A' ],    
    text2     => 'cooool',
    textarea  => 'cccccc',
    textarea2 => 'sasdf',
};

my $html = <<'EOF';
<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>test</title>
</head>
<body>

	<form name="test" action="#" method="post" enctype="multipart/form-data" accept-charset="utf-8">

		<fieldset>

		    <legend>Form</legend>

			<dl>
			    <dt><label for="text1">Text1:</label></dt>
			    <dd><input type="text" name="text1" id="text1" value="Ratione accusamus aspernatur aliquam" /></dd>

			    <dt><label for="text2">Text2:</label></dt>
			    <dd><input type="text" name="text2" id="text2" /></dd>

			    <dt><label for="select">Select:</label></dt>
			    <dd>
			        <select name="select" id="select" multiple="multiple">
			            <option label="A" selected="selected">A</option>
			            <option label="B" selected="selected">B</option>
			            <option label="C">C</option>
			        </select>
			    </dd>

			    <dt><label for="select2">Select:</label></dt>
			    <dd>
			        <select name="select2" id="select2">
			            <option label="A">A</option>
			            <option label="B">B</option>
			            <option label="C">C</option>
			        </select>
			    </dd>

			    <dt><label>Radio:</label></dt>
			    <dd><input type="radio" name="radio" value="A" /></dd>
			    <dd><input type="radio" name="radio" value="B" /></dd>
			    <dd><input type="radio" name="radio" value="C" /></dd>

			    <dt><label>Checkbox:</label></dt>
			    <dd><input type="checkbox" name="checkbox" value="A" /></dd>
			    <dd><input type="checkbox" name="checkbox" value="B" /></dd>
			    <dd><input type="checkbox" name="checkbox" value="C" /></dd>

			    <dt><label for="textarea">Textarea:</label></dt>
			    <dd><textarea name="textarea" id="textarea" cols="20" rows="10">Voluptatem cumque voluptate sit recusandae at. Et quas facere rerum unde esse.</textarea></dd>

			    <dt><label for="textarea2">Textarea:</label></dt>
			    <dd><textarea name="textarea2" id="textarea2" cols="20" rows="10" /></dd>

			    <dt><label for="upload1">Upload:</label></dt>
			    <dd><input type="file" name="upload1" id="upload1" /></dd>

			    <dt><label for="upload2">Upload:</label></dt>
			    <dd><input type="file" name="upload2" id="upload2" /></dd>

			    <dt><input type="submit" value="submit" /></dt>
            </dl>
            
		</fieldset>
	</form>
</body>
</html>
EOF

printf( "HTML::FillInForm         : %s\n", $HTML::FillInForm::VERSION );
printf( "HTML::Parser             : %s\n", $HTML::Parser::VERSION );
printf( "HTML::FillInForm::LibXML : %s\n", $HTML::FillInForm::LibXML::VERSION );
printf( "XML::LibXML              : %s\n", $XML::LibXML::VERSION );
printf( "libxml                   : %s\n\n", XML::LibXML::LIBXML_DOTTED_VERSION );

cmpthese( -1, {
    'HTML::FillInForm' => sub { 
        HTML::FillInForm->new->fill( 
            scalarref => \$html, 
            fdat      => $params 
        ) 
    },
    'HTML::FillInForm::LibXML' => sub { 
        HTML::FillInForm::LibXML->new->fill(  
            scalarref => \$html,
            fdat      => $params 
        )
    }
});

__END__

HTML::FillInForm         : 1.06
HTML::Parser             : 3.45
HTML::FillInForm::LibXML : 0.01
XML::LibXML              : 1.58
libxml                   : 2.6.22

                          Rate         HTML::FillInForm HTML::FillInForm::LibXML
HTML::FillInForm         243/s                       --                     -18%
HTML::FillInForm::LibXML 296/s                      22%                       --

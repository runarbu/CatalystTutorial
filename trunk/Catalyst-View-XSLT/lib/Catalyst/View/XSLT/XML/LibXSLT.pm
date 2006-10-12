package Catalyst::View::XSLT::XML::LibXSLT;

use strict;
use warnings;

=head1 NAME

Catalyst::View::XSLT::XML::LibXSLT - An implementation for Catalyst::View::XSLT
with XML::LibXSLT

=head1 SYNOPSIS

This module is meant to be used internaly by Catalyst::View::XSLT module.

=cut

=over 4

=item new

Returns a new instance of XML::LibXSLT view implementation

=cut

# {{{ sub new(mixed $proto, oref $c, href $params)
sub new
{
	my ($proto, $c, $params) = @_;

	eval {

		XML::LibXML->require; 
		XML::LibXSLT->require;
	
		XML::LibXML->import;
		XML::LibXSLT->import;
	};
	
	if ($@) {
		$c->error('Could not use XML::LibXSLT: $@');
		return undef;
	}

	if (exists $params->{register_function}
		 and ref($params->{register_function}) eq 'ARRAY') {

		my $register_subs = $params->{register_function};

		foreach my $hrefSubConf (@{ $register_subs }) {
			XML::LibXSLT->register_function(
				$hrefSubConf->{uri},
				$hrefSubConf->{name},
				$hrefSubConf->{subref},
			);
		}
		 
	 }
	
	my $class = ref $proto || $proto;
	
	my $self = {};
	
	bless($self, $class);
	
	return $self;
	
}
# }}}

=item process

=cut

sub process {

	my ($self, $c, $template) = @_;

	my ($result, $error) = ('', undef);

	eval {	
		my $xmlParser = XML::LibXML->new();

		my $xsltProcessor = XML::LibXSLT->new();

		my 	($xmlDocument, $xsltStylesheet);
	    
	    my $xml = $c->stash->{xml};
	    delete $c->stash->{xml};

	    if ($xml =~ /\</) {
			$xmlDocument = $xmlParser->parse_string($xml);
	    } else {
			$xmlDocument = $xmlParser->parse_file($xml);
	    }
	
		if ($template =~ m/\</) {
			$xsltStylesheet = $xmlParser->parse_string($template);
		} else {
			$xsltStylesheet = $xmlParser->parse_file($template);
		}

		my $xsltTransformer = $xsltProcessor->parse_stylesheet($xsltStylesheet);

		my %params = XML::LibXSLT::xpath_to_string( %{$c->stash} );

		my $results = $xsltTransformer->transform($xmlDocument, %params);

		$result = $xsltTransformer->output_string($results);
		
	};

	$error = $@;

	return ($result, $error);
}

=back

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Base>, L<XML::LibXSLT>.

=head1 AUTHOR

Martin Grigorov, C<mcgregory@e-card.bg>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
__END__

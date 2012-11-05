package Test::Subcmd;

use warnings;
use strict;
use Test::More;

use Exporter 'import';

our @EXPORT_OK = qw/output_is/;

sub output_is ($&$$)
{
    my ($app, $code, $expected, $label) = @_;

    my $output;
    open my $fh, '>>', \$output or die "Unable to open handle to buffer.\n";
    $app->set_in_out( undef, $fh );
    $code->();
    $app->set_in_out( undef, \*STDOUT );
    return is $output, $expected, $label;
}

1;

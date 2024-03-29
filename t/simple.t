#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 25;

use_ok('Apache::LogRegex');

my $format = '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"';
my @fields = qw/%h %l %u %t %r %>s %b %{Referer}i %{User-Agent}i/;
my $regex  = '^(\S*) (\S*) (\S*) (\[[^\]]+\]) \"([^\"]*)\" (\S*) (\S*) \"([^\"]*)\" \"([^\"]*)\"$';
my $line   = '212.74.15.68 - - [23/Jan/2004:11:36:20 +0000] "GET /images/previous.png HTTP/1.1" 200 2607 "http://peterhi.dyndns.org/bandwidth/index.html" "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.2) Gecko/20021202"';

################################################################################
# Create a new object
################################################################################

eval { Apache::LogRegex->new(); };
like( $@, qr/^Apache::LogRegex->new\(\) takes 1 argument/, 'Wrong number of arguments' );

eval { Apache::LogRegex->new(1,2); };
like( $@, qr/^Apache::LogRegex->new\(\) takes 1 argument/, 'Wrong number of arguments' );

eval { Apache::LogRegex->new(undef); };
like( $@, qr/^Apache::LogRegex->new\(\) argument 1 \(FORMAT\) is undefined/, 'Undefined argument' );

my $x = Apache::LogRegex->new($format);
isa_ok( $x, 'Apache::LogRegex' );

################################################################################
# Check the fields and regex
################################################################################

my @l = $x->names();
isa_ok( \@l, 'ARRAY');

is(scalar(@fields), scalar(@l), 'Same length');
is(join(' ', @fields), join(' ', @l), 'Same fields');

eval { $x->names(1); };
like($@, qr/^Apache::LogRegex->names\(\) takes no argument/, 'Wrong number of arguments');

my $r = $x->regex();
is($r, $regex, 'Regex matches');

eval { $x->regex(1); };
like($@, qr/^Apache::LogRegex->regex\(\) takes no argument/, 'Wrong number of arguments');

################################################################################
# Check it can parse a line
################################################################################

my %data = $x->parse($line);
isa_ok( \%data, 'HASH');

is($data{'%h'}, '212.74.15.68', 'Checking the data' );
is($data{'%l'}, '-', 'Checking the data' );
is($data{'%u'}, '-', 'Checking the data' );
is($data{'%t'}, '[23/Jan/2004:11:36:20 +0000]', 'Checking the data' );
is($data{'%r'}, 'GET /images/previous.png HTTP/1.1', 'Checking the data' );
is($data{'%>s'}, '200', 'Checking the data' );
is($data{'%b'}, '2607', 'Checking the data' );
is($data{'%{Referer}i'}, 'http://peterhi.dyndns.org/bandwidth/index.html', 'Checking the data' );
is($data{'%{User-Agent}i'}, 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.2) Gecko/20021202', 'Checking the data' );

################################################################################
# Check it does not parse junk
################################################################################

eval { %data = $x->parse('dummy'); };
is($@, '', 'Does not parse junk');

eval { %data = $x->parse(); };
like($@, qr/^Apache::LogRegex->parse\(\) takes 1 argument/, 'Wrong number of arguments');

eval { %data = $x->parse(1,2); };
like($@, qr/^Apache::LogRegex->parse\(\) takes 1 argument/, 'Wrong number of arguments');

eval { %data = $x->parse(undef); };
like($@, qr/^Apache::LogRegex->parse\(\) argument 1 \(LINE\) is undefined/, 'Wrong number of arguments');

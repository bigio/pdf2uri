#!/bin/perl

# MIT License
#
# Copyright (c) 2024 Giovanni Bechis

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

use strict;
use warnings;

use Getopt::Std;
use XML::LibXML;

getopt('f:', \my %opts);

my $file = $opts{f};

my $ver = qx{pdftohtml -v 2>&1};
if($ver !~ /pdftohtml version/) {
  warn "pdftohtml not found or incompatible version";
  exit 2;
}

if (not defined $file) {
  warn "[-f] parameter is required";
  exit 3;
} elsif (not -f $file) {
  warn("File $file not found");
  exit 4;
}

my $xml;
open (my $pipe, "-|", "pdftohtml -xml -stdout \"$file\"") or die "error opening pipe: $!";
while (<$pipe>) {
  chomp;
  $xml .= $_ . "\n";
}
close ($pipe) or die;

my $dom = XML::LibXML->load_xml(string => $xml);
my @uris;
foreach my $node ($dom->findnodes('//a')) {
    push(@uris, $node->getAttribute('href'));
}
my @uniq_uris = do { my %seen; grep { !$seen{$_}++ } @uris };
print @uniq_uris;

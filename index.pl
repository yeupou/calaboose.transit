#!/usr/bin/perl
#
# (c) 2012 Mathieu Roy <yeupou--gnu.org>
#     http://yeupou.wordpress.com
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
#    USA

use strict;

print "Content-type:text/html\n\n";
print <<EndOfHTML;


<html><head><title>Accès temporaire :</title></head>
<body>
<h1>Perl Environment Variables</h1>
EndOfHTML

    print $ENV{"REMOTE_USER"}." BLALBLA <br>";

    foreach my $key (sort(keys %ENV)) {
	print "$key = $ENV{$key}<br>\n";
}

print "</body></html>";




# EOF

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
use CGI qw(:standard Link);

print header();
print start_html(-lang =>  'fr-FR',
		 -encoding => 'UTF-8',
		 -title => "Accès temporaire");

my $debug = 1;
my $user = param('user');

if ($user) {
# a user was provided
    print h3("Demande d'authentification :");

    # only take into account the request if it relates to a valid user...
    if (scalar(getpwnam($user)) eq "") {

	print "DBG Valid user\n";

	# and is the user belongs to the group transit
	use User::grent;
	my $group = getgrnam("transit");
	for (@{$group->members}) {
	    if ($_ eq $user) {

		print "DBG Valid user belongs to transit\n";
		
		# then set up a password if there's no .passwd, 
		#   (concurrent access is not implemented, otherwise it should
		# at this point read the content of .passwd and update it
		# if need be)
		my $passwd = "../.passwd";
		unless (-e $passwd) {
		    
		    print "DBG Valid user belongs to transit and $passwd is missing\n";

		    print "TADA";
		    
		}		
	    }
	}
    }

   # in any case
   # do not provide any relevant error message, it's not supposed to give out 
   # any details of the current system
     
} else {
# otherwise print a form to allow user to register 
    print h3("Inconnu...");
    print p("Indiquer ici le nom d'utilisateur habituel :");
    print start_form(-method=>"POST",-action=>script_name()).textfield(-name=>'user').submit().end_form();
    
}

print end_html();

# EOF

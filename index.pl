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
use POSIX qw(strftime);

print header();
print start_html(-lang =>  'fr-FR',
		 -encoding => 'UTF-8',
		 -title => "Accès temporaire");

my $debug = 1;
my $log = "/var/log/nginx/transit.log";
my $passwd = "/etc/nginx/passwd/transit";
my $user = param('user');

if ($user) {
# a user was provided
    print h3("Demande d'authentification :");
    
    print "+DBG user set to $user\n";

    # only take into account the request if it relates to a valid user...
    if (scalar(getpwnam($user)) ne "") {

	print "+DBG $user is valid ";

	# and is the user belongs to the group transit
	use User::grent;
	my $group = getgrnam("transit");
	for (@{$group->members}) {
	    if ($_ eq $user) {

		print "+DBG $user belongs to transit ";
		
		# then set up a password if there's no .passwd, 
		#   (concurrent access is not implemented, otherwise it should
		# at this point read the content of .passwd and update it
		# if need be)
		unless (-e $passwd) {
		    
		    print "+DBG $passwd is missing ";
	    
		    # If we get here, we create a new password and send it by
		    # mail to the user.
		    # (assume there is at least a valid alias for the user)

		    my @chars = (0 .. 9, 'a' .. 'z', 'A' .. 'Z');
		    my $random =  join "", @chars[ map rand @chars, 0 .. 6 ];
		    my $remote_ip = $ENV{'REMOTE_ADDR'};

                    # this must be logged
		    open(LOG, ">> /var/log/nginx/transit.log");
		    print LOG strftime "$remote_ip [%c] access requested and approved, ".$ENV{'HTTP_USER_AGENT'}."\n", localtime;
		    close(LOG);
		    
		    open(PASSWD, "> $passwd");
		    print PASSWD "$user:".crypt($random, $user)."\n";
		    close(PASSWD);
			


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

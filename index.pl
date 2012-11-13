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

my $debug = 0;
my $log = "/var/log/nginx/transit.log";
my $passwd = "/etc/nginx/passwd/transit";
my $user = param('user');

if ($user) {
# a user was provided
    print h3("Demande d'authentification :");
    
    print "+DBG user set to $user " if $debug;

    # only take into account the request if it relates to a valid user...
    if (scalar(getpwnam($user)) ne "") {

	print "+DBG $user is valid " if $debug;

	# and is the user belongs to the group transit
	use User::grent;
	my $group = getgrnam("transit");
	for (@{$group->members}) {
	    if ($_ eq $user) {

		print "+DBG $user belongs to transit " if $debug;
		
		# then set up a password if there's no entry for the current
		# user 
		my $passwd_contains_user = 0;
		open(PASSWD, "< $passwd");
		while(<PASSWD>){
		    next unless /^$user:/;
		    $passwd_contains_user = 1;
		}
		close(PASSWD);

		unless ($passwd_contains_user) {
		    
		    print "+DBG $user is missing from $passwd " if $debug;
	    
		    # If we get here, we create a new password and send it by
		    # mail to the user.
		    # (assume there is at least a valid alias for the user)

		    my @chars = (0 .. 9, 'a' .. 'z', 'A' .. 'Z');
		    my $random =  join "", @chars[ map rand @chars, 0 .. 6 ];
		    my $remote_ip = $ENV{'REMOTE_ADDR'};

                    # this must be logged
		    use POSIX qw(strftime);
		    open(LOG, ">> /var/log/nginx/transit.log");
		    print LOG strftime "$remote_ip [%c] access requested and approved, ".$ENV{'HTTP_USER_AGENT'}."\n", localtime;
		    close(LOG);
		    
		    # update/create a passwd file
		    open(PASSWD, ">> $passwd");
		    print PASSWD "$user:".crypt($random, $user)."\n";
		    close(PASSWD);
		    
		    print "+DBG $passwd updated/created ($user:$random) " if $debug;
			
		    # build a mail and send it
		    use Socket;
		    my $remote;
		    $remote = gethostbyaddr(inet_aton($remote_ip), AF_INET) 
			or $remote = $remote_ip;
		    use Mail::Send;
		    my $msg = new Mail::Send;
		    $msg->to($user);
		    $msg->subject("Accès temporaire");
		    $msg->add("User-Agent", "calaboose.transit");
		    my $fh = $msg->open;
		    print $fh "Bonjour,\n\Sollicité depuis la machine $remote, un nouveau mot de passe temporaire a été crée :\n\n\t\t".$random."\n\n";
		    $fh->close;
		    
		    print p("Un message vous a été envoyé à l'instant.");

		    print "+DBG mail sent " if $debug;
		    
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

#!/usr/bin/perl

use strict;
use LWP::UserAgent;
use HTTP::Cookies;

$ENV{HTTPS_CA_DIR}    = '/etc/ssl/certs';

#######################################################################
# Start Variables 

my ($cj,$op,$lurl,$br,$res,$req,$surl,$css,$prms,@keys,
    $user,$pass,@lines,$nurl,$pguid,$q,$v,$furl);

# End Variables 
#######################################################################

#######################################################################
# Start Configuration

# Credentials
$user	=	''; #Remember it probably needs to be @cox.net
$pass	=	'';

# Cookie Jar location
$cj	=	"/tmp/cookie"; #Make sure it's writable

# End Configuration
#######################################################################

#######################################################################
# Start  Constands and debugging

#login url
$lurl = "https://idm.east.cox.net/auth/login.fcc";
#final url
$furl = "https://myaccount.cox.net/internettools/datausage/usage.cox";

# Just a couple of precautions

# Create a browser / user agent object - lets mimic firefox
$br = LWP::UserAgent->new;
$br->agent("User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.12) Gecko/20080201 Firefox/2.0.0.12");

# test ssl options
#$br->ssl_opts(verify_hostname => 0);

# Make it follow redirects. Doesn't by default
#push @{ $br->requests_redirectable }, 'POST';

# Don't follow any redirects
#$br->requests_redirectable([ ]);

# Create cookie jar object
$cj = HTTP::Cookies->new(
  file => $cj,
  autosave => 1,
  ignore_discard => 1
);

# had to set all those cookies. Had to find them by other means, but 
# will look to work in a function to retreive them.
#.cox.com
$cj->set_cookie('0','cox-current-site','centralflorida','/','.cox.com');
$cj->set_cookie('0','cox-current-zipcode','32601','/','.cox.com');
$cj->set_cookie('0','coxlocale','centralflorida%3Ben_US','/','.cox.com');
$cj->set_cookie('0','cox-locale','Wj0zMjYwMV58XlQ9Ul58Xkw9XnxeSD1odHRwOi8vd3cyLmNveC5jb20vcmVzaWRlbnRpYWwvY2VudHJhbGZsb3JpZGEvaG9tZS5jb3g','/','.cox.com');
$cj->set_cookie('0','location','FL+-+Gainesville-Ocala','/','.cox.com');
$cj->set_cookie('0','coxwebmail','FL','/','.cox.com');

#.coxbusiness.com
$cj->set_cookie('0','cox-current-site','centralflorida','/','.coxbusiness.com');
$cj->set_cookie('0','cox-current-zipcode','32601','/','.coxbusiness.com');
$cj->set_cookie('0','coxlocale','centralflorida%3Ben_US','/','.coxbusiness.com');
$cj->set_cookie('0','cox-locale','Wj0zMjYwMV58XlQ9Ul58Xkw9XnxeSD1odHRwOi8vd3cyLmNveC5jb20vcmVzaWRlbnRpYWwvY2VudHJhbGZsb3JpZGEvaG9tZS5jb3g','/','.coxbusiness.com');
$cj->set_cookie('0','location','FL+-+Gainesville-Ocala','/','.coxbusiness.com');
$cj->set_cookie('0','coxwebmail','FL','/','.coxbusiness.com');

#.cox.net
$cj->set_cookie('0','cox-current-site','centralflorida','/','.cox.net');
$cj->set_cookie('0','cox-current-zipcode','32601','/','.cox.net');
$cj->set_cookie('0','coxlocale','centralflorida%3Ben_US','/','.cox.net');
$cj->set_cookie('0','cox-locale','Wj0zMjYwMV58XlQ9Ul58Xkw9XnxeSD1odHRwOi8vd3cyLmNveC5jb20vcmVzaWRlbnRpYWwvY2VudHJhbGZsb3JpZGEvaG9tZS5jb3g','/','.cox.net');
$cj->set_cookie('0','location','FL+-+Gainesville-Ocala','/','.cox.net');
$cj->set_cookie('0','coxwebmail','FL','/','.cox.net');

# Assign our browser object to our cookie jar
$br->cookie_jar($cj);

# Show progress option, default is 0 - DEBUGGING
$br->show_progress(0);

# End Constants and debugging
#######################################################################

#######################################################################
# Start Output

# HTML Output header
#print "Content-type: text/html\n\n";

# head to do all this mess trying to set the locale cookies
# was a pain in the ass
#$x = &gcontent($surl)->header('Location');
#print "\nresponse1: ".$x;
#$x = &locale($x)->content;
#print "\nresponse2: ".$x;


#working
&login($user,$pass);
#&gcontent($furl)->content;
print &parsecontent(&gcontent($furl)->content);
#print &gcontent($furl)->content;


# End Output
#######################################################################

#######################################################################
# Start Subroutines

#pick location
sub locale {

  my($url) = @_;

  $res = $br->post($url,
    [ 
			'dest' => 'https%3A%2F%2Fmyaccount.cox.net%2Finternettools%2Fdatausage%2Fusage.cox',
			'source' => 'outside',
			'lob' => 'residential',
			'zipcode' => '32601',
			'state' => ''
    ]
  );

  return $res;

}

# Authenticate
sub login {

  # redirect POST
  push @{ $br->requests_redirectable }, 'POST';
	#print "\nredirectable headers: ".join '  ', @{ $_->requests_redirectable},"\n" for $br;
	
  my($u,$p,$r) = @_;

  $res = $br->post($lurl,
	#'Referer' => '$r',
    [ 
			'target'		=> 'https://idm.east.cox.net/loginit/get?returnURL=/coxlogin/redirect.jsp?targeturl=https%3A%2F%2Fmyaccount.cox.net%2Finternettools%2Fdatausage%2Fusage.cox&coxretry',
			'onsuccess'	=> '${onsuccessurl}',
			'onfailure'	=> '${onfailureurl}',
      'username'	=> $u,
      'password' 	=> $p
    ]
  );

  return $res;

}

# GET Content
sub gcontent {

  my($url) = @_;

  #print "\nredirectable headers: ".join '  ', @{ $_->requests_redirectable},"\n" for $br;
  $res = $br->get($url);
  return $res;

}

sub parsecontent {

  my (@line,@output);

  #foreach (@lines){
  foreach (split /\n/,$_[0]){
    if (/<strong>([^<]+)<\/strong>(.*)$/){
			push (@line, $1);
  		push (@line, $2);
    } 
  } 

  foreach (@line){
	  s/\s{2,}/ of /g; #turn to spaces into 'of'
		s/<[a-zA-Z\/][^>]*>/ /g; #strip tags
		s/&nbsp;/ /g; #get rid of nbsp
		s/Daily Usage.*$//g; #take off some excess stuff
		s/(Current.*$)/\n$1/; #Add a new line
		s/(Data.*$)/\n$1:/; #Add a new line
		s/: The.*/GB/; #format some extra stuffs

		push (@output, $_); # push it all into an array

	}

  return join '',@output;

}

# End Subroutines
#######################################################################


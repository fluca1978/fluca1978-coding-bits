#!env perl

use v5.20;


my $require_title = 0;

while ( <> ){
    if ( /^blogger_orig_url/ ){
        say $_;
        say 'permalink: /:year/:month/:day/:title.html';
        $require_title = 1;
    }
    elsif ( $require_title && /^[-]{3}$/ ){
        $require_title = 0;
        say $_;
        say "\n<h1>~</h1>\n";
    }
    else {
        print $_;
    }
}

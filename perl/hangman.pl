#!/usr/bin/env perl

use v5.10;
use Term::ReadKey;

my $word;

# search for a word
open my $word_fh, '<', '/usr/share/dict/words' || die "\nCannot read words!\n$!\n";
srand;
rand( $. ) < 1 && ( $word = lc( ( split( /[\s']/, $_ ) )[ 0 ] ) ) while( <$word_fh> );
close $word_fh;

# wovels converted to +
my ( %guess_status ) = map { $_  , ( /[aeiouèéòàùì]/ ? '+' : '_' ) } ( split // , $word );
my $current_guessing = '';
my $max_trials       = 10;
my @wrong_chars      = ();

ReadMode 3; # allow for signals

# while there are undiscovered chars or other trials to do, go for it!
$current_guessing = join ' ' , map { $guess_status{ $_ } } ( split // , $word );
while( $current_guessing =~ /[+_]/ &&  $max_trials > 0 ){


    say "\n\n|| $current_guessing ||\t" . join( ',', @wrong_chars );
    say "guess a char: ";
    my $current_char = lc ReadKey( 0 );


    if ( ! $guess_status{ $current_char } ){
        # not guessed
        $max_trials--;
        push @wrong_chars, $current_char;
        say "No [$current_char] in the word, you still have $max_trials trials.";
    }
    else{
        say "You guessed right [$current_char]!";
        $guess_status{ $current_char } = $current_char;
        # build the guessing line
        $current_guessing = join ' ' , map { $guess_status{ $_ } } ( split // , $word );
    }



}

say "You guessed [$word] !\n" if ( $max_trials > 0 );
say "Sorry, the word you were looking for was [$word]\n" if ( ! $max_trials );


ReadMode 0;

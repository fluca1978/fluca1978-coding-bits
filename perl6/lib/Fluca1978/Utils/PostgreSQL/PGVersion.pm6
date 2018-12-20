# PGVersion
# Copyright 2018 Luca Ferrari
# Released under the BSD Licence
#
# This class handles the PostgreSQL versioning number scheme.
# The object stores all available numbers as integers and knows
# how to return a major number and minor. Since a major number can
# be made by two digits with a dot (e.g., 9.6) the major number is
# always returned as a string, other numbers are returned as integers.
#
# The object stores also the information about alfa and beta versions:
# there are two integers to keep track of an alfa or beta number, if they
# are greater than zero the version is an experimental one.
class PGVersion {
    has Int $!brand-number   = 0;
    has Int $!year-number    = 0;
    has Int $!minor-number   = 0;

    has Str $!development-type = ''; # can assume 'alfa' or 'beta'

    has Str $!http-download;


    method is-alfa( --> Bool ){ 'alfa' eq $!development-type; }
    method is-beta( --> Bool ){ 'beta' eq $!development-type; }
    method is-release( --> Bool ){ ! $!development-type; }

    # Utility method to know if the numbering scheme has
    # two only digits (i.e., 10 ongoing or less than 6 )
    method !use-two-numbers { $!brand-number >= 10 || $!brand-number < 6; }

    method major-number( --> Str ){
        self!use-two-numbers
                ?? $!brand-number.Str
                !! '%d.%d'.sprintf( $!brand-number, $!year-number );
    }

    method minor-number {
        return Nil if self.is-alfa || self.is-beta;
        return $!minor-number;
    }

    method development-number {
        return Nil if ! self.is-alfa && ! self.is-beta;
        return $!minor-number;
    }

    # Provide s descriptive string with only the numeric part.
    method gist( --> Str ){
        if self!use-two-numbers {
            return '%d%s%d'.sprintf:
            $!brand-number,
            self.is-release ?? '.' !! $!development-type,
            $!minor-number;
        }
        else {
            return '%d.%d.%d'.sprintf: $!brand-number, $!year-number, $!minor-number;
        }
    }


    # Provides a descriptive string with a prefix 'v', e.g.,
    # v9.6.5
    # Uses .gist to get the part after the 'v'.
    multi method Str( --> Str ){
        return 'v%s'.sprintf: self.gist;
    }

    multi method Str( Bool $verbose --> Str ){

        return self.gist if ! $verbose;

        # a stable version
        return '%s (Major: %s, Minor: %s, stable)'.sprintf:
        self.gist,
        self.major-number,
        self.minor-number  if self.is-release;

        # an unstable version
        return '%s (%s %d of development branch %d)'.sprintf:
        self.gist,
        $!development-type,
        $!minor-number,
        self.major-number;


    }

    # Method compatible with the PostgreSQL
    # SHOW server_version
    # SHOW server_version_num
    method server-version { return self.gist; }
    method server-version-num {
        return '%02d%02d%02d'.sprintf:
        $!brand-number,
        $!year-number,
        self.is-release ?? $!minor-number !! 0 ;
    }

    # Construct the object by means of a version string.
    method BUILD( :$version-string! ){
        self.parse( $version-string );
    }

    # A method to parse a string
    # that seems a PostgreSQL version and returns
    # initializes the object.
    # The string can be something like:
    # v10.1
    # 10.1
    # v9.6.5
    # 9.6.5
    # 11beta3
    method parse( Str $string! ){

        # reset all variabiles, allowing this object
        # to re-parse a different string
        $!brand-number = 0;
        $!year-number  = 0;
        $!minor-number = 0;
        $!development-type = '';

        # old-numbering: v9.6.5
        if $string ~~ / <[vV]>?
                        $<first>=(\d ** 1..2 )
                        <[.]>
                        $<second>=(\d ** 1..2 )
                        <[.]>
                        $<third>=(\d ** 1..2 )/ {
            $!brand-number  = $/<first>.Int;
            $!year-number = $/<second>.Int;
            $!minor-number  = $/<third>.Int;
            return True;
        }
        elsif $string ~~ / <[vV]>?
                           $<first>=(\d ** 1..2 )
                           <[.]>
                           $<second>=(\d ** 1..2 ) / {
            # stable new numbering v10.1
            $!brand-number  = $/<first>.Int;
            $!minor-number  = $/<second>.Int;
            return True;
        }
        elsif $string ~~ / <[vV]>? $<first>=(\d ** 1..2 ) $<dev>=(  <  alfa | beta > ) $<dev-n>=( \d ) / {
            # unstable new numbering v11beta3
            $!brand-number     = $/<first>.Int;
            $!year-number      = 0;
            $!minor-number     = $/<dev-n>.Int || 0;
            $!development-type = $/<dev>.Str;
            return True;
        }



        # unknown version string!
        return False;
    }

    # Computes the available downloadable link
    # from the official web site or the base specified.
    #
    #
    method http-download-url( Str :$base = 'https://ftp.postgresql.org/pub/source' ){
        return '%s/%s/postgresql-%s.tar.%s'.sprintf:
        $base,
        self.Str, # e.g., v11.1
        self.gist, # e.g., 11.1
        $!brand-number <= 7 ?? 'gz' !! 'bz2';
    }

    # Check if this version is the same of another version.
    method ACCEPTS ( PGVersion $other ){
        self.server-version-num == $other.server-version-num;
    }

    method newer( PGVersion $version ){
        self.server-version-num > $version.server-version-num;
    }

    method older( PGVersion $version ){
        self.server-version-num < $version.server-version-num;
    }

}

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
    has Int $!first-number   = 0;
    has Int $!second-number  = 0;
    has Int $!third-number   = 0;
    has Int $!alfa-number    = 0;
    has Int $!beta-number    = 0;


    method is-alfa( --> Bool ){ return $!alfa-number > 0; }
    method is-beta( --> Bool ){ return $!beta-number > 0; }

    # Utility method to know if the numbering scheme has
    # two only digits (i.e., 10 ongoing or less than 7 )
    method !use-two-numbers { return $!first-number >= 10 || $!first-number < 7; }

    method major-number( --> Str ){
        self!use-two-numbers
                ?? $!first-number.Str
                !! '%d.%d'.sprintf( $!first-number, $!second-number );
    }

    method minor-number {
        return Nil if self.is-alfa || self.is-beta;
        return self!use-two-numbers ?? $!second-number !! $!third-number;
    }

    method development-number {
        return Nil if ! self.is-alfa && ! self.is-beta;
        return $!alfa-number if self.is-alfa;
        return $!beta-number if self.is-beta;
    }

    # Provide s descriptive string with only the numeric part.
    method gist( --> Str ){
        if self!use-two-numbers {
            return '%dalfa%d'.sprintf( $!first-number, $!alfa-number ) if self.is-alfa;
            return '%dbeta%d'.sprintf( $!first-number, $!beta-number ) if self.is-beta;
            return '%d.%d'.sprintf(    $!first-number, $!second-number );
        }
        else {
            return '%d.%d.%d'.sprintf: $!first-number, $!second-number, $!third-number;
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
        self.minor-number  if ! self.is-alfa && ! self.is-beta;

        # an unstable version
        return '%s (%s %d of development branch %d)'.sprintf:
        self.gist,
        self.is-alfa ?? 'alfa' !! 'beta',
        self.is-alfa ?? $!alfa-number !! $!beta-number,
        self.major-number;


    }

    # Method compatible with the PostgreSQL
    # SHOW server_version
    # SHOW server_version_num
    method server-version { return self.gist; }
    method server-version-num {
        return '%02d%02d%02d'.sprintf:
        $!first-number,
        self!use-two-numbers ?? 0 !! $!second-number,
        self!use-two-numbers ?? $!second-number !! $!third-number if ! self.is-alfa && ! self.is-beta;

        return '%02d9999'.sprintf: $!first-number;
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
        $!first-number   = 0;
        $!second-number  = 0;
        $!third-number   = 0;
        $!alfa-number    = 0;
        $!beta-number    = 0;

        # old-numbering: v9.6.5
        if $string ~~ / <[vV]>?
                        $<first>=(\d ** 1..2 )
                        <[.]>
                        $<second>=(\d ** 1..2 )
                        <[.]>
                        $<third>=(\d ** 1..2 )/ {
            $!first-number  = $/<first>.Int;
            $!second-number = $/<second>.Int;
            $!third-number  = $/<third>.Int;
            return True;
        }
        elsif $string ~~ / <[vV]>?
                           $<first>=(\d ** 1..2 )
                           <[.]>
                           $<second>=(\d ** 1..2 ) / {
            # stable new numbering v10.1
            $!first-number  = $/<first>.Int;
            $!second-number = $/<second>.Int;
            return True;
        }
        elsif $string ~~ / <[vV]>? $<first>=(\d ** 1..2 ) $<dev>=( < alfa | beta > ) $<dev-n>=( \d ) / {
            # unstable new numbering v11beta3
            $!first-number  = $/<first>.Int;
            $!alfa-number = $/<dev> ~~ 'alfa' ?? $/<dev-n>.Int !! 0;
            $!beta-number = $/<dev> ~~ 'beta' ?? $/<dev-n>.Int !! 0;

            return True;
        }

        # unknown version string!
        return False;
    }
}

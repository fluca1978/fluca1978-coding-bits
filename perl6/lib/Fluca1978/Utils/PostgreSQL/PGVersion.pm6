# PGVersion
# Copyright 2018 Luca Ferrari
# Released under the BSD Licence

=begin pod

=TITLE PGVersion - a class to handle PostgreSQL version strings

=SUBTITLE SYNOPSIS
     my $v = PGVersion.new: :version-string( 'v9.6.5' );
     say $v.gist;  # 9.6.5
     say $v;       # v9.6.5

     my $v = PGVersion.new: :brand-number( 10 ), :minor-number( 3 );
     say $v.server-version-num; # 100003

=SUBTITLE Description

This class allows you for quickly and consistently manage PostgreSQL
server version strings and numbers, providing facilities to convert
a string (or number) into an object.

The class provides different methods to inspect a version a compare different
objects with regard to their version details.

Internally, the class handles a version splitting it into three parts (brand, year and
minor numbers) and a flag to keep track of the alfa/beta/release status of the
version itself.

=SUBTITLE Methods

=item C<major-number> returns a string with the major number,
for instance '9.6', '10'.

=item C<minor-number> provides an integer with the minor number
of the PostgreSQL version

=item C<development-number> if the version is an alfa or beta one,
this method provides an integer with the number of development. For instance
in the case '11beta3' it return C<3>.

=item C<gist>, C<Str>, C<Str( Bool) > provide a stringified version
of the object. The C<gist> provides only the numbers separated by a dot,
the C<Str> applies a 'v' in front of the number and in the case of a C<True>
optional parameter provides a descvriptive string (useful for output in verbose
listings)

=item C<server-version> same as C<gist>

=item C<server-version-num> provides a string with only numbers as in
executing C<SHOW server_version_num;> in a PostgreSQL server connection.

=item C<reset> invalidates the object resetting all the fields

=item C<parse> initializes the object with values extracted from a version string.
Valid strings are: C<v9.6.5>, C<10.1>, C<v11beta1>, C<90605>.

=item http-download-url( Str :base ) provides a link to download the specified
version of PostgreSQL. The C<$base> optional argument can be initialized to a
downloadable repository, by default the PostgreSQL one.

=item C<newer>, C<older>, C<ACCEPTS> compares this object against another
version

=end pod


class PGVersion {
    has Int $!brand-number     = 0;
    has Int $!year-number      = 0;
    has Int $!minor-number     = 0;
    has Str $!development-type = ''; # can assume 'alfa' or 'beta'


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
        # 9.6.5 -> 90605
        # 10.1  -> 100001
        return '%d%d%d'.sprintf:
            $!brand-number * ( $!brand-number >= 10 ?? 100 !! 10 ),
            $!year-number * 10,
            ( self.is-release ?? $!minor-number !! 0 );
    }

    # Construct the object by means of a version string.
    multi method BUILD( Str :$version-string! ){
        self.parse( $version-string );
    }

    # Construct the object by means of the three version numbers.
    # Please note that only the brand version is mandatory,
    # since the other twos are set to zero automatically.
    multi method BUILD( Int :$brand-number!, Int :$year-number, Int :$minor-number  ){
        self.reset;
        $!brand-number  = $brand-number;
        $!year-number   = $year-number // 0;
        $!minor-number  = $minor-number // 0;
    }


    # Reset all the values.
    method reset {
        # reset all variabiles, allowing this object
        # to re-parse a different string
        $!brand-number = 0;
        $!year-number  = 0;
        $!minor-number = 0;
        $!development-type = '';
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

        self.reset;


        # allow the building form a string with
        # the server num format
        # e.g., 90605
        if $string.Int && $string.chars >= 5 {
            my $version = $string.Int;
            my @values = $string.split: '';
            my $index = 0; # the split inserts a first null char as @values[0]
            $!brand-number     = Int.new: ( @values[ ++$index ] ~ @values[ ++$index ] ) / ( $string.chars == 5 ?? 10 !! 1 );
            $!year-number      = Int.new: ( @values[ ++$index ] ~ @values[ ++$index ] ) / 10;
            $!minor-number     = Int.new: @values[ ++$index ] ~ @values[ ++$index ];
            $!development-type = '';

            return True;
        }
        elsif  $string ~~ / :i v?
                        $<first>=(\d ** 1..2 )
                        $<dev>=( alfa || beta || [.] )
                        $<second>=(\d ** 1..2 )
                        [.]?
                        $<third>=(\d ** 0..2 )/ {
            $!brand-number     = $/<first>.Int;
            $!year-number      = $/<third>.Int ?? $/<second>.Int !! 0;
            $!minor-number     = $/<third>.Int ?? $/<third>.Int  !! $/<second>.Int;
            $!development-type = $/<dev>.Str eq '.' ?? '' !! $/<dev>.Str.lc;
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
        self.server-version-num.Int > $version.server-version-num.Int;
    }

    method older( PGVersion $version ){
        self.server-version-num.Int < $version.server-version-num.Int;
    }


    # Comparison operator.
    multi sub infix:<cmp>( PGVersion $left, PGVersion $right ){
        $left.server-version-num cmp $right.server-version-num;
    }

}

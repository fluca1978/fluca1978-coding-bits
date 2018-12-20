use v6;
use Test;
use Fluca1978::Utils::PostgreSQL::PGVersion;
plan 3;

use-ok( 'PGBrew::Utils::PGVersion' );

subtest 'NEW Version number parsing' => {

    my $version = PGVersion.new: :version-string( 'v10.1' );
    is( $version.gist, '10.1', 'Stringify version number' );
    is( $version.major-number, 10.Str, 'Get version number' );
    is( $version.minor-number, 1, 'Get minor version number' );
    isnt( $version.is-alfa, True, 'Alfa version' );
    isnt( $version.is-beta, True, 'Beta version' );
    is( $version.development-number, Nil, 'Extract beta number' );
    is( $version.server-version-num, '100001', 'SHOW SERVER_VERSION_NUM' );

    my $version-string = '11beta3';
    $version.parse: 'v' ~ $version-string;
    is( $version.gist, $version-string, 'Stringify beta version number' );
    is( $version.major-number, 11.Str, 'Get beta version number' );
    is( $version.minor-number, Nil, 'Get minor beta version number' );
    isnt( $version.is-alfa, True, 'Alfa version' );
    is( $version.is-beta, True, 'Beta version' );
    is( $version.development-number, 3, 'Extract beta number' );
    is( $version.server-version-num, '119999', 'SHOW SERVER_VERSION_NUM' );

    $version-string = '11alfa4';
    $version.parse: $version-string;
    is( $version.gist, $version-string, 'Stringify version number' );
    is( $version.major-number, 11.Str, 'Get version number' );
    is( $version.minor-number, Nil, 'Get minor version number' );
    is( $version.is-alfa, True, 'Alfa version' );
    isnt( $version.is-beta, True, 'Beta version' );
    is( $version.development-number, 4, 'Extract beta number' );

    isnt( $version.parse( '11NotVersion2' ), True, 'Cannot parse unknow version string!' );
    isnt( $version.parse( 'Blah' ), True, 'Cannot parse unknow version string!'  );

}


subtest 'OLD version number parsing' => {
    my $version-string = '9.6.5';
    my $version = PGVersion.new: :version-string( 'v' ~ $version-string );

    $version.parse: $version-string;
    is( $version.gist, $version-string, 'Stringify OLD version number' );
    is( $version.major-number, '9.6', 'Get old version number' );
    is( $version.minor-number, 5, 'Get old minor version number' );
    isnt( $version.is-alfa, True, 'Alfa old version' );
    isnt( $version.is-beta, True, 'Beta old version' );
    is( $version.development-number, Nil, 'Extract old beta number' );

    $version-string = '9.6.5';
    $version.parse: $version-string;
    is( $version.gist, $version-string, 'Stringify OLD version number' );
    is( $version.major-number, '9.6', 'Get old version number' );
    is( $version.minor-number, 5, 'Get old minor version number' );
    isnt( $version.is-alfa, True, 'Alfa old version' );
    isnt( $version.is-beta, True, 'Beta old version' );
    is( $version.development-number, Nil, 'Extract old beta number' );
    is( $version.server-version-num, '090605', 'SHOW SERVER_VERSION_NUM' );

    $version-string = '6.12';
    $version.parse: $version-string;
    is( $version.gist, $version-string, 'Stringify OLD version number' );
    is( $version.major-number, '6', 'Get old version number' );
    is( $version.minor-number, 12, 'Get old minor version number' );
    isnt( $version.is-alfa, True, 'Alfa old version' );
    isnt( $version.is-beta, True, 'Beta old version' );
    is( $version.development-number, Nil, 'Extract old beta number' );

}

use v6;
use Test;
use Fluca1978::Utils::PostgreSQL::PGVersion;
plan 8;

use-ok( 'Fluca1978::Utils::PostgreSQL::PGVersion' );

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
    is( $version.server-version-num, '110000', 'SHOW SERVER_VERSION_NUM' );

    $version-string = '11beta2'.uc;
    $version.parse: 'v' ~ $version-string;
    is( $version.gist, $version-string.lc, 'Stringify camel case beta version number' );
    is( $version.major-number, 11.Str, 'Get beta version number' );
    is( $version.minor-number, Nil, 'Get minor beta version number' );
    isnt( $version.is-alfa, True, 'Alfa version' );
    is( $version.is-beta, True, 'Beta version' );
    is( $version.development-number, 2, 'Extract beta number' );
    is( $version.server-version-num, '110000', 'SHOW SERVER_VERSION_NUM' );

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
    is( $version.server-version-num, '90605', 'SHOW SERVER_VERSION_NUM' );

    $version-string = '9.6.5';
    $version.parse: $version-string;
    is( $version.gist, $version-string, 'Stringify OLD version number' );
    is( $version.major-number, '9.6', 'Get old version number' );
    is( $version.minor-number, 5, 'Get old minor version number' );
    isnt( $version.is-alfa, True, 'Alfa old version' );
    isnt( $version.is-beta, True, 'Beta old version' );
    is( $version.development-number, Nil, 'Extract old beta number' );
    is( $version.server-version-num, '90605', 'SHOW SERVER_VERSION_NUM' );

    $version-string = '6.3.2';
    $version.parse: $version-string;
    is( $version.gist, $version-string, 'Stringify OLD version number' );
    is( $version.major-number, '6.3', 'Get old version number' );
    is( $version.minor-number, 2, 'Get old minor version number' );
    isnt( $version.is-alfa, True, 'Alfa old version' );
    isnt( $version.is-beta, True, 'Beta old version' );
    is( $version.development-number, Nil, 'Extract old beta number' );

    $version-string = '1.1';
    $version.parse: $version-string;
    is( $version.gist, $version-string, 'Stringify OLD version number' );
    is( $version.major-number, '1', 'Get old version number' );
    is( $version.minor-number, 1, 'Get old minor version number' );
    isnt( $version.is-alfa, True, 'Alfa old version' );
    isnt( $version.is-beta, True, 'Beta old version' );
    is( $version.development-number, Nil, 'Extract old beta number' );
}

subtest 'URL' => {
    my $version = PGVersion.new: :version-string( 'v11.1' );
    is( $version.http-download-url, 'https://ftp.postgresql.org/pub/source/v11.1/postgresql-11.1.tar.bz2' );
    $version.parse: 'v7.3.5';
    is( $version.http-download-url, 'https://ftp.postgresql.org/pub/source/v7.3.5/postgresql-7.3.5.tar.gz' );

}


subtest 'ACCEPTS and smart matching' => {
    my $version-a = PGVersion.new: :version-string( '10.1' );
    my $version-b = PGVersion.new: :version-string( 'v9.6.5' );

    is( $version-a ~~ $version-a, True, 'Smart matching against self' );
    is( $version-a ~~ $version-b, False, 'Smart matching against different version' );
    is( $version-a ~~ 'v10.1', True, 'Smart matching against self string' );
    is( $version-b.gist ~~ '9.6.5', True, 'Smart matching against self string' );

    is( $version-a.newer( $version-b ), True, 'Newer version' );
    is( $version-b.older( $version-a ), True, 'Older version' );
}


subtest 'Build from version number' => {
    my $version = PGVersion.new: :version-string( '90605' );
    my $version-string = '9.6.5';
    is( $version.gist, $version-string, 'Stringify OLD version number' );
    is( $version.major-number, '9.6', 'Get old version number' );
    is( $version.minor-number, 5, 'Get old minor version number' );
    isnt( $version.is-alfa, True, 'Alfa old version' );
    isnt( $version.is-beta, True, 'Beta old version' );
    is( $version.development-number, Nil, 'Extract old beta number' );

    $version = PGVersion.new: :version-string( '100001' );
    $version-string = '10.1';
    is( $version.gist, $version-string, 'Stringify NEW version number' );
    is( $version.major-number, '10', 'Get version number' );
    is( $version.minor-number, 1, 'Get minor version number' );
    isnt( $version.is-alfa, True, 'Alfa version' );
    isnt( $version.is-beta, True, 'Beta version' );
    is( $version.development-number, Nil, 'Extract  beta number' );
}


subtest 'Build with explicit numbers' => {
    my $version = PGVersion.new: :brand-number(10), :minor-number(3);
    my $version-string = '10.3';
    is( $version.gist, $version-string, 'Stringify version number' );
    is( $version.major-number, '10', 'Get version number' );
    is( $version.minor-number, 3, 'Get minor version number' );
    isnt( $version.is-alfa, True, 'Alfa version' );
    isnt( $version.is-beta, True, 'Beta version' );
    is( $version.development-number, Nil, 'Extract  beta number' );
    is( $version.server-version-num, '100003', 'Get server version num' );



    $version = PGVersion.new: :brand-number(9), :minor-number(3), :year-number(6);
    $version-string = '9.6.3';
    is( $version.gist, $version-string, 'Stringify version number' );
    is( $version.major-number, '9.6', 'Get version number' );
    is( $version.minor-number, 3, 'Get minor version number' );
    isnt( $version.is-alfa, True, 'Alfa version' );
    isnt( $version.is-beta, True, 'Beta version' );
    is( $version.development-number, Nil, 'Extract  beta number' );
    is( $version.server-version-num, '90603', 'Get server version num' );
}


subtest 'Comparison' => {
    my $version-a = PGVersion.new: :brand-number(9), :minor-number(3), :year-number(6);
    my $version-b = PGVersion.new: :brand-number(9), :minor-number(6), :year-number(3);
    my $version-c = $version-a;
    is( $version-a cmp $version-b, Order::More, 'Comparing older version' );
    is( $version-b cmp $version-a, Order::Less, 'Comparing newer version' );
    is( $version-c cmp $version-a, Order::Same, 'Comparing same version' );
    
}

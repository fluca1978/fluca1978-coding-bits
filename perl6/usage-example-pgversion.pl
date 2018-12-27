use Fluca1978::Utils::PostgreSQL::PGVersion;

for <10.1 11beta1 11.1 9.6.5 6.11 90605 100003> {
    say "Building for version $_";
    my $v = PGVersion.new: :version-string( $_ );
    say "PostgreSQL version is $v";
    say "or for short { $v.gist }";
    say "release ? { $v.is-release }";
    say "alfa ? { $v.is-alfa }";
    say "beta ? { $v.is-beta }";
    say "and if you want a detailed version:\n{ $v.Str( True ) }";
    say "Equivalent to SHOW SERVER_VERSION_NUM is {$v.server-version-num }";
    say "URL to download: { $v.http-download-url }";
    say '~~~~' x 10;
}

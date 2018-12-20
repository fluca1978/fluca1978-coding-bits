use Fluca1978::Utils::PostgreSQL::PGVersion;

for <10.1 11beta1 11.1 9.6.5> {
    my $v = PGVersion.new: :version-string( $_ );
    say "PostgreSQL version is $v";
    say "or for short { $v.gist }";
    say "and if you want a detailed version:\n{ $v.Str( True ) }";
    say "Equivalent to SHOW VERSION_NUM is {$v.server-version-num }";
    say '~~~~' x 10;
}

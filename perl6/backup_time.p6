#!env perl6

sub MAIN( Str :$backup_dir
          where { .IO.d // die "No backup directory [$backup_dir]!" } = 'BACKUP'
    , *@backup_entries where { .map: { .IO.f || .IO.d // die "No backup entry [$_]" }  }
    )
{
    my $now = DateTime.now;
    # for each entry compute the name
    for @backup_entries -> $entry {
        my $archive_name = $backup_dir.IO.add: '%s-%s-%04d-%02d-%02dT%02d%02d'.sprintf(
                                                     ( $entry.IO.d ?? 'DIRECTORY' !! 'FILE' ),
                                                     $entry.IO.basename,
                                                     $now.year,
                                                     $now.month,
                                                     $now.day,
                                                     $now.hour,
                                                     $now.minute );

        "== Backup %s\n\t  [%s]\n\t->[%s]".sprintf( ( $entry.IO.d ?? 'DIRECTORY' !! 'FILE' ), $entry.IO.basename, $archive_name ).say;
        if $entry.IO.d {
            my $current_tar = run 'tar', 'cjvf', $archive_name ~ '.tar.bz2', $entry, :out, :err;
            ( $current_tar.exitcode == 0 ?? 'OK' !! 'KO' ).say;
        }
        else {
            my $ok = $entry.IO.copy( $archive_name );
            ( $ok ?? 'OK' !! 'KO' ).say;
        }
    }
}

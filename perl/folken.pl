#!env perl

use v5.10; # speriamo in una versione decente!


if ( ! @ARGV ){
    say "Uso: $0 <file_csv> [file_tag] [csv|sql|org]  [limite_righe|all]";
    exit;
}

my %available_modes = ( 'csv' => 'CSV pulito',
                        'org' => 'Emacs-org',
                        'sql' => 'SQL generico',
    );



# in default modalita' csv
my $mode  = $ARGV[ 2 ] || undef;
my $limit = $ARGV[ 3 ] || 'all';
undef $limit if ( $limit eq 'all' );
my @modes_to_process = ( $mode );

# se non ho specificato un modo particolare allora li processo tutti
@modes_to_process = sort keys %available_modes if ( ! $mode || $mode eq 'all' || ! grep( $mode, keys %available_modes ) );


for $mode ( @modes_to_process ){

    # in default (csv) non ho separatori all'inizio e alla fine della riga
    my ( $begin_separator, $separator, $end_separator );
    ( $begin_separator, $separator, $end_separator ) = ( '', ',', '' )   if ( $mode eq 'csv' );
    ( $begin_separator, $separator, $end_separator ) = ( '|', '|', '|' ) if ( $mode eq 'org' );
    ( $begin_separator, $separator, $end_separator ) = ( '(', ',', ')' ) if ( $mode eq 'sql' );


    my $output_file_name = sprintf '%s.%s', $ARGV[ 0 ], $mode;

    open my $input, "<", $ARGV[ 0 ] || die "\nImpossibile aprire il file $ARGV[ 0 ] !\n$!\n";
    open my $output, ">", $output_file_name  || die "\nImpossibile generare il file di output [$output_file_name]!\n$!\n";


    say sprintf "Inizio elaborazione modo %s (%s) su file di output [%s] %s limite",
        $mode, $available_modes{ $mode }, $output_file_name,
        ( $limit ? "$limit tuple" : 'nessun' );


    my @headers;

    # intestazioni
    if ( @ARGV > 1 ){
        open my $tag, "<", $ARGV[ 1 ]   || die "\nNessun file di tag specificato, intestazioni disabilitate!\n";
        local $/ = "\r\n";  # ATTENZIONE: i tag potrebbero essere in formato DOS!
        chomp( @headers = <$tag> );
        unshift @headers, 'RECNUM' if ( @headers );
        close $tag;
    }


    my $preamble = '';
    if ( @headers ){
        if ( $mode eq 'sql' ){
            # modalita' sql, non stampo le intestazioni ma preparo il preamble
            ( my  $table = $ARGV[ 0 ] ) =~ s/(\w+)\.\w+$/$1/;
            $preamble = sprintf "INSERT INTO\n %s(%s)\n VALUES", uc $table, join ',', @headers;
            $end_separator = ');';
        }else {
            say { $output } $begin_separator, join( $separator, @headers ), $end_separator;
        }
    }

    # dati
    my $counter = 0;
    while ( <$input> ){
        chomp;
        my @fields = map{ s/'//g;   s/^\"|\"$/'/g; s/'\s+/'/g; s/\s+'/'/g; $_  } split ',';
        say { $output } $preamble if ( $preamble );  # insert into se modalita' sql
        say { $output } $begin_separator, join( $separator, @fields ), $end_separator;
        last if $limit && $counter++ > $limit;
    }



    close $input;
    close $output;

    say "Pulizia completata, file [$output_file_name]\n";
}

say "Non resta altro da fare";

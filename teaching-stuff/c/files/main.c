#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void
main(){
  FILE *myFile = fopen( "/tmp/example.txt", "w" );
  char* content = "AABBCCDDEEFF";

  fwrite( content, strlen( content ), 1,  myFile );
  fclose( myFile );

  myFile = fopen( "/tmp/example.txt", "r" );
  char twoChars[2];

  int read = 0;
  while( ( read = fread( twoChars, sizeof( twoChars ), 1, myFile ) ) > 0 )
    printf( "Read %d/%d: %s\n", read, (int) sizeof( twoChars ), twoChars );

}

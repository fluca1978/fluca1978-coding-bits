#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/**
 * A simple program to show two different methods to get the current working
 * directory of a running process (this one).
 * The first method, the more portable one, uses the getcwd call.
 * The second method launches a pwd process and gets back the result assuming
 * the string is not longer than 1024 chars.
 */
  



int
main( int argc, char** argv ){
  char* myPath;

  printf("\nGetting path by mean of getcwd....");
  myPath = NULL;

  /*
    As  an  extension  to  the  POSIX.1-2001  standard,  Linux  (libc4, libc5, glibc)
    getcwd() allocates the buffer dynamically using malloc(3) if  buf  is  NULL.   In
    this case, the allocated buffer has the length size unless size is zero, when buf
    is allocated as big as necessary.  The caller should free(3) the returned buffer.
  */
  myPath = getcwd( myPath, 0 );
  printf("\nObtained path [ %s ]\n", myPath);
  free( myPath );
  myPath = NULL;

  myPath = malloc( 1024 );
  FILE *outputStream = popen( "pwd", "r" );
  /*
    Reading stops after an EOF or  a  newline.
    If  a  newline is read, it is stored into the buffer.
  */
  fgets( myPath, 1024, outputStream );
  myPath[ strlen( myPath ) - 1 ] = '\0';
  printf("\nObtained path by means of pwd [ %s ]\n", myPath );
  free( myPath );
  


}



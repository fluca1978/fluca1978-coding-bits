/* An example of sparse file creation. */

/* 
 * To compile and run:

 gcc -o sparse.exe sparse.c
 ./sparse.exe

 * To see the output do the following ls:

 $ ls -lahs sparse.out 
 4.0K -rw-r--r-- 1 luca luca 11M 2012-11-08 16:20 sparse.out

 * The file is 4 kB (one data page) but is occupying 11 MB on the file system!

 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>

#define KB *1024
#define MB *1024 *1024

int main (int argc, char **argv) {
  int offset = 10 MB, fd;
  char ch, file[1024];

  /* use argv[1] as file name to write onto, or by default
     create a file named "sparse.out"
  */
  if( argc > 1 ) {
    strcpy (file, argv[1]);
  } else {
    strcpy (file, "sparse.out");
  }

  /* open the file for writing */
  if ((fd = open (file, O_WRONLY | O_CREAT | O_TRUNC, 0666)) == -1) {
    printf("\n Cannot open the sparse file for writing [%s][%d] \n",
	   file,
	   errno);
    exit (1);
  }

  /* go to the end of the file */
  lseek (fd, offset, SEEK_SET);

  /* write one char to the end of the file */
  write (fd, "a", 1);

  /* all done */
  close (fd);

  return 0;
}

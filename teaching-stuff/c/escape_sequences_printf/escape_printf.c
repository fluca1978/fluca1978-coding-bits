/**
 * A simple progrma to demonstrate the usage of escape sequences in the
 * printf standard library function.
 *
 * To compile the program simply run
   
   gcc -o esc.exe escape_printf.c
   ./esc.exe

 *
 * 
 */
#include <stdio.h>

int main(int argc, char**argv){

  int background, foreground, style;

  printf("\nWelcome to a simple program to demonstrate the escape sequences on terminals using the printf library function\n" );
  
  /*
   * An escape sequence is made of the ASCII char 033, a square opening bracket
   * and by three numbers separated by a semicolon.
   * The first number is the style (underline,...), the second
   * is the foreground color and the third is the background color.
   * Each escape sequence must end with a lower case 'm'.
   * 
   */



  for( style = 0; style <= 7; style++)
    for( background = 30; background <= 37; background++ )
      for(foreground=40;foreground<=47;foreground++){
	printf("%c[%d;%d;%dm",033,style,background,foreground);
	printf("\n\tHere it is the tuple (style = %d, foreground = %d, background = %d",
	       style,
	       foreground,
	       background);
      }
    
  
  /* reset the terminal! */
  printf("%c[0;37;40m\n",033);  

  exit( 0 );
}

/**
 * A simple program to demonstrate how to extract embedded structures using
 * pointer math and a custom offsetof function.
 *
 * Compile the program with:
 * gcc -lm -O0 with_custom_offset_of.c
 * and run.
 */


#include <stdio.h>
#include <stddef.h>
#include <math.h>


/**
 * Define a structure that represents an header
 */
struct header {
  
  /**
   * An header name, just to print something out.
   */
  char* h_name;
  
  /**
   * A version, just to simulate some real header data.
   */
  int h_version;

};


/**
 * Define a packet structure that embeds an header.
 * In order not to use the offset_of place the header
 * as the first member of the structure, so that a pointer
 * to a packet can be casted to a pointer to an header
 * and viceversa.
 */
struct packet_with_header_at_top {
  
  /**
   * The packet header.
   */
  struct header p_header;
  
  
  /**
   * A name for this packet, just to print out something.
   */
  char* p_name;
  
  /**
   * An integer to simulate some real packet data.
   */
  int p_data;
  
 
};


/**
 * A packet of data containing the header at the bottom.
 * It is still possible to convert an header pointer to a packet
 * pointer and vice versa, but there is an extra effort.
 */
struct packet_with_header_at_bottom {
  
  
  /**
   * A name for this packet, just to print out something.
   */
  char* p_name;
  
  /**
   * An integer to simulate some real packet data.
   */
  int p_data;

  /**
   * The packet header.
   */
  struct header p_header;
  
};

#define custom_offset_of( struct_pointer, struct_member ) \
  ( (size_t) ( (char*) &( (struct_pointer*) NULL )->struct_member - (char*) NULL ) )





int main( int argc, char** argv ){

  printf( "\nRunning program without offset support\n" );
  int offset = 0;

  // create an header
  struct header my_header = {
    .h_name    = "HEADER",
    .h_version = 1
  };
  
  /*
   * Create a packet with the header at the top and one
   * with the header at the bottom. Please note that the initialization order
   * of the packet fields has nothing to do with the real underlying structure.
   */

  struct packet_with_header_at_top my_packet_top = {
    .p_header = my_header,
    .p_name   = "PACKET WITH HEADER AT TOP",
    .p_data   = 99
  };


  struct packet_with_header_at_bottom my_packet_bottom = {
    .p_header = my_header,
    .p_name   = "PACKET WITH HEADER AT BOTTOM",
    .p_data   = 999
  };


  /*
   * Define some pointers to play with structures.
   */
  struct packet_with_header_at_top*    top_pointer    = &my_packet_top;
  struct packet_with_header_at_bottom* bottom_pointer = &my_packet_bottom;
  struct header*                       header_pointer = &my_header;

  /*
   * Print out the original data to ensure always is correct.
   */
  printf( "\n Name of the packet with header at top:    %s", top_pointer->p_name );
  printf( "\n Name of the packet with header at bottom: %s", bottom_pointer->p_name );
  printf( "\n Header name: %s", header_pointer->h_name );


  /*
   * Loose the header pointer
   */
  header_pointer = 0;

  /*
  printf( "\nSize of a char* is %d", sizeof( char* ) );
  printf( "\nSize of an int is  %d", sizeof( int ) );
  printf( "\nSize of an void* is  %d", sizeof( void* ) );
  printf( "\nSize of struct header is %d and size of struct header* is %d", sizeof( struct header ), sizeof( struct header* ) );
  */

  /*
   * Getting the header out of the packet with the header at the top is
   * as simple as casting pointers
   */
  printf( "\n---Packet with header at top---\n");
  printf( "\nPacket address is 0x%x", top_pointer );
  printf( "\nHeader address from packet is 0x%x", top_pointer->p_header );


  // cast the pointer to the packet to a pointer to the header
  header_pointer = top_pointer;

  printf( "\nHeader address computed is 0x%x", header_pointer );
  printf( "\nHeader name and data extracted from the packet: %s - %d", header_pointer->h_name, header_pointer->h_version );
  // cast back from header to packet
  top_pointer = ( struct packet_with_header_at_top* ) header_pointer;
  printf( "\n Name of the packet with header at top:    %s", top_pointer->p_name );
  printf( "\n-------------------------------\n");



  /*
   * For the bottom header packet things are slightly more complex:
   * it is required to manually compute the offset of the field
   * within the structure.
   * In order to manipulate the structure an offset has to be computed
   * and it is worth noting that the offset has to be aligned to
   * a char* (1 byte alignement).
   */
  printf( "\n---Packet with header at bottom---\n");
  printf( "\nPacket address is 0x%x", bottom_pointer );
  printf( "\nHeader address from packet is 0x%x", bottom_pointer->p_header );

  // compute the supposed offset depending on the fields that are before
  // the p_header
  offset = sizeof( int ) + sizeof( char* );

  // align the offset to 1 byte
  //  offset = ( offset % sizeof( char* ) == 0 ? offset : ceil( ( (double) offset / (double) sizeof( char* ) ) ) * sizeof( char* ) );
  offset = custom_offset_of( struct packet_with_header_at_bottom, p_header );
  printf( "\nOffset computed is %d", offset );

  // move the pointer to the offset
  header_pointer = ( (char*) bottom_pointer ) + offset;

  printf( "\nHeader address computed is 0x%x", header_pointer );
  printf( "\nHeader name and data extracted from the packet: %s - %d", header_pointer->h_name, header_pointer->h_version );

  // cast back from header to packet using again the offset
  bottom_pointer = ( struct packet_with_header_at_bottom* ) ( (char*) header_pointer - offset );
  printf( "\n Name of the packet with header at top:    %s", bottom_pointer->p_name );
  printf( "\n-------------------------------\n");


}

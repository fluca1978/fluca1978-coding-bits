#include <iostream>
#include <string>
#include <list>

int main( int argc, char **argv ) {
  std::list<std::string> strings = { "My", "name", "is", "Luca" };

  for ( std::string current : strings )
    std::cout << current << ' ';

  std::cout << std::endl;



  std::cout << "First element in the list is: " << strings.front() << std::endl;
  std::cout << "Last  element in the list is: " << strings.back() << std::endl;

  strings.push_back( "Ferrari" );

  strings.reverse();
  for ( std::string current : strings )
    std::cout << "[REVERSED] " << current << std::endl;
  return 0;
}



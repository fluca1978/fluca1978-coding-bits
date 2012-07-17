package ficList.test;
import ficList.impl.*;

/**
 * Test delle liste ad array costruite.
 * @author Francesco De Mola demola.franceaco@unimore.it
 * @version 1.0
 */
public class MainArray {
  public static void main(String argv[]){
    // creo qualche stringa
    String s1 = "stringa 1";
    String s2 = "stringa 2";
    String s3 = "stringa 3";
    String s4 = "stringa 4";

    // e qualche altro oggetto
    MainArray m = new MainArray();
    Object o1 = new Object();
    Object o2 = new Object();


	System.out.println("PROGRAMMA DI PROVA DELLE LISTE AD ARRAY\n");


	// PROVO LA LISTA AD ARRAY
	ListArray aList = new ListArray(s1);
		
    // stampa della lista
    System.out.println("\nLista array fino ad ora:\n");
    aList.dump();

    // aggiungo altri elementi
    aList.insert(o1);
    aList.insert(o2);
    aList.insert(m);

    // stampa della lista
    System.out.println("\nLista array fino ad ora:\n");
    aList.dump();

    // rimuovo un elemento dalla lista
    aList.remove(s1);

    // stampa della lista
    System.out.println("\nLista array fino ad ora:\n");
    aList.dump();




  }
}

package ficList.test;

import ficList.impl.*;
import ficList.impl.exception.*;

import java.io.*;


/**
 * Test delle liste ad array costruite.
 * @author Francesco De Mola demola.franceaco@unimore.it
 * @version 1.0
 */
public class MainArray2 {
  public static void main(String argv[]){
 
    // creo qualche persona
    Persona p1 = new Persona("Francesco","via Allegri",6);
    Persona p2 = new Persona("Giacomo","via Roma",10);
    Persona p3 = new Persona("Luca","via Campi",32);
    Persona p4 = new Persona("Letizia","via Vignolese",205);
    Persona p5 = new Persona("Davide","via Gramsci",2);
    Persona p6 = new Persona("Raffaele","via Emilia",653);


	System.out.println("PROGRAMMA DI PROVA DELLE LISTE \"CONTROLLATE\" AD ARRAY\n");


	// PROVO LA LISTA AD ARRAY
	ListArray2 aList = new ListArray2(p1);
	//aggiungo elementi
	aList.insert(p2);
	aList.insert(p3);
    aList.insert(p4);
    aList.insert(p5);
    
    // stampa della lista
    System.out.println("\nLista array fino ad ora:\n");
    aList.dump();


    System.out.println("\n->Aggiunta di un elemento con controllo...\n");
	
	try{
		
	    aList.controlled_insert(p6);
	    
	}catch(FullListException e){
	 	
	 	System.out.println("ERROR: "+e.toString());
	 	
	}catch(DuplicateItemException e){
	 	
	 	System.out.println("ERROR: "+e.toString());
	 	System.out.println("Sei sicuro di voler sostituire l'elemento? (y/n) ");
	 	
	 	try{
	 		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
		 	String risposta = in.readLine();
		 	if (risposta.compareToIgnoreCase("y")==0)
		 		aList.update(p6);
		}catch(IOException e1){
			System.out.println("ERROR: "+e1.toString());
		}
	}


    // stampa della lista
    System.out.println("\nLista array fino ad ora:\n");
    aList.dump();


    // ricreo una persona già inserita e la aggiungo con i controlli
    Persona p7 = new Persona("Luca","p.za Prampolini",1);
    System.out.println("\n->Aggiunta di una persona gia' presente...\n");

	try{
		
	    aList.controlled_insert(p7);
	    
	}catch(FullListException e){
	 	
	 	System.out.println("ERROR: "+e.toString());
	 	
	}catch(DuplicateItemException e){
	 	
	 	System.out.println("ERROR: "+e.toString());
	 	System.out.println("Sei sicuro di voler sostituire l'elemento? (y/n) ");
	 	
	 	try{
	 		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
		 	String risposta = in.readLine();
		 	if (risposta.compareToIgnoreCase("y")==0)
		 		aList.update(p7);
		}catch(IOException e1){
			System.out.println("ERROR: "+e1.toString());
		}
	}
    


    // stampa della lista
    System.out.println("\nLista array fino ad ora:\n");
    aList.dump();
    
    //creo una persona col nome da cercare nella lista
    System.out.println("\n->Ricerca di una persona...\n");
    Persona p = new Persona("Giacomo");
    Persona p8 = (Persona)aList.getObject(p);
    System.out.println("\nCerco Giacomo: "+p8.toString());
    
    
    //rimozione di elementi
    System.out.println("\n->Elimino Giacomo...\n");

	try{
		
	    aList.controlled_remove(p8);
	    
	}catch(ItemNotFoundException e){
	 	System.out.println("ERROR: "+e.toString());	 	
	}
 
     // stampa della lista
    System.out.println("\nLista array fino ad ora:\n");
    aList.dump();
   
 
    System.out.println("\n->Elimino Luigi...\n");
    p = new Persona("Luigi");
	try{
		
	    aList.controlled_remove(p);
	    
	}catch(ItemNotFoundException e){
	 	System.out.println("ERROR: "+e.toString());	 	
	}
    
    // stampa della lista
    System.out.println("\nLista array fino ad ora:\n");
    aList.dump();
    
  }
}

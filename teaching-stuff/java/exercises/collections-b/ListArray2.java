package ficList.impl;

import ficList.List;
import ficList.impl.exception.*;
import ficList.test.Persona;


/**
 * Implementazione di una lista ad array.
 * @author Francesco De Mola demola.francesco@unimore.it
 * @version 1.0
 */
public class ListArray2 extends ListArray{
 
	/**
	 * Costruttore della lista vuota
	 */
	public ListArray2(){
	  	super();
	}
	
	/**
	 * Costruttore che accetta un elemento da inserire in cima alla lista.
     * @param first l'oggetto da inserire per primo nella lista.
     */
	public ListArray2(Object first){
	  	super(first);	  	
	}

	/**
	 * Costruttore che accetta un elemento da inserire in cima alla lista
	 * e un'altra lista da concatenare come elementi successivi.
     * @param first l'oggetto da inserire per primo nella lista.
     * @param lista la lista da concatenare.
     */
	public ListArray2(Object first,List lista){
		super(first,lista);
	}
		
	/**
	 * Inserisce un nuovo elemento se la lista non è piena e non esiste già. 
	 * Altrimenti lancia un'eccezione.
	 * @param toInsert l'oggetto da inserire di tipo Persona (per consentire
	 * il confronto corretto sull'oggetto)
	 * @throws FullListException se la lista è piena
	 * @throws DuplicateItemException se la lista contiene già l'elemento
	 */
	public void controlled_insert(Persona toInsert) throws FullListException,DuplicateItemException{
		
		//controllo se l'elemento è già presente nella lista
		if (contains(toInsert))
			throw new DuplicateItemException("Elemento gia' presente nella lista");
		
		//controllo se c'è ancora spazio nella lista
		if (currentPos+1 >= MaxDim)
			throw new FullListException("E' stato raggiunta la capienza massima della lista");

		insert(toInsert);
	}
	
	/**
	 * Aggiorna un elemento, se è già presente nella lista.
	 * @param toUpadate l'oggetto da aggiornare
	 */
	public void update(Persona toUpdate){
    	//se la lista è vuota ritorna subito
    	if (isEmpty())
    		return;

    	int i=0;
    	//ricerca l'elemento
    	while (!((Persona)elements[i]).equals(toUpdate) && (i<currentPos))
    		i++;
    		
    	//sostituisce l'oggetto (se è stato trovato prima dell'ultima posizione)
    	if (i<=currentPos)
    		elements[i] = toUpdate;		
	}
		
	/**
	 * Rimuove un oggetto dalla lista, scalando gli elementi successivi
	 * verso sinistra. Se l'oggetto non esiste lancia un'eccezione.
     * @param toRemove l'oggetto da rimuovere
	 * @throws ItemNotFoundException se la lista contiene già l'elemento
     */
    public void controlled_remove(Persona toRemove) throws ItemNotFoundException{

		//controllo se l'elemento non è presente nella lista
		if (!contains(toRemove))
			throw new ItemNotFoundException("L'elemento non e' presente");
			
    	//se la lista è vuota ritorna subito
    	if (isEmpty())
    		return;
		
    	int i=0;
    	//ricerca l'elemento
    	while (!((Persona)elements[i]).equals(toRemove) && (i<currentPos))
    		i++;
    	//scala gli elementi successivi (se esistono) a sinistra
    	for (int j=i; i<currentPos; i++)
    		elements[j] = elements[j+1];
    	
    	//se l'elemento è stato trovato e rimosso, si aggiorna la lunghezza della lista
    	if (i<=currentPos)
    		currentPos--;
    }
    
    /**
     * Indica se un oggetto è presente nella lista.
     * @param toSearch l'oggetto da cercare nella lista.
     * @return true se l'oggetto viene trovato, false altrimenti.
     */
    public boolean contains(Persona toSearch){
    	//scorro tutta la lista alla ricerca dell'elemento
    	for (int i=0; i<currentPos; i++)
    		if (((Persona)elements[i]).equals(toSearch))
    			return true;
    	return false;
    }
    
    /**
     * Cerca un elemento e, se lo trova, lo restituisce senza rimuoverlo.
     * @param toGet l'oggetto da prelevare dalla lista o null se non trovato.
     */
    public Object getObject(Persona toGet){
    	//scorro tutta la lista alla ricerca dell'elemento
    	for (int i=0; i<currentPos; i++)
    		if (((Persona)elements[i]).equals(toGet))
    			return elements[i];
    	return null;
    }
    	
    
}


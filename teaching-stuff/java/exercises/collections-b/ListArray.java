package ficList.impl;
import ficList.List;


/**
 * Implementazione di una lista ad array.
 * @author Francesco De Mola demola.francesco@unimore.it
 * @version 1.0
 */
public class ListArray implements List{
	
	/** 
	 * Dimensione massima della lista
	 */
	final static int MaxDim = 5;
	
	/**
	 * Array degli elementi della lista
	 */
	protected Object[] elements;
	
	/** 
	 * Posizione dell'ultimo elemento
	 */
	protected int currentPos;
	 
	 
	 
	/**
	 * Costruttore della lista vuota
	 */
	public ListArray(){
	  	elements = new Object[MaxDim];
	  	currentPos = -1;
	}
	
	/**
	 * Costruttore che accetta un elemento da inserire in cima alla lista.
     * @param first l'oggetto da inserire per primo nella lista.
     */
	public ListArray(Object first){
	  	elements = new Object[MaxDim];
	  	currentPos = 0;
	  	elements[currentPos] = first;
	  	
	}

	/**
	 * Costruttore che accetta un elemento da inserire in cima alla lista
	 * e un'altra lista da concatenare come elementi successivi.
     * @param first l'oggetto da inserire per primo nella lista.
     * @param lista la lista da concatenare.
     */	
	public ListArray(Object first,List lista){
		this();
		revInsert(lista);
		insert(first);
	}

    /**
     * Metodo di servizio per l'inserimento di una lista in quella corrente
     * rispettando l'ordine. Occorre procedere ricorsivamente dalla fine della
     * lista da appendere poiché non si è certi di come la lista sia implementata
     * (viene passato un oggetto List). Pertanto si procede tagliando la lista
     * fino al suo ultimo elemento, l'ultimo elemento viene poi inserito nella
     * lista attuale (inserimento in testa), dopodiché il penultimo elemento
     * (inserimento in testa => penultimo prima di ultimo) e così via.
     * @param lista List
     */
	private void revInsert(List lista){
		if (!lista.isEmpty()){
			revInsert(lista.tail());
			insert(lista.head());
		}
	}
	
	/**
	 * Dice se la lista è vuota.
	 * @return true se la lista è vuota
	 */
	public boolean isEmpty(){
		return (currentPos == -1);
	}
	
	/**
	 * Restituisce il prime elemento della lista, senza cancellarlo.
	 * @return il primo elemento della lista o null se la lista è vuota.
	 */
	public Object head(){
		if (isEmpty())
			return null;
		else
			return elements[0];
	}
	
	/**
	 * Restituisce l'ultimo elemento della lista, senza cancellarlo.
	 * @return l'ultimo elemento della lista o null se la lista è vuota.
	 */
	public Object last(){
		if (isEmpty())
			return null;
		else
			return elements[currentPos];
	}
	
    /**
     * Restituisce la coda della lista. La coda di una lista è una lista formata
     * da tutti gli elementi seguenti la testa.
     * @return la coda della lista o null se la lista è vuota
     */
	public List tail(){
		if (isEmpty())
			return null;
		else{
			// crea una nuova lista e copia tutti gli elementi a partire
			// dall'ultimo (per rispettare l'ordine di inserimento)
			// tralasciando il primo (cella 0 dell'array)
			ListArray tmp = new ListArray();
			for (int i=currentPos; i>0; i--)
				tmp.insert(elements[i]);
			return tmp;
		}
	}
		
	/**
	 * Inserisce un nuovo elemento in testa. Gli altri elementi esistenti
	 * vengono spostati a seguire
	 * @param toInsert l'oggetto da inserire
	 */
	public void insert(Object toInsert){
		currentPos++;
		//scala tutti gli elementi verso destra per creare un posto all'inizio
		for (int i=currentPos; i>0; i--)
			elements[i] = elements[i-1];
		//inserisce il nuovo elemento in testa (cella 0 dell'array)
		elements[0] = toInsert;
	}
	
	/**
	 * Rimuove un oggetto dalla lista, scalando gli elementi successivi
	 * verso sinistra.
     * @param toRemove l'oggetto da rimuovere
     */
    public void remove(Object toRemove){
    	//se la lista è vuota ritorna subito
    	if (isEmpty())
    		return;

    	int i=0;
    	//ricerca l'elemento
    	while (!elements[i].equals(toRemove) && (i<currentPos))
    		i++;
    	//scala gli elementi successivi (se esistono) a sinistra
    	for (int j=i; i<currentPos; i++)
    		elements[j] = elements[j+1];
    	
    	//se l'elemento è stato trovato e rimosso, si aggiorna la lunghezza della lista
    	if (i<=currentPos)
    		currentPos--;
    }

    /**
     * Fornisce la lunghezza della lista.
     * @return la lugnehzza della lista, ossia il numero di celle occupate nell'array.
     */
    public int length(){
    	return currentPos+1;
    }
    
    /**
     * Indica se un oggetto è presente nella lista.
     * @param toSearch l'oggetto da cercare nella lista.
     * @return true se l'oggetto viene trovato, false altrimenti.
     */
    public boolean contains(Object toSearch){
    	//scorro tutta la lista alla ricerca dell'elemento
    	for (int i=0; i<currentPos; i++)
    		if (elements[i].equals(toSearch))
    			return true;
    	return false;
    }
    
    /**
    * Stampa su stdout la lista.
    */
	public final void dump(){
		int margine = 0;
		
		for (int i=0; i<=currentPos; i++){
	      System.out.println("");          // va a capo
	      for(int j=0; j<margine; j++)      // stampa un rientro verso destra
	        System.out.print(" ");
	
	      margine++;
	      //stampa l'elemento (invocazione implicita del metodo toString sull'oggetto in elements[i]
		  System.out.print("+ ["+elements[i].getClass().getName()+"] <"+elements[i]+">");
	    }
	
	    // vado a capo
	    System.out.print("\n");
	}

    
}


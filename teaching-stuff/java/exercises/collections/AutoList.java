package automobili;
import ficList.*;

/**
 * Lista di automobili
 */
public class AutoList implements ficList.List
{

    /**
     * Primo elemento della lista
     */
    private automobili.Node node;

    
 
    /**
     * Costruttore di default della lista
     */
    public AutoList(){
	node=null;
    }
 
    /**
     * Costruttore che specifica la testa
     *@param testa l'oggetto da mettere in cima alla lista
     */
    public AutoList(Object testa){
	node = new Node(testa);
    }
 

    
    /**
     * Costruttore
     *@param testa l'oggetto da mettere in testa
     *@param lista la lista in cui appendere l'oggetto in testa
     */
    public AutoList(Object testa, List lista){
	if (lista != null)
	    revInsert(lista);
	insert(testa);	
    }	
 

    /**
     * Inserisce una lista invertendo l'ordine
     *@param lista la lista da inserire
     */
 private void revInsert(List lista){
     if(!lista.isEmpty()){
	 revInsert(lista.tail());
	 insert(lista.head());	
     }	
 }
 
    /**
     * Indica se la lista e' vuota
     *@return true se la lista e' vuota
     */
    public boolean isEmpty(){
	return (node == null);
    }
 
    /**
     * Restituisce il primo elemento della lista
     *@return il primo elemento
     */
    public Object head(){
	if (isEmpty()){
	    return null;
	}
	else{
	    return node.info;
	}
    }
    

    /**
     * Ultimo elemento della lista
     *@return l'ultimo elemento
     */
    public Object last(){
	if (isEmpty()){
	    return null;
	}
	else{
	    Node tmp = node;
	    while(tmp.next != null)
		{tmp = tmp.next;}
	    return tmp.info;	
	}	
    }
    
    
    /**
     * Taglia la lista.
     *@return la lista senza il primo elemento
     */
    public List tail(){
	if (isEmpty())
	    return null;
	else{
		AutoList tmp = new AutoList();
		tmp.node = node.next;
		return tmp;	
	    }
    }
 

    /**
     * inserisce un elemento nella lista
     *@param o l'elemento da aggiungere
     */
    public void insert(Object o){
	node = new Node(o,node);
    }
    
    /**
     * Rimuove un elemento dalla lista
     *@param o l'elemento da rimuovere
     */
 public void remove (Object o){
     if(!isEmpty())
	 {
	     Node pred = node;
	     Node tmp = node.next;
	     if (node.info.equals(o))
		 node = node.next;
	     else {
		     while (tmp != null)
			 if (tmp.info.equals(o))
			     {pred.next = tmp.next; return;}
			 else
			     {pred = pred.next; tmp = tmp.next;}	
		 }	
	 }
 }
 


    /**
     * Lunghezza della lista
     *@return la lunghezza della lista
     */
    public int length(){
	Node tmp = node;
	int cont = 0;
	while(tmp != null)
	    {tmp = tmp.next; cont++;}
	return cont;	
    }
 


    /**
     * Indica se un elemento e' contenuto nella lista
     *@param o l'elemento da cercare
     *@return true se l'elemento e' contenuto
     */
    public boolean contains(Object o){
	Node tmp = node;
	while(tmp != null)
	    {
		if (tmp.info.equals(o))
		    return true;
		else	tmp = tmp.next;
	    }	
	return false;
    }
    
    
    /**
     * Cerca le auto di marca
     *@param marca la marca dell'automobile(i) da cercare
     *@return il vettore delle automobili contenute
     */
    public Automobile[] getAutoDiMarca(String marca){
	Node tmp = node;
	int conta = 0;
	
	//conta quante automobili della marca specificata sono presenti nella lista
	while(tmp != null){
	    if (((Automobile)(tmp.info)).getMarca().equals(marca))
		conta++;
	    tmp = tmp.next;
	}
	
	//crea e riempie il vettore dei risultati (di dimensione 'ad hoc')
	Automobile[] ris = new Automobile[conta];
	tmp = node;
	int i = 0;
	while(tmp != null){
	    if (((Automobile)(tmp.info)).getMarca().equals(marca))
		ris[i++] = (Automobile)tmp.info;
	    tmp = tmp.next;	
	}
	return ris;
    }
    
 
    /**
     * Cerca le auto sopra una certa potenza
     *@param potenza la potenza minima dell'automobile
     *@return il vettore con le auto trovate
     */
    public Automobile[] getAutoSopraPotenza(float potenza){
	Node tmp = node;
	int conta = 0;
	
	//conta quante auto hanno la potenza uguale o superiore a quella specificata
	while(tmp != null){
	    if(((Automobile)tmp.info).getPotenza() >= potenza)
		conta++;
	    tmp = tmp.next;	
	}
	
	//crea e riempie il vettore dei risultati (di dimensione 'ad hoc')
	Automobile[] ris = new Automobile[conta];
	tmp = node;
	int i = 0;
	while(tmp != null){
	    if(((Automobile)tmp.info).getPotenza() >= potenza)
		ris[i++] = (Automobile)tmp.info;
	    tmp = tmp.next;	
	}
	return ris;	
    }
}

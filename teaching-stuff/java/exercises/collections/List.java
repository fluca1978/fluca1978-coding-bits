package ficList;


/**
 * Interfaccia che definisce i metodi che deve avere una lista.
 */
public interface List
{

    /**
     * Indica se la lista e' vuota.
     *@return true se la lista e' vuota, false altrimenti
     */
    public boolean isEmpty();
 	

    /**
     * Restituisce l'oggetto in cima alla lista
     *@return il primo oggetto della lista
     */
    public Object head();
 
    /**
     * Restituisce una lista senza il primo elemento.
     *@return la lista privata della testa
     */
    public List tail();
 
    /**
     * Ultimo elemento della lista
     *@return l'ultimo elemento della lista
     */
    public Object last();
 
    
    /**
     * Inserisce un elemento nella lista.
     *@param element l'elemento da aggiungere alla lista
     */
    public void insert(Object element);
 
    /**
     * Rimuove un elemento dalla lista.
     *@param element l'elemento da rimuovere
     */
    public void remove(Object element);
 
    /**
     * Lunghezza della lista
     *@return il numero di elementi presenti nella lista
     */
    public int length();
 
    /**
     * Cerca un elemento nella lista
     *@param element elemento da cercare
     *@return true se l'elemento e' contenuto nella lista
     */
    public boolean contains(Object element);
}

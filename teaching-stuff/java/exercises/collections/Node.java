package automobili;


/**
 * Nodo di una lista
 */
public class Node
{
    /**
     * Informazione della lista (es. automobile)
     */
    Object info; 
 	
    /**
     * Puntatore al prossimo riferimento nella lista
     */
    Node next;   
 
    /**
     * Costruttore di default. 
     *@param info l'oggetto da inserire in questo nodo
     */
    public Node (Object info){
	this(info,null);
    }
 
    /**
     * Costruttore con prossimo elemento
     *@param info il nodo corrente
     *@param succ il nodo successivo a questo
     */
    public Node(Object info, Node succ){
	this.info=info;
	this.next=succ;
    }
}

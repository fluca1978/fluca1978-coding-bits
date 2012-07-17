package fluca.net;

/**
 * Questa interfaccia identifica un connection manager che <i>dovrebbe</i>
 * essere eseguito concorrentemente. In altre parole, l'esecuzione del metodo
 * manageConnection(..) viene affidata ad un thread separata.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public interface ConcurrentConnectionManager extends ConnectionManager{
}

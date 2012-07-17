package fluca.net.secure;
import java.io.Serializable;


/**
 * Questa classe rappresenta un singolo "grant", ovvero un tipo di permesso su una
 * connessione. Un esempio e' una coppia username-password, usato per stabilire una
 * connessione sicura. E' possibile inserire username e password in un grant e
 * inviare il grant lungo la connessione. Se il server accetta il grant (username/password corretti)
 * si ha la connessione, altrimenti il grant non e' sufficiente per collegarsi al server.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public abstract class Grant implements Serializable{

}

package fluca.net;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.SocketAddress;

/**
 * Questa interfaccia definisce la struttura che deve avere un oggetto per
 * gestire una connessione arbitraria che giunge al server. Ogni volta che una
 * connessione viene stabilita con il server, il server invoca il metodo
 * <code>manageConnection</code> su un oggetto che implementa questa interfaccia,
 * passando gli opportuni stream. All'interno del suddetto metodo e' quindi
 * necessario inserire la logica di gestione della connessione (
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public interface ConnectionManager {

  /**
   * Questo metodo definisce il comportamento della connessione. All'interno di
   * questo metodo e' possibile utilizzare i canali di input/output per inviare
   * e ricevere dati dall'host remoto.
   * @param remoteAddress l'indirizzo remoto da cui proviene la connessione (non indispensabile)
   * @param input lo stream di input sul quale e' possibile fare delle readObject()
   * per ottenere i dati in ricezione
   * @param output lo stream di output sul quale e' possibile fare delle writeObject(..)
   * per inviare oggetti all'host remoto
   * @param canRead true se la socket e' aperta in lettura dall'altra parte, ovvero
   * se i dati <b>scritti</B> sull'outputstream <i>possono</i> essere letti dall'altra parte, false
   * se i dati scritti <b>saranno sicuramente ignorati</b> dall'altro estremo della connessione
   * @param canWrite true se la socket e' aperta in scrittura dall'altra parte, ovvero
   * se e' possible che arrivino altri dati da leggere.
   */
  public void manageConnection(SocketAddress remoteAddress,
                               ObjectInputStream input,
                               ObjectOutputStream output,
                               boolean canRead,
                               boolean canWrite);


}

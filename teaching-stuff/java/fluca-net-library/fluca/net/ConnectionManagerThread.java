package fluca.net;
import java.io.*;
import java.net.*;



/**
 * Questa classe rappresenta un thread di esecuzione per un concurrent connection
 * manager.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public class ConnectionManagerThread implements Runnable{

  /**
   * Lo stream di output della connessione.
   */
  private ObjectOutputStream output = null;

  /**
   * Lo stream di input della connessione.
   */
  private ObjectInputStream input = null;


  /**
   * L'indirizzo remoto della connessione.
   */
  private SocketAddress address = null;

  /**
   * Lo stato della scrittura remota.
   */
  private boolean canWrite = true;

  /**
   * Lo stato della lettura remota.
   */
  private boolean canRead = true;

  /**
   * Il manager che deve essere eseguito concorrentemente.
   */
  private ConcurrentConnectionManager manager = null;


  /**
   * Costruttore di questo oggetto. Il costruttore salva le variabili temporanee,
   * crea un nuovo thread associato a questo oggetto e lo esegue sul connection manager.
   * Sostanzialmente i parametri di questo costruttore rispecchiano quelli da passare
   * al metodo manageConnection(..) del connection manager specificato.
   * <B>ATTENZIONE:</B>questo costruttore e' protetto, e quindi non puo' essere invocato
   * all'infuori del package fluca.net. In altre parole, un thread di gestione delle
   * connessioni puo' essere usato solo all'interno del package fluca.net stesso.
   * @param input lo stream di input
   * @param output lo stream di output
   * @param address l'indirizzo remoto della socket
   * @param canRead lo stato remoto di lettura
   * @param canWrite lo stato remoto di scrittura
   * @param manager il connection manager da eseguire concorrentemente
   * @throws IllegalArgumentException se il connection manager non viene specificato
   */
  protected ConnectionManagerThread(ObjectInputStream input, ObjectOutputStream output,
                                 SocketAddress address, boolean canRead, boolean canWrite,
                                 ConcurrentConnectionManager manager)
  throws IllegalArgumentException{
    this.input = input;
    this.output = output;
    this.canRead = canRead;
    this.canWrite = canWrite;
    this.address = address;
    this.manager = manager;

    if( this.manager == null ){
      throw new IllegalArgumentException("Impossibile avviare un thread di gestione se manca il connection manager");
    }

    // creo un thread su questo oggetto
    Thread t = new Thread(this,"ConnectionManagerThread@"+manager.getClass().getName());
    // avvio il thread
    t.start();
  }


  /**
   * Metodo di esecuzione del thread. Questo metodo esegue semplicemente il
   * metodo di gestione della connessione del connection manager.
   */
  public void run(){
    this.manager.manageConnection(this.address,this.input,this.output,this.canRead,this.canWrite);
  }
}

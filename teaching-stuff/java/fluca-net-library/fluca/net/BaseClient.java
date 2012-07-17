package fluca.net;
import java.io.*;    // necessario per la gestione dell'I/O a stream
import java.net.*;   // necessario per la gestione delle connessioni di rete


/**
 * Questa classe rappresenta una semplice implementazione di un client per programmi
 * di rete. Questa classe mette a disposizione metodi base per effettuare la
 * connessione al BaseServer.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public class BaseClient extends BaseNetClass{



  /**
   * Costruttore della classe. Inizializza la classe e il suo connection manager.
   * @param manager il connection manager utilizzato per gestire la connessione.
   * @throws IllegalArgumentException se il connection manager risulta nullo
   */
  public BaseClient(ConnectionManager manager) throws IllegalArgumentException{
    super();

    if( manager == null ){
      throw new IllegalArgumentException("Impossibile creare un client senza nessun manager di connesione");
    }

    this.manager = manager;
  }




  /**
   * Metodo per l'apertura e gestione di una connessione verso un server.
   * @param remoteAddress l'indirizzo internet remoto
   * @param port la porta del server
   */
  protected final void connectTo(InetAddress remoteAddress, int port){
    // controllo i parametri
    if( remoteAddress == null || port < 0 ){
      // non posso collegarmi ad un indirizzo nullo o ad una porta negativa
      throw new IllegalArgumentException("Indirizzo o numero porta remoto sbagliato!");
    }

    try{
      // creo la connessione verso l'host remoto
      msg("Tentativo di connessione a " + remoteAddress + ":" + port);
      this.connection = new Socket(remoteAddress, port);

      // se sono qui significa che sono collegato, quindi passo la palla
      // al gestore della connessione
      if( this.isConnected() ){
        this.manage();
      }

    }catch(IOException e){
      System.err.println("Errore di I/O durante la connessione");
      e.printStackTrace();
    }

  }


  /**
   * Metodo per la connessione ad un host remoto una volta che sia noto il suo nome
   * simbolico o il suo indirizzo.
   * @param remoteAddress il nome dell'host (es. polaris.ing.unimo.it) o il suo
   * indirizzo in formato stringa
   * @param port la porta su cui ascolta il server
   */
  public void connectTo(String remoteAddress, int port){
    try{
      // converto la stringa passata in un indirizzo internet valido
      InetAddress remote = InetAddress.getByName(remoteAddress);
      this.connectTo(remote, port);
    }catch(UnknownHostException e){
      System.err.println("Errore: l'host "+remoteAddress+" non puo' essere risolto!");
      e.printStackTrace();
    }

  }


  /**
   * Metodo per chiudere una connessione.
   */
  public final void closeConnection(){
    try{
      if (this.isConnected()) {
        this.connection.close();
        this.connection = null;
      }
    }catch(IOException e){
      System.err.println("Errore nella chiusura della connessione client");
      e.printStackTrace();
    }
  }








}

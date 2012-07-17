package fluca.net.secure;
import fluca.net.*;
import java.io.*;
import java.net.*;


/**
 * Client sicuro da utilizzarsi assieme al SecureServer. Gestisce grant di connessione.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public class SecureClient extends BaseClient{

  /**
   * Il grant per questa connessione.
   */
  protected Grant grant = null;


  /**
   * Costruttore principale, accetta il grant da usare sulla connessione.
   * @param manager il manager della connessione.
   * @param grant il grant della connessione
   */
  public SecureClient(ConnectionManager manager, Grant grant){
    super(manager);
    this.grant = grant;
  }


  protected final void sendGrant(ObjectOutputStream oos){
    try{
      // mando il grant
      msg("Invio del grant");
      oos.writeObject(this.grant);
      oos.flush();
    }catch(IOException e){
      System.err.println("Errore di I/O inviando il grant");
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
    // controllo i parametri
    if( remoteAddress == null || port < 0 ){
      // non posso collegarmi ad un indirizzo nullo o ad una porta negativa
      throw new IllegalArgumentException("Indirizzo o numero porta remoto sbagliato!");
    }

    try{
      // creo la connessione verso l'host remoto
      msg("Tentativo di connessione a " + remoteAddress + ":" + port);
      this.connection = new Socket(remoteAddress, port);

      // mando il grant sulla connessione
      ObjectOutputStream oos = new ObjectOutputStream( this.getOutputStream(false) );
      this.sendGrant( oos );
      oos = null;

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



}

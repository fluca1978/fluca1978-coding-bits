package fluca.net.secure;
import fluca.net.*;
import java.io.*;
import java.net.*;

public class SecureServer extends BaseServer{


  /**
   * Grant da verificare per ogni connessione
   */
  protected Grant grant = null;


  /**
   * Costruttore principale, accetta un solo grant da controllare su ogni connessione.
   * @param port porta su cui ascoltare
   * @param manager manager della connessione da usare
   * @param startNow avvia subito il server o no
   * @param grant il grant da usare
   */
  public SecureServer(int port, ConnectionManager manager, boolean startNow, Grant grant){
    super(port, manager, startNow);
    this.grant = grant;
  }



  /**
   * Metodo per controllare il grant di una connessione. <B>Deve agire per primo sulla
   * connessione.</B>
   * @param ois lo stream di lettura della connessione.
   * @return true se la connessione puo' essere effettuata, false altrimenti
   */
  protected final boolean isGrantVerified(ObjectInputStream ois){

    try{
      // tento di leggere il grant
      Grant grantLetto = (Grant) ois.readObject();

      if (grantLetto == null )
        return false;

      // verifico che tipo di grant ho
      if( grantLetto instanceof PasswordGrant && this.grant instanceof PasswordGrant){
        // controllo username e password
        PasswordGrant letto = (PasswordGrant) grantLetto;
        PasswordGrant mio   = (PasswordGrant) this.grant;

        if( letto.getPassword().equals(mio.getPassword()) &&
            letto.getUsername().equals(mio.getUsername()) ){
          return true;
        }
        else
          return false;
      }
      else
      if( grantLetto instanceof AddressGrant && this.grant instanceof AddressGrant ){
        // controllo se gli indirizzi corrispondono
        AddressGrant letto = (AddressGrant) grantLetto;
        AddressGrant mio   = (AddressGrant) this.grant;

        if( letto.getAddress().equals(mio.getAddress()) )
          return true;
        else
          return false;
      }
      else
        return false;

    }catch(IOException e){
      System.err.println("La connessione ha qualche problema");
      e.printStackTrace();
      return false;
    }
    catch(ClassNotFoundException e){
      System.err.println("Impossibile trovare la classe");
      e.printStackTrace();
      return false;
    }
  }



  /**
     * Questo metodo rappresenta il cuore del thread corrente. Si occupa di
     * inizializzare la server socket e di aprirla in ascolto, per
     * accettare connessioni da parte dei client.
     */
    public void run(){
      try{
        // inizializzo la server socket
        ServerSocket server = new ServerSocket(this.listeningPort);

        msg("Socket server creata, entro nel ciclo di attesa");

        // ATTENZIONE: siccome prima/dopo l'accept devo modificare il flag
        // listening, inserisco il pezzo di codice in un blocco synchronized
        synchronized(this){

          // accetto connessioni fino a quando qualcuno non forza lo stop
          // del server
          while( this.isRunning() ){
            // ora mi metto in ascolto
            this.setListening(true);
            msg("Attendo una nuova connessione...");
            this.connection = server.accept();

            // se sono qui ho ricevuto una connessione, quindi imposto
            // il flag relativo a false
            this.setListening(false);

            msg("connessione ricevuta!");
            msg("Client:"+this.connection.getRemoteSocketAddress());


            // gestisco la connessione attraverso il connection manager
            if( this.isConnected() ){
              // ATTENZIONE: a differenza di BaseServer, qui devo verificare
              // il grant sulla connessione
              ObjectInputStream ois = new ObjectInputStream( this.getInputStream(false) );

              if( this.isGrantVerified(ois) )
                this.manage();
              else{
                // devo chiudere la connessione subito
                msg("Connessione chiusa per grant errato");
                // invio una eccezione per segnalare l'errore
                this.connection.close();
                this.connection = null;
              }
            }

            msg("Risveglio di eventuali thread sospesi su richiesta di stream");
            this.notifyAll();
          }
        }


      }catch(IOException e){
        this.setListening(false);
        System.err.println("\n\t[BaseServer] ERRORE GESTIONE SOCKET!");
        e.printStackTrace(System.err);
      }
    }


}

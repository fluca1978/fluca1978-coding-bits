package fluca.net;

import java.io.*;  // necessario per gli stream di lettura/scrittura
import java.net.*; // necessario per le classi di rete


/**
 * Questa classe rappresenta la classe base di un server. La classe gestisce il
 * suo proprio thread e consente di ottenere le socket e gli stream di input/output.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public class BaseServer extends BaseNetClass implements Runnable{

  /**
   * Il thread legato a questa istanza.
   */
  protected Thread myThread = null;




  /**
   * Questo flag indica se il server sta eseguendo (ossia se il suo thread
   * associato e' avviato).
   */
  private boolean running = false;

  /**
   * Questo flag indica se il server si trova in una fase di listening, ossia
   * e' bloccato sulla accept della server socket, o se sta facendo altro.
   */
  private boolean listening = false;



  /**
   * La porta di ascolto di questo server. Per default impostata a 3663.
   */
  protected int listeningPort = 3663;








  /**
   * Costruttore semplice di questa classe, <b>non avvia automaticamente il server</b> ma
   * si limita ad inizializzarlo. <B>Per avviare il server e' necessario invocare
   * il metodo <code>start()</code></b>.
   * @param port la porta di ascolto di questo server (dovrebbe essere maggiore di 1024 per
   * non avere problemi di permessi con il sistema operativo).
   * @param manager il gestore della connessione per le connessioni in ingresso
   * @throws IllegalArgumentException se il gestore della connessione e' nullo
   */
  public BaseServer(int port, ConnectionManager manager)
  throws IllegalArgumentException{

    super();
    this.listeningPort = port;

    if( manager == null ){
      // non e' possibile avviare un server senza un gestore di connessione
      throw new IllegalArgumentException("Impossibile avviare il server senza un gestore di connessione");
    }

    this.manager = manager;
  }

  /**
   * Costruttore sovraccaricato. Questo costruttore consente di specificare l'avvio
   * immediato del server.
   * @param port la porta di ascolto di questo server (dovrebbe essere maggiore di 1024 per
   * non avere problemi di permessi con il sistema operativo).
   * @param manager il gestore della connessione per le connessioni in ingresso
   * @throws IllegalArgumentException se il gestore della connessione e' nullo
   * @param startNow true se il server deve essere avviato ora, false se deve
   * essere avviato in un secondo momento tramite chiamata esplicita al metodo
   * <code>start()</code>
   */
  public BaseServer(int port, ConnectionManager manager, boolean startNow)
  throws IllegalArgumentException{
    this(port, manager);

    // avvio il server se necessario
    if( startNow == true ){
      this.start();
    }
  }



  /**
   * Questo metodo indica se il server sta girando oppure no.
   * @return true se il thread agganciato a questo server sta girando.
   */
  public boolean isRunning(){
    return this.running;
  }

  /**
   * Indica se il server e' bloccato aspettando connessioni da un client, ovvero
   * se si trova nella fase di accept.
   * @return true se il server si trova sulla chiamata accept, false se
   * sta facendo altro (es. recuperando uno stream).
   */
  public boolean isListening(){
    return this.listening;
  }



  /**
   * Metodo (protetto) per abilitare/disabilitare il listening mode.
   * @param value true se il server sta ascoltando, false se no.
   */
  protected void setListening(boolean value){
    this.listening = value;
  }




  /**
   * Metodo per fermare il server in esecuzione.
   */
  public final  void stop(){
    // devo settare il flag di esecuzione a false
    msg("Arresto il server");
    this.running = false;

    // ATTENZIONE: non basta settare il flag a false! Se il server sta eseguendo
    // un accept restera' bloccato li, quindi forzo una connessione fasulla
    // solo per fare uscire il server dal ciclo di accept.
    if( this.isListening() == true ){
      try{
        msg("Forzo auto-connessione per fermare il server");
        Socket client = new Socket("localhost", this.listeningPort);
        client.close();
      }catch(IOException e){
        System.err.println("Errore durante l'auto-connessione per lo stop del server");
        e.printStackTrace();
      }
    }
  }


  /**
   * Metodo di avvio del thread del server.
   * Questo metodo controlla se il server e' gia' in esecuzione con un proprio thread e,
   * in caso contrario, provvedere a creare un nuovo thread associandolo a questa
   * istanza e avviandolo. Una volta avviato, il thread entra nel metodo <code>run()</code>
   * e li resta fino a quando il server non viene fermato (metodo stop()). Da notare
   * che il thread creato e' un <i>demone</i>, ossia un thread di servizio che non
   * produce l'attesa della JVM all'uscita.
   */
  public final synchronized void start(){
    // controllo se il server sta gia' girando
    if( this.running ){
      msg("Il server e' gia' avviato!");
      return;
    }

    // controllo se ho gia' un thread associato a questo server
    if( this.myThread == null ){
      // non ho un thread associato, lo creo
      msg("Devo creare un nuovo thread demone per questo server");
      this.myThread = new Thread(this, "BaseServerThread");
      this.myThread.setDaemon(true);   // un server deve avere un thread demone
    }

    // avvio il thread
    msg("Avvio il thread del server");
    this.myThread.start();
    this.running = true;
    msg("thread del server avviato");
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
        while( this.running == true ){
          // ora mi metto in ascolto
          this.listening = true;
          msg("Attendo una nuova connessione...");
          this.connection = server.accept();

          // se sono qui ho ricevuto una connessione, quindi imposto
          // il flag relativo a false
          this.listening = false;

          msg("connessione ricevuta!");
          msg("Client:"+this.connection.getRemoteSocketAddress());


          // gestisco la connessione attraverso il connection manager
          if( this.isConnected() ){
            this.manage();
          }

          msg("Risveglio di eventuali thread sospesi su richiesta di stream");
          this.notifyAll();
        }
      }


    }catch(IOException e){
      this.listening = false;
      System.err.println("\n\t[BaseServer] ERRORE GESTIONE SOCKET!");
      e.printStackTrace(System.err);
    }
  }

}

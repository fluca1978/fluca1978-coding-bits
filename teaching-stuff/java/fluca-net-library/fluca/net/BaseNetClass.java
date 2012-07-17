package fluca.net;
import java.io.*;  // necessario per gli stream di lettura/scrittura
import java.net.*; // necessario per le classi di rete

/**
 * Questa classe fornisce servizi di base per l'implementazione di semplice client/server
 * di rete. La classe e' astratta, anche se fornisce l'implementazione di tutti i suoi
 * metodi, per indicare che questa classe non fornisce servizi completi, ma solo
 * "pezzi base" per la costruzione di classi di rete funzionanti.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public abstract class BaseNetClass {

  /**
    * Riferimento alla socket remota cui si e' connessi. Se la socket viene utilizzata
    * da un server, significa che <code>connection</code> "punta" al client remoto. Se invece
    * la socket e' utilizzata da un client, significa che <code>connection</code>
    * si riferisce al server remoto.
    */
   protected Socket connection = null;

   /**
     * Questo flag indica se il server/client sta gestendo una connessione ricevuta,
     * ovvero se e' entrato nel metodo <code>manageConnection(..)</code>
     * di un oggetto <code>ConnectionManager</code> ma non ne e' ancora uscito.
     */
    protected boolean managing = false;

    /**
     * Questo flag indica l'abilitazione o meno dell'esecuzione verbose, con
     * mesaggi su stderr.
     */
    protected boolean verbose = true;

    /**
     * Questo flag indica se la connessione e' attiva (connection non e' null).
     */
    private boolean connected = false;


    /**
     * Il manager di una connessione. Questo oggetto viene utilizzato per la gestione
     * di una connessione stabilita.
     */
    protected ConnectionManager manager = null;


    /**
      * Metodo per la stampa di un messaggio in modalita' verbose. Il messaggio stampato comprende
      * il nome della classe e i flag qui presenti.
      * @param msg il messaggio da stampare
      */
     protected final void msg(String msg){
       if( verbose )
         System.err.println("["+this.getClass().getName()+" - "+Thread.currentThread().getName()+"] "+msg+" <managing="+this.managing+">");
     }


     /**
      * Questo metodo fornisce indicazioni sullo stato della connessione. Il metodo
      * auto-imposta il valore del flag connected a seconda dello stato della connessione
      * corrente.
      * @return true se la connessione e' stabilita, false se non e' stabilita.
      */
     public final synchronized boolean isConnected(){
       if( this.connection != null ){
         this.connected = this.connection.isConnected();
       }
       else
         this.connected = false;

       return this.connected;
     }


     /**
      * Questo metodo fornisce indicazioni sullo stato di gestione della connessione.
      * @return true se il server/client sta ancora gestendo la connessione, ovvero non e'
      * ancora ritornato dal metodo <code>manageConnection</code> di un oggetto
      * <code>ConnectionManager</code>, false se e' gia' ritornato.
      */
     public final boolean isManaging(){
       return this.managing;
     }



     /**
      * Metodo per ottenere lo stream di output collegato al client/server attuale.
      * Questo metodo restituisce lo stream di output della socket attualmente
      * servita. E' possibile ottenere null, se non ci sono connessioni, come pure
      * aspettare fino a quando una connessione viene stabilita. Il metodo puo' quindi
      * <b>avere comportamento bloccante!</b>.
      * <BR><B><U>ATTEMZIONE:</U> se il comportamento e' bloccante, deve essere
      * il programmatore a farsi carico del risveglio dei thread sospesi! L'utilizzo
      * di questo metodo in modalita' bloccante e' <U>fortemente sconsigliato</u>
      * nell'implementazione di un client!</B>
      * @param blocking indica se si deve attendere una connessione o no
      * @return lo stream di output per inviare dati
      */
     protected final synchronized OutputStream getOutputStream(boolean blocking) {
       // verifico se c'e' una connessione servita e se mi devo fermare
       // ad aspettarne una
       if ( this.isConnected() == false && blocking == false) {
         // non c'e' una connessione e non devo aspettarne una, quindi
         // ritorno null
         msg("Nessuna connessione presente, nessuno stream di output da fornire");
         return null;
       }
       else {
         try {

           if ( this.isConnected()==false && blocking == true) {
             // non c'e' una connessione di rete ma mi devo bloccare aspettandola
             msg("Attendo una connessione...");
             this.wait();
           }
           // se sono qui ho una connessione, ritorno lo stream di output
           msg("Stream di output pronto");
           return this.connection.getOutputStream();
         }
         catch (InterruptedException e) {
           System.err.println("Problema aspettando una connessione del client");
           e.printStackTrace();
           return null;
         }
         catch (IOException e) {
           System.err.println("Problema di I/O aspettando prelevando lo stream di output");
           e.printStackTrace();
           return null;
         }

       }
     }

     /**
     * Metodo per ottenere lo stream di input collegato al client/server attuale.
     * Questo metodo restituisce lo stream di input della socket attualmente
     * servita. E' possibile ottenere null, se non ci sono connessioni, come pure
     * aspettare fino a quando una connessione viene stabilita. Il metodo puo' quindi
     * <b>avere comportamento bloccante!</b>.
     * <BR><B><U>ATTEMZIONE:</U> se il comportamento e' bloccante, deve essere
     * il programmatore a farsi carico del risveglio dei thread sospesi! L'utilizzo
     * di questo metodo in modalita' bloccante e' <U>fortemente sconsigliato</u>
     * nell'implementazione di un client!</B>
     * @param blocking indica se si deve attendere una connessione o no
     * @return lo stream di input per ricevere dati
     */
     protected final synchronized InputStream getInputStream(boolean blocking){
       // verifico se c'e' una connessione servita e se mi devo fermare
       // ad aspettarne una
       if ( this.isConnected()==false && blocking == false) {
         // non c'e' una connessione e non devo aspettarne una, quindi
         // ritorno null
         msg("Nessuna connessione presente, nessuno stream di input da fornire");
         return null;
       }
       else {
         try {

           if ( this.isConnected()==false && blocking == true) {
             // non c'e' una connessione di rete ma mi devo bloccare aspettandola
             msg("Attendo una connessione...");
             this.wait();
           }
           // se sono qui ho una connessione, ritorno lo stream di output
           msg("Stream di input pronto");
           return this.connection.getInputStream();
         }
         catch (InterruptedException e) {
           System.err.println("Problema aspettando una connessione del client");
           e.printStackTrace();
           return null;
         }
         catch (IOException e) {
           System.err.println("Problema di I/O aspettando prelevando lo stream di input");
           e.printStackTrace();
           return null;
         }

       }

     }


     /**
      * Metodo per gestire una connessione attraverso il connection manager.
      * Questo metodo invoca il metodo <code>manageConnection</code> del
      * connection manager, passando l'indirizzo della socket remota e gli stream
      * di input/output. Il flag <code>managing</code> viene impostato di conseguenza.
      * Il metodo classico di utilizzo di questo metodo e':<br>
      * <code>
      * if( isConnected() ){
      *   manage();
      * }
      * </code>
      * Questo metodo getisce automaticamente l'esecuzione concorrente, preoccupandosi
      * di avviare un nuovo thread per la gestione di una connessione qualora il
      * connection manager specificato sia di tipo <code>ConcurrenteConnectionManager</code>.
      * <B>ATTENZIONE: utilizzare un <code>ConcurrenteConnectionManager</code> come gestore di
      * una connessione di un client potrebbe essere rischioso!</B>
      * @throws IOException se sussiste qualche problema nell'ottenere gli stream
      * dalla connessione corrente
      */
     protected synchronized final void manage() throws IOException{
       // ora devo gestire la connessione
       this.managing = true;
       msg("Gestisco la connessione attraverso il connection manager "+this.manager.getClass().getName());


       // ATTENZIONE: e' necessario ottenere prima lo stream di output di quello
       // di input.
       ObjectOutputStream oos = new ObjectOutputStream( this.getOutputStream(false) );
       oos.flush();     // il flush iniziale non e' indispensabile
       ObjectInputStream ois  = new ObjectInputStream( this.getInputStream(false) );


       // ATTENZIONE: occorre controllare se il connection manager e' sequenziale
       // oppure concorrente. Nel caso sia concorrente occorre avviare un nuovo
       // thread di esecuzione.
       if( this.manager instanceof ConcurrentConnectionManager ){
         // esecuzione concorrente, avvio un nuovo thread
         msg("Avvio un nuovo thread per servire la richiesta");
         new ConnectionManagerThread( ois, oos, this.connection.getRemoteSocketAddress(),
                                      !this.connection.isInputShutdown(),!this.connection.isOutputShutdown(),
                                      (ConcurrentConnectionManager)this.manager);
         msg("Thread avviato");
       }
       else{

         this.manager.manageConnection(this.connection.getRemoteSocketAddress(),
                                       ois, oos, !this.connection.isInputShutdown(),
                                       !this.connection.isOutputShutdown());
       }

       this.managing = false;
       msg("Gestione connessione terminata");
     }


     /**
      * Metodo per abilitare/disabilitare la modalità verbose.
      *
      * @param verbose true se si vuole abilitare la modalita' verbose, false
      * se la si vuole disabilitare
      */
     public void setVerbose(boolean verbose){
       this.verbose = verbose;
     }

}

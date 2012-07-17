package note.gui;
import note.Nota;
import javax.swing.*;
import java.io.*;
import java.awt.event.*;



/**
 * Finestra principale del programma note.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public class FinestraNote extends JFrame implements ActionListener{

  /**
   * Array di note legate a questo programma.
   */
  private Nota[] note = null;

  /**
   * Menu per la visualizzazione delle note inserite fino ad ora.
   */
  private JMenu m_show = null;


  /**
   * Pannello per visualizzare la nota corrente.
   */
  private PannelloNota pannello_nota = null;

  /**
   * File in cui salvare tutte le note di questo programma.
   */
  public static final String file_note = "C:\\note.dat";

  public FinestraNote() {
    // inizializzo il genitore
    super("Programma di gestione delle note");

   // carico le note da file
   this.caricaNoteDaFile();

   // inizializzo il meno "visualizza"
   this.m_show = new JMenu( Keys.KEY_VIEW );

   // inizializzo un menu con le voci per una nuova nota e per
   // l'uscita dal programma
   JMenu m_file = new JMenu( "File" );
   JMenuItem m_new = new JMenuItem( Keys.KEY_NEW );
   JMenuItem m_exit = new JMenuItem( Keys.KEY_EXIT );
   m_new.addActionListener(this);
   m_exit.addActionListener(this);
   m_file.add(m_new);
   m_file.addSeparator();
   m_file.add(m_exit);

   // preparo la barra dei menu
   JMenuBar bar = new JMenuBar();
   bar.add( m_file );
   bar.add(this.m_show);
   this.setJMenuBar(bar);

   // richiedo la sincronizzazione del menu visualizza: scorro l'array delle note
   // e inserisco una voce corrispondente al soggetto di ogni nota.
   this.sincronizzaMenuNote();


   // aggiungo il pannello nota a questa finestra
   this.pannello_nota = new PannelloNota( this.note[0] );
   this.getContentPane().add(this.pannello_nota);

   // aggiungo questa classe come listener per i salvataggi delle note
   this.pannello_nota.addSalvaListener(this);


   // aggiungo un listener per la chiusura della finestra
   this.addWindowListener( new WindowCloser() );

   // imposto la dimensione di questa finestra e la visualizzo
   this.setSize(600,350);
   this.setVisible(true);
 }


  /**
   * Metodo per ricaricare le note dal file delle note. Anzitutto si verifica
   * se il file esiste, nel qual caso viene ricaricato l'array delle note
   * e si provvede ad inserire nel menu ogni soggetto della nota.
   */
  protected void caricaNoteDaFile(){
    try{
      File file = new File( FinestraNote.file_note );

      if( file.exists() ){
        // il file esiste, rileggo l'oggetto array di note
        ObjectInputStream is = new ObjectInputStream( new FileInputStream( file ) );
        this.note = (Nota[]) is.readObject();
      }
      else{
        // il file con le note salvate non esiste, quindi non posso caricare
        // nulla. Inizializzo allora l'array di note per poterne contenere
        // almeno 1
        this.note = new Nota[1];
      }


    }catch(IOException e){
      // errore di I/O, visualizzo una finestra di dialogo con il messaggio di
      // errore
      JOptionPane.showMessageDialog(this,e.getLocalizedMessage(),"I/O ERROR",JOptionPane.ERROR_MESSAGE);
    }
    catch(ClassNotFoundException e){
      JOptionPane.showMessageDialog(this,e.getLocalizedMessage(),"TYPE ERROR",JOptionPane.ERROR_MESSAGE);
    }
  }



  /**
   * Metodo per aggiungere una nota al menu di visualizzazione. Viene aggiunto
   * il soggetto della nota e si aggancia la nota al listener.
   * @param nota la nota da aggiungere
   */
  protected final void inserisciNotaInMenu(Nota nota){

    // controllo che la nota sia valida
    if( nota == null )
      return;


    // aggiungo il soggetto al menu'
    JMenuItem subject = new JMenuItem( nota.getSubject() );
    subject.addActionListener( this );
    this.m_show.add( subject );
  }


  /**
   * Metodo per recuperare una nota in base al soggetto. La ricerca e'
   * case insensitive.
   * @param subject la stringa soggetto da ricercare
   * @return la nota trovata o null in caso non sia presente la nota.
   */
  protected final Nota notaDaSoggetto(String subject){
    // controllo se posso procedere
    if( subject == null || subject.equals("")
       || this.note == null ){
     return null;
   }

   // scorro l'array delle note per trovare quella che ha un soggetto simile
   // (ossia uguale senza case sensitiveness) a quello specificato
   for(int i=0; i<this.note.length; i++){
     if( this.note[i] != null && this.note[i].getSubject().equalsIgnoreCase(subject) ){
       // ho trovato la nota giusta, la restituisco al chiamante
       return this.note[i];
     }
   }

   // se sono qui non ho trovato nessuna nota
   return null;
  }

  /**
   * Metodo per inserire e sincronizzare il menu di visualizzazione con le note
   * attualmente caricate in memoria.
   */
  protected void sincronizzaMenuNote(){
    for(int i=0;this.note != null && i<this.note.length; i++){
      this.inserisciNotaInMenu(this.note[i]);
    }
  }

  /**
   * Metodo per analizzare gli eventi generati dai vari controlli.
   * @param event l'evento generato
   */
  public void actionPerformed(ActionEvent event){
    // prelevo la stringa di comando
    String command = event.getActionCommand();

    // controllo se la stringa corrisponde ad un soggetto di una nota
    Nota da_visualizzare = this.notaDaSoggetto( command );

    // se il comando corrispondeva al soggetto di una nota, ora ho trovato
    // la relativa nota e la posso visualizzare, altrimenti il comando
    // si riferisce ad una voce di menu
    if( da_visualizzare != null ){
      this.pannello_nota.setNota( da_visualizzare );
      return;
    }

    // se sono qui il comando si riferisce ad una voce di menu o a qualcosa
    // relativo ai pulsanti

    if( command.equals( Keys.KEY_NEW ) ){
      // chiedo all'utente il subject della nuova nota
      String subject = JOptionPane.showInputDialog(this,"Inserire il soggetto della nota:","Nuova Nota",JOptionPane.OK_CANCEL_OPTION);
      try{
        // creo la nota con il soggetto e nessun testo
        Nota nota = new Nota(subject, "");
        // chiedo al pannello di visualizzare questa nota
        this.pannello_nota.setNota( nota );
        // ordino di aggiungere questa nota all'array e di sincronizzare
        // il menu dei soggetti
        this.aggiungiNota( nota );
      }catch(IllegalArgumentException e){
        JOptionPane.showMessageDialog(this,
                                      "Non si puo' usare un soggetto nullo",
                                      "ERRORE", JOptionPane.ERROR_MESSAGE);
      }
    }
    else
    if( command.equals( Keys.KEY_SAVE ) ){
      // e' arrivato l'ordine di salvataggio, salvo tutto l'array
      try{
        ObjectOutputStream os = new ObjectOutputStream( new FileOutputStream( FinestraNote.file_note ) );
        os.writeObject( this.note );
      }catch(IOException e){
        JOptionPane.showMessageDialog(this,"Errore durante il salvataggio","ERRORE I/O",JOptionPane.ERROR_MESSAGE);
      }
    }
    else
    if( command.equals( Keys.KEY_EXIT ) ){
      // uscita, distruggo questa finestra
      this.setVisible(false);
      this.dispose();
      System.exit(0);
    }
  }


  protected final void aggiungiNota(Nota nota){
    if( nota == null )
      return;

    // controllo se l'array di note e' nullo, nel caso lo creo
    if( this.note == null ){
      this.note = new Nota[1];
      this.note[0] = nota;
    }
    else{
      Nota tmp[] = new Nota[ this.note.length + 1 ];
      System.arraycopy(this.note,0,tmp,0,this.note.length);
      tmp[this.note.length] = nota;
      this.note = tmp;
    }

    // richiedo l'allineamento del menu
    this.inserisciNotaInMenu( nota );
  }
}

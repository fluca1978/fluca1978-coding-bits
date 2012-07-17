package note.gui;
import note.Nota;
import javax.swing.*;
import java.awt.event.*;
import java.awt.*;

/**
 * Questa classe rappresenta un JPanel capace di visualizzare una nota di testo.
 * Il pannello si occupa della visualizzazione della nota e del suo soggetto,
 * nonche' della possibilita' di inserimento di nuovo testo.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public class PannelloNota extends JPanel implements ActionListener{

  /**
   * La nota di testo legata a questo pannello.
   */
  protected Nota nota;

  /**
   * L'etichetta che visualizzera' il soggetto della nota corrente.
   */
  protected JLabel subject = null;

  /**
   * Il textarea che mostrera' il contenuto della nota corrente.
   */
  protected JTextArea showing = null;

  /**
   * Il textarea per eventuali aggiunte.
   */
  protected JTextArea adding = null;


  /**
   * Il pulsante per fare l'append del testo.
   */
  protected JButton b_aggiungi = null;

  /**
   * Il pulsante per cambiare il testo della nota con quello corrente (no
   * append).
   */
  protected JButton b_cambia = null;


  /**
   * Pulsante per effettuare il salvataggio su disco della nota corrente.
   */
  protected JButton b_salva = null;

  /**
   * Pulsante per cancellare i pannelli di visualizzazione della nota corrente.
   */
  protected JButton b_clear = null;

  /**
   * Pulsante per rendere la nota corrente un post-it.
   */
  protected JButton b_postit = null;


  /**
   * Riferimento al post it corrente.
   */
  protected PostIt w_postit = null;


  /**
   * Pulsante per invalidare la nota corrente.
   */
  protected JButton b_invalida = null;

  public PannelloNota(Nota nota) {
    // inizializzo il genitore
    super();

    // aggancio la nota corrente
    this.nota = nota;


    // creo i pulsanti
    this.b_aggiungi = new JButton(Keys.KEY_APPEND);
    this.b_cambia   = new JButton(Keys.KEY_CHANGE);
    this.b_clear    = new JButton(Keys.KEY_CLEAR);
    this.b_salva    = new JButton(Keys.KEY_SAVE);
    this.b_invalida = new JButton(Keys.KEY_INVALID);
    this.b_postit   = new JButton(Keys.KEY_POSTIT);

    // imposto questa classe come listener di eventi per i pulsanti
    this.b_aggiungi.addActionListener(this);
    this.b_cambia.addActionListener(this);
    this.b_clear.addActionListener(this);
    this.b_salva.addActionListener(this);  // non necessario, l'evento non viene trattato qui
    this.b_invalida.addActionListener(this);
    this.b_postit.addActionListener(this);

    // creo i campi di testo (5 righe, 20 colonne)
    this.showing = new JTextArea(5,20);
    this.adding  = new JTextArea(5,20);

    // creo l'etichetta per il subject
    this.subject = new JLabel("Subject: ",JLabel.CENTER);


    // ora imposto il layout manager
    this.setLayout( new BorderLayout());



    // aggiungo i componenti
    this.add(this.subject,BorderLayout.NORTH);
    this.add(new JScrollPane(this.showing),BorderLayout.CENTER);
    // ATTENZIONE: a sud aggiungo un pannello annidato
    JPanel nested = new JPanel();
    nested.setLayout(new BorderLayout());
    nested.add(new JScrollPane(this.adding),BorderLayout.CENTER);
    JPanel buttons = new JPanel();
    buttons.setLayout( new GridLayout(6,1));
    buttons.add(this.b_aggiungi);
    buttons.add(this.b_cambia);
    buttons.add(this.b_clear);
    buttons.add(this.b_invalida);
    buttons.add(this.b_salva);
    buttons.add(this.b_postit);
    nested.add(buttons,BorderLayout.EAST);
    this.add(nested,BorderLayout.SOUTH);

    // imposto la nota
    this.visualizzaNota();

  }

  /**
   * Metodo di risposta agli eventi dei componenti di questo pannello.
   * @param event l'evento generato
   */
  public void actionPerformed(ActionEvent event){
    // ottengo la stringa di comando dell'evento
    String command = event.getActionCommand();

    // NOTA: siccome disabilito/abilito i pulsanti a seconda della presenza
    // o meno di una nota, non devo controllare se this.nota e' null,
    // in quanto un comando puo' arrivare solo con i pulsanti abilitati,
    // ossia solo se c'e' gia' una nota non null.

    // analizzo il comando ricevuto
    if( command.equals(Keys.KEY_APPEND) ){
      // devo fare l'append sulla nota
      this.nota.appendText( this.adding.getText() );
    }
    else
    if( command.equals( Keys.KEY_CHANGE ) ){
      // devo cambiare la nota
      this.nota.setText( this.adding.getText() );
    }
    else
    if( command.equals( Keys.KEY_CLEAR ) ){
      // devo cancellare la nota corrente dalla visualizzazione
      this.nota = null;
    }
    else
    if( command.equals( Keys.KEY_INVALID ) ){
      // devo invalidare la nota
      this.nota.setValid(false);
    }
    else
    if( command.equals( Keys.KEY_POSTIT ) ){
      // devo rendere la nota un post-it e cambiare il pulsante
      if( this.nota != null ){
        this.w_postit = new PostIt(this.nota);
        this.b_postit.setText( Keys.KEY_UNPOSTIT );
      }
    }
    else
    if( command.equals( Keys.KEY_UNPOSTIT ) ){
      // devo rimuovere il post-it
      this.w_postit.setVisible(false);
      this.w_postit.dispose();
      this.w_postit = null;
      this.b_postit.setText( Keys.KEY_POSTIT );
    }

    // chiedo sempre di rivisualizzare la nota
    this.visualizzaNota();

  }


  /**
   * Metodo per visualizzare la nota corrente. Viene impostata l'etichetta di
   * soggetto, viene mostrato il testo nel pannello showing e viene sbiancato
   * quello per le aggiunte. Oltre a questo si abilitano i pulsanti e i campi
   * di testo.
   */
  protected void visualizzaNota(){
    // controllo che la nota corrente sia valida
    if(this.nota == null){
      // nessuna nota, sbianco i campi e disabilito i pulsanti
      this.showing.setText("");
      this.adding.setText("");
      this.subject.setText("Subject: ");
      this.b_aggiungi.setEnabled(false);
      this.b_cambia.setEnabled(false);
      this.b_clear.setEnabled(false);
      this.b_salva.setEnabled(false);
      this.b_invalida.setEnabled(false);
      this.b_postit.setEnabled(false);
    }
    else{
      // ho una nota, la visualizzo
      this.subject.setText("Suibject: "+this.nota.getSubject());
      this.showing.setText(this.nota.getText());
      this.adding.setText("");
      // ATTENZIONE: abilito i pulsanti e il campo di aggiunta solo se la
      // nota non e' scaduta (e' ancora valida)
      if( this.nota.isValid() ){
        this.b_aggiungi.setEnabled(true);
        this.b_cambia.setEnabled(true);
        this.b_clear.setEnabled(true);
        this.b_salva.setEnabled(true);
        this.b_invalida.setEnabled(true);
        this.b_postit.setEnabled(true);
      }
      else{
        // visualizzo una etichetta per dire che la nota non e' piu' valida
        this.subject.setText( this.subject.getText() + " - NON PIU' VALIDA");
        this.b_invalida.setEnabled(false);
        this.b_aggiungi.setEnabled(false);
        this.b_cambia.setEnabled(false);
        this.b_postit.setEnabled(false);
      }

    }

    // disabilito sempre il campo showing, non si puo' editare in quello ma
    // solo in quello di aggiunta
    this.showing.setEnabled(false);
  }


  /**
   * Metodo per cambiare la nota corrente.
   * @param nota la nuova nota da visualizzare
   */
  public void setNota(Nota nota){
    this.nota = nota;
    this.visualizzaNota();

    // ATTENZIONE: se l'utente ha attivato un post-it lo rimuovo perché la
    // nota cambia
    if( this.w_postit != null ){
      this.w_postit.setVisible(false);
      this.w_postit.dispose();
      this.w_postit = null;
      this.b_postit.setText( Keys.KEY_POSTIT );
    }
  }

  /**
   * Metodo per aggiungere un listener interessato al salvataggio di questa nota.
   * @param listener il listener incaricato di gestire il salvataggio di questa nota.
   */
  public void addSalvaListener(ActionListener listener){
    this.b_salva.addActionListener(listener);
  }

  /**
   * Metodo per restituire la nota corrente.
   * @return la nota correntemente legata a questo pannello.
   */
  public Nota getNota(){
    return this.nota;
  }
}

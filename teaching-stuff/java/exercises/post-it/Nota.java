package note;
import java.io.Serializable;
import java.util.Calendar;


/**
 * Questa classe rappresenta una semplice nota di testo. Una nota ha un soggetto,
 * un contenuto e una validita', che indica se e' gia' scaduta o meno.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public class Nota implements Serializable{


  /**
   * Il soggetto di questa nota.
   */
  protected String subject = null;

  /**
   * Il testo di questa nota.
   */
  protected String text = null;

  /**
   * La validita' di questa nota. Per impostazione di default una nota
   * e' sempre valida.
   */
  protected boolean valid = true;

  /**
   * Costruttore base di una nota. E' necessario specificare il soggetto e
   * il contenuto della nota. Qualora il soggetto sia nullo viene sollevata
   * una eccezione (le note sono identificate dal loro soggetto, quindi il soggetto
   * deve essere diverso da null).
   * @param subject il soggetto che identifica questa nota
   * @param text il contenuto della nota (puo' essere nullo)
   * @throws IllegalArgumentException sollevata se il soggetto e' nullo
   */
  public Nota(String subject, String text) throws IllegalArgumentException {

    // controllo che il soggetto sia una stringa testuale "valida"
    if (subject == null || subject.equals("")
        || subject.equals("\n") || subject.equals("\t")) {
      throw new IllegalArgumentException(
          "E' necessario specificare un soggetto testuale per la nota");
    }

    // inizializzo i campi
    this.subject = subject;
    this.text = text;
  }

  /**
   * Metodo per ottenere il soggetto di questa nota.
   * @return il soggetto della nota corrente
   */
  public String getSubject() {
    return this.subject;
  }

  /**
   * Metodo per ottenere il contenuto della nota.
   * @return il testo contenuto in questa nota.
   */
  public String getText() {
    return this.text;
  }

  /**
   * Indica se la nota e' ancora valida.
   * @return true se e' valida, false se e' gia' stata controllata.
   */
  public boolean isValid() {
    return this.valid;
  }

  /**
   * Metodo per impostare la valida di una nota.
   * @param valid true se la nota deve essere mantenuta valida, false
   * se deve essere invalidata.
   */
  public void setValid(boolean valid) {
    this.valid = valid;
  }

  /**
   * Metodo per cambiare il testo della nota.
   * @param newText il nuovo testo di questa nota.
   */
  public void setText(String newText) {
    this.text = newText;
  }


  /**
   * Metodo per aggiungere del testo in coda alla nota. Il testo viene aggiunto
   * con una nota che riporta la data dell'aggiunta. L'aggiunta figura su una nuova
   * linea con la dicitura speciale [Aggiunta giorno/mese - ora:minuti].
   * @param toAppend il testo da aggiungere alla nota.
   */
  public void appendText(String toAppend){
    // ottengo un oggetto che mi fornisce indicazioni sulla data
    Calendar calendario = Calendar.getInstance();


    // appendo il testo alla nota
    this.text += "\n[Aggiunta "+ calendario.get(Calendar.DAY_OF_MONTH) + "/"
                               + calendario.get(Calendar.MONTH) + " - "
                               + calendario.get(Calendar.HOUR) + ":"
                               + calendario.get(Calendar.MINUTE) + "] "
                               + toAppend;
  }
}

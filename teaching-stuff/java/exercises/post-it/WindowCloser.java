package note.gui;

import java.awt.event.*;

/**
 * Classe per la chiusura della applicazione alla chiusura della finestra.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public class WindowCloser extends java.awt.event.WindowAdapter{
  /**
   * Metodo invocato automaticamente alla chiusura della finestra cui e' agganciata
   * l'istanza di questa classe.
   * @param event evento di finestra
   */
  public void windowClosing(WindowEvent event)
    {
        System.out.println("Chiusura della finestra e dell'applicazione");
        System.out.println("Evento ricevuto: "+event);
        System.exit(0);
    }

}

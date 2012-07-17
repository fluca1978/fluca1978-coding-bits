package fluca.net.secure;
import java.net.InetAddress;

/**
 * Un grant che rappresenta un indirizzo, ovvero consente di specificare connessioni
 * provenienti da un determinato indirizzo.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public class AddressGrant extends Grant{

  /**
   * L'indirizzo remoto della connessione.
   */
  private InetAddress remoteAddress = null;


  /**
   * Costruttore principale.
   * @param address l'indirizzo remoto per questo grant
   */
  public AddressGrant(InetAddress address){
    super();
    this.remoteAddress = address;
  }


  /**
   * Restituisce l'indirizzo remoto del grant. Il metodo e' protetto!
   * @return l'indirizzo remoto del grant
   */
  protected InetAddress getAddress(){
    return this.remoteAddress;
  }

}

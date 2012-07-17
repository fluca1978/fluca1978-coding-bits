package fluca.net.secure;

/**
 * Questa classe rappresenta un grant per una coppia username/password.
 * @author Luca Ferrari fluca1978 (at) gmail (dot) com
 * @version 1.0
 */
public class PasswordGrant extends Grant{
  private String username = null;
  private String password = null;    // dovrebbe essere un char[], ma per semplicita' usiamo una String

  /**
   * Costruttore di questo grant.
   * @param username lo username da inviare al server
   * @param password la password da inviare al server
   */
  public PasswordGrant(String username, String password){
    this.username = username;
    this.password = password;
  }


  /**
   * Restituisce lo username. Il metodo e' protetto!
   * @return lo username del grant
   */
  protected String getUsername(){
    return this.username;
  }

  /**
   * Restituisce la password del grant. Il metodo e' protetto!
   * @return la password del grant
   */
  protected String getPassword(){
    return this.password;
  }


}

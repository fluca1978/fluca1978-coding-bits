package automobili;



/**
 * Classe che definisce il concetto di automobile.
 */
public class Automobile
{
    /**
     * Marca dell'automobile.
     */
    private String marca;

    /**
     * Modello
     */
    private String modello;

    /**
     * Cilindrata, espressa in cc.
     */
    private int cilindrata;

    /**
     * Potenza, espressa in kW
     */
    private float potenza; 


    
    /**
     * Costruttore di default
     *@param marca la marca dell'automobile
     *@param modello il modello dell'automobile
     *@param cilindrata la cilindrata dell'automobile
     *@param potenza la potenza dell'automobile
     */
 public Automobile (String marca,String modello,int cilindrata,float potenza) {
     this.marca = marca;
     this.modello = modello;
     this.cilindrata = cilindrata;
     this.potenza = potenza;	
 }	

    /**
     * Metodo per sapere la marca .
     *@return la marca dell'automobile
     */
    public String getMarca(){
	return this.marca;
    }

    /**
     * Metodo per sapere il modello.
     *@return il modello dell'auto
     */
    public String getModello(){
	return modello;
    }

    /**
     * Metodo per sapere la cilindrata
     *@return la cilindrata dell'auto
     */
    public int getCilindrata(){
	return cilindrata;
    }


    /**
     * Metodo per ottenere la potenza.
     *@return la potenza dell'auto
     */
    public float getPotenza(){
	return potenza;
    }
 
    /**
     * Metodo per determinare se due oggetti istanza di questa classe sono uguali. Due automobili
     * sono considerate uguali se e solo se i loro attributi (marca,modello,ecc.) sono uguali.
     *@return true se le auto sono uguali
     *@param toCompare oggetto da confrontare con quello corrente
     */
    public boolean equals(Object toCompare){

	// Primo test da eseguire sempre quando si sovrascrive equals: l'oggetto di confronto e' istanza 
	// di questa classe?
	if(!(toCompare instanceof Automobile)){
	    return false;
	}

	// ora che so che toCompare e' un automobile mi creo un riferimento di tipo automobile per
	// praticita'
	Automobile car = (Automobile)toCompare;

	// controllo se tutti i campi sono uguali
	if(this.marca.equals(car.getMarca()) && this.modello.equals(car.getModello())
	   && this.cilindrata==car.cilindrata && this.potenza == car.getPotenza() ){
	    // sono uguali
	    return true;
	}


	// test piu' veloce => senza chiamata di metodi
	//	if(this.marca.equals(car.marca) && this.modello.equals(car.modello) &&
	//         this.potenza==car.potenza && this.cilindrata==car.cilindrata){
	//            return true;
	//      }

	return false;
    }
 

}

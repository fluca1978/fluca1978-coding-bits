package ficList.test;


public class Persona {
	private String nome;
	private String via;
	private int civico;
	
	
	public Persona(String nome){
		this.nome=nome;
		this.via=null;
		this.civico=0;
	}
	
	public Persona(String nome,String via,int civico){
		this.nome=nome;
		this.via=via;
		this.civico=civico;
	}
	
	public void setVia(String via){
		this.via=via;
	}
	
	public void setCivico(int civico){
		this.civico=civico;
	}
	
	public String getNome(){
		return nome;
	}
	
	public String toString(){
		return nome+" - "+via+" "+civico;
	}
	
	public boolean equals(Persona p){
		return (nome.compareToIgnoreCase(p.getNome())==0);
	}
}

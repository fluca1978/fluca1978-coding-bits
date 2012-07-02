/* CC_private */

/* 
 * Questo file contiene l'implementazione del conto corrente vero e proprio.
 * L'interfaccia pubblica del conto corrente (ContoCorrentePub) è già stata
 * definita nel file header CC_pub.h (qui incluso per avere visione della struttura
 * pubblica), mentre qui viene definita una struttura privata, che contiene anche
 * i dati legati ad ogni conto corrente. L'idea è quella di avere due strutture
 * "simili", una che fornisce l'interfaccia pubblica, ed una che fornisce
 * anche la parte privata. Se le due strutture coincidono nella loro parte iniziale
 * (ossia hanno gli stessi campi, nello stesso ordine, all'inizio), allora
 * è possibile allocare memoria per la struttura più grande delle due (quella
 * privata) e convertirla dinamicamente in quella ridotta e pubblica. Successivamente,
 * dato un puntatore alla struttura pubblica, è possibile tramutarlo in un puntatore
 * a quella privata (si ricordi che la memoria allocata è contigua). In sostanza
 * quello che avviene è spiegato dalla seguente figura:

		-	+--------------+ -
		|	|   m_saldo    | |
		|	+--------------+ |
		|	|   m_stampa   | |
           Conto|	+--------------+ |	Conto
        Corrente|	| m_versamento | |	Corrente
             Pub|	+--------------+ |	Private
		|	| m_prelievo   | |
		|	+--------------+ |
		|	|m_stampa_movim| |
		-	+--------------+ |
			| NumeroConto  | |
			+--------------+ |
			|    Saldo     | |
			+--------------+ |
			|   Movimenti  | |
			+--------------+ |
			|   cur_mov    | |
			+--------------+ -


 * Si noti che ogni operazione pubblica accetta come parametro un puntatore
 * di tipo ContoCorrentePub, che viene poi convertito in uno di tipo
 * ContoCorrentePrivate dal servizio (privato, poiché static) Public2Private.
 * Quest'ultimo, non fa altro che eseguire un semplice cast (conversione di tipo)
 * fra i puntatori. Ancora una volta, questa operazione è possibile (ed ha successo)
 * perché è stata allocata memoria sufficiente a contenere un ContoCorrentePrivate,
 * restituendo poi un puntatore ContoCorrentePub che punta allo stesso indirizzo di
 * memoria (dove inizia la parte di struttura sovrapposta fra le due versioni - pubblica
 * e privata).
 */


#include <stdio.h>
#include <stdlib.h>
// includo l'interfaccia pubblica del modulo di conto corrente
// per avere accesso al tipo pubblico
#include "CC_pub.h"			
							




// costante che rappresenta il massimo numero di movimenti registrabili
#define MAX_MOVIMENTI 30

// Definizione della struttura dati privata.
// Questa struttura dati deve avere la stessa forma iniziale della struttura pubblica,
// e contenere i dati privati come ultimi campi.
typedef struct{
  // struttura pubblica
  ContoCorrentePub pub;

	//------------------------------------------
	
	// dati nascosti
	int NumeroConto;			// numero del conto corrente
	int Saldo;				// saldo attuale
	int Movimenti[MAX_MOVIMENTI];		// lista degli ultimi movimenti
	int cur_mov;				// indice del movimento corrente
} ContoCorrentePrivate;





/* 
 * Servizio privato di conversione dalla struttura pubblica a quella privata.
 * Questa funzione accetta il puntatore alla struttura pubblica e lo converte in quello a
 * struttura privata. 
 */

static ContoCorrentePrivate* Public2Private(ContoCorrentePub* ccpub){
	

	ContoCorrentePrivate* ccpriv = NULL;	// puntatore da ritornare

	// controllo se il puntatore è valido, e in caso punti realmente
	// alla struttura pubblica lo converto (operazione di casting)
	// nella struttura privata
	if( ccpub != NULL ){
		printf("\n\t[Public2Private] conversione della struttura da pub a private");
		ccpriv = (ContoCorrentePrivate*) ccpub;
	}

	return ccpriv;
}



/* 
 * Servizio privato di conversione della struttura privata in quella pubblica.
 * La funzione accetta il puntatore alla struttura privata e, se quest'ultimo è
 * valido, lo converte in un puntatore alla struttura pubblica. 
 */
static ContoCorrentePub* Private2Public(ContoCorrentePrivate* ccpriv){

	ContoCorrentePub* ccpub = NULL;		// puntatore da restituire

	// controllo se il puntatore è valido, e in caso affermativo
	// lo converto in un puntatore alla struttura pubblica
	if( ccpriv != NULL ){
		printf("\n\t[Private2Pub] conversione della struttura da private a pub");
		ccpub = (ContoCorrentePub*) ccpriv;
	}

	return ccpub;
}




/* 
 * Servizio privato di registrazione di un movimento 
 */
static void registraMovimento(ContoCorrentePrivate* ccpriv, int ammontare){
	// se ho già registrato MAX_MOVIMENTI riparto da zero
	if( ccpriv->cur_mov >= MAX_MOVIMENTI ){
		ccpriv->cur_mov = 0;
	}

	ccpriv->Movimenti[ccpriv->cur_mov] = ammontare;
	ccpriv->cur_mov++;
}





/* 
 * Servizio pubblico per la stampa delle informazioni di un conto corrente.
 * La funzione accetta un puntatore alla struttura pubblica, la converte in un 
 * puntatore a quella privata e stampa i vari dati nascosti. 
 */
void StampaContoCorrente(ContoCorrentePub* ccpub){

	ContoCorrentePrivate* ccpriv = NULL;

	// verifico se il puntatore passato è valido
	if( ccpub == NULL ){
		return;
	}

	// conversione a struttura privata
	ccpriv = Public2Private( ccpub );

	// stampa dei campi
	printf("\n----------- INFORMAZIONI SUL CONTO CORRENTE ---------");
	printf("\nNumero di conto: %d", ccpriv->NumeroConto);
	printf("\nSaldo corrente: %d",  ccpriv->Saldo);
	printf("\nNumero di movimenti registrati: %d", ccpriv->cur_mov);
	printf("\n-----------------------------------------------------");
}


/* 
 * Servizio pubblico per l'informazione sul saldo attuale. 
 * Questa funzione ritorna il valore del saldo corrente, o -1 in caso di
 * errore (es. il puntatore passato come parametro non è valido).
 */
int getSaldo(struct CCPUB* ccpub){

	ContoCorrentePrivate* ccpriv = NULL;

	// converto la struttura da pubblica a privata e restituisco
	// il valore del saldo
	ccpriv = Public2Private( ccpub );

	if( ccpriv != NULL ){
		return ccpriv->Saldo;
	}
	else
		return -1;
	
}





/* 
 * Servizio pubblico di versamento.
 * Questo servizio accetta come parametro il puntatore alla struttura pubblica, provvede
 * alla sua conversione a privata ed esegue il versamento.
 * La funzione ritorna l'effettivo ammontare versato. 
 */
int versamento(ContoCorrentePub* ccpub, int ammontare){
	ContoCorrentePrivate* ccpriv;
	

	// controllo che il puntatore sia valido e che l'ammontare sia positivo
	if( ccpub == NULL || ammontare <= 0 ){
		return 0;
	}

	// effettuo il versamento
	ccpriv = Public2Private( ccpub );
	ccpriv->Saldo += ammontare;
	registraMovimento( ccpriv, ammontare );
	return ammontare;
}



/* 
 * Servizio pubblico di prelievo.
 * Questo servizio accetta il puntatore alla struttura pubblica, lo converte
 * in uno alla struttura privata ed effettua il prelievo. Viene restituito
 * il valore effettivamente prelevato. 
 */
int prelievo(ContoCorrentePub* ccpub, int ammontare){
	ContoCorrentePrivate* ccpriv;
	int tmp;

	// controllo che il puntatore sia valido e l'ammontare sia positivo
	if( ccpub == NULL || ammontare <= 0 ){
		return 0;
	}

	// conversione del puntatore per ottenere la struttura privata
	ccpriv = Public2Private( ccpub );

	// se ho un saldo superiore al prelievo, effettuo l'operazione,
	// altrimenti prelevo il massimo possibile
	if( ccpriv->Saldo >= ammontare ){
		ccpriv->Saldo -= ammontare;
		registraMovimento( ccpriv, ammontare * (-1) );
		return ammontare;
	}
	else{
		tmp = ccpriv->Saldo;
		ccpriv->Saldo = 0;
		registraMovimento( ccpriv, tmp * (-1) );
		return tmp;
	}

}



/* 
 * Servizio pubblico di stampa dei movimenti. 
 */
void stampaMovimenti(ContoCorrentePub* ccpub){
	ContoCorrentePrivate* ccpriv;
	int i;

	// conversione e controllo del puntatore
	if( (ccpriv = Public2Private( ccpub )) != NULL ){
		for(i=0; i < ccpriv->cur_mov && i < MAX_MOVIMENTI; i++)
			printf("\nMovimento %d, valore %d", i, ccpriv->Movimenti[i]);
	}
}


/* 
 * Servizio pubblico di generazione di un nuovo conto corrente. Questa
 * funzione accetta il numero del nuovo corrente da aprire e crea/inizializza
 * una struttura dati privata (ContoCorrentePrivate), per poi restituire il
 * puntatore alla struttura pubblica (ContoCorrentePub). 
 */
ContoCorrentePub* aperturaContoCorrente(int numero_conto){

	ContoCorrentePrivate* ccpriv = NULL;

	// alloco memoria per il nuovo conto corrente
	ccpriv = (ContoCorrentePrivate*) malloc( sizeof(ContoCorrentePrivate) );

	// controllo se la malloc ha allocato effettivamente memoria
	if( ccpriv != NULL ){
		// il nuovo conto corrente è stato generato, lo inizializzo
		printf("\n\t[aperturaContoCorrente] inizializzazione dati conto corrente");
		ccpriv->NumeroConto = numero_conto;
		ccpriv->Saldo       = 0;
		ccpriv->cur_mov     = 0;

		// "aggancio" i puntatori alle relative funzioni
		ccpriv->pub.saldo              = getSaldo;
		ccpriv->pub.m_stampa           = StampaContoCorrente;
		ccpriv->pub.m_versamento       = versamento;
		ccpriv->pub.m_prelievo         = prelievo;
		ccpriv->pub.m_stampa_movimenti = stampaMovimenti;

	}

	// restituisco il conto corrente creato (o NULL se non si è riusciti
	// ad allocare memoria
	return Private2Public(ccpriv);
}

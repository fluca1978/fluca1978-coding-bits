/* Main.cpp */
/* 
 * Programma che utilizza il conto corrente realizzato con strutture
 * "modificanti" in stile OOP. 
 */

// author: Luca Ferrari fluca1978 at gmail.com


#include <stdio.h>
// include che definisce la versione pubblica
// della struttura ContoCorrente
#include "CC_pub.h"		
						


int main(void){
	ContoCorrentePub* C1;
	ContoCorrentePub* C2;



	printf("\nProgramma in esecuzione\n");

	// creo i conti corrente
	C1 = aperturaContoCorrente( 3663 );
	C2 = aperturaContoCorrente( 8026 );


	// effettuo dei versamenti
	C1->m_versamento( C1, 10000 );
	C2->m_versamento( C2, 7000 );

	// effettuo un prelievo ed un versamento combinato
	C1->m_versamento( C1, C2->m_prelievo(C2, 2000) );

	// richiedo la stampa delle informazioni dei conti
	C1->m_stampa(C1);
	C2->m_stampa(C2);

	// stampa dei movimenti 
	C1->m_stampa_movimenti( C1 );
	C1->m_stampa_movimenti( C2 );

	/* Se tento di accedere direttamente ai campi nascosti della struttura
	otttengo un errore di compilazione:
		C1->Saldo = 3000;
	produce come output:
	"Error: Saldo is not a member of CCPUB"

	Se cerco di convertire la struttura
		ContoCorrentePrivate ccpriv = (ContoCorrentePrivate*) C1;
	ottengo un errore di compilazione poiché ContoCorrentePrivate è un tipo
	dichiarato in un altro file e non "importato" esplicitamente. */


	// fine del programma
	getchar();		// aspetto che l'utente prema un tasto per terminare
}




/************  OUTPUT DI ESECUZIONE *********************/
/*

Programma in esecuzione

	[aperturaContoCorrente] inizializzazione dati conto corrente
	[Private2Pub] conversione della struttura da private a pub
	[aperturaContoCorrente] inizializzazione dati conto corrente
	[Private2Pub] conversione della struttura da private a pub
	[Public2Private] conversione della struttura da pub a private
	[Public2Private] conversione della struttura da pub a private
	[Public2Private] conversione della struttura da pub a private
	[Public2Private] conversione della struttura da pub a private
	[Public2Private] conversione della struttura da pub a private
----------- INFORMAZIONI SUL CONTO CORRENTE ---------
Numero di conto: 3663
Saldo corrente: 12000
Numero di movimenti registrati: 2
-----------------------------------------------------
	[Public2Private] conversione della struttura da pub a private
----------- INFORMAZIONI SUL CONTO CORRENTE ---------
Numero di conto: 8026
Saldo corrente: 5000
Numero di movimenti registrati: 2
-----------------------------------------------------
	[Public2Private] conversione della struttura da pub a private
Movimento 0, valore 10000
Movimento 1, valore 2000
	[Public2Private] conversione della struttura da pub a private
Movimento 0, valore 7000
Movimento 1, valore -2000

*/



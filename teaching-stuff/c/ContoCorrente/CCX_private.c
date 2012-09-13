// file CCX_private.c

#include <stdio.h>
#include <stdlib.h>
#include "CCX_pub.h"


/*
 * Struttura che implementa il conto corrente con numero di carta.
 */
typedef struct CCX_private{
  
  // riferimento alla parte pubblica
  ContoCorrenteConCartaPub pub;

  /*------ dati nascosti ------------*/

  
  // numero della carta di credito
  char* numero_carta;
  
} ContoCorrenteConCartaPrivate;





//------------------------------------------
//------------------------------------------
//   METODI INTERNI DI CONVERSIONE 



static ContoCorrenteConCartaPrivate* Public2Private(ContoCorrenteConCartaPub* ccpub){
  
  
  ContoCorrenteConCartaPrivate* ccpriv = NULL;	// puntatore da ritornare
  
  // controllo se il puntatore è valido, e in caso punti realmente
  // alla struttura pubblica lo converto (operazione di casting)
  // nella struttura privata
  if( ccpub != NULL ){
    printf("\n\t[CCX Public2Private] conversione della struttura da pub a private\n");
    ccpriv = (ContoCorrenteConCartaPrivate*) ccpub;
  }

  return ccpriv;
}



static ContoCorrenteConCartaPub* Private2Public(ContoCorrenteConCartaPrivate* ccpriv){
  
  
  ContoCorrenteConCartaPub* ccpub = NULL;	
  
  if( ccpriv != NULL ){
    printf("\n\t[CCX Private2Public] conversione della struttura da private a pub\n");
    ccpub = (ContoCorrenteConCartaPub*) ccpriv;
  }

  return ccpub;
}





/*
 * Implementazione di default del metodo getter per il numero di carta
 * di credito.
 */
static char* getNumeroCartaDiCredito( ContoCorrenteConCartaPub *ccpub ){
  if( ccpub == NULL )
    return NULL;

  ContoCorrenteConCartaPrivate *ccpriv = Public2Private( ccpub );
  return ccpriv->numero_carta;
}




/**
 * Costruttore di copia da un conto corrente normale 
 */
ContoCorrenteConCartaPub* abilitaCarta( ContoCorrentePub* contoNormale, char* numero_carta ){

  // controlli di sicurezza
  if( contoNormale == NULL || numero_carta == NULL )
    return NULL;


  printf("\n\t[abilitaCarta] Abilitazione carta %s su conto %s",
	 numero_carta,
	 contoNormale->m_titolare( contoNormale ) );

  // costruisco un nuovo conto corrente esteso
  ContoCorrenteConCartaPrivate *ccpriv = malloc( sizeof( ContoCorrenteConCartaPrivate ) );

  
  
  // inserisco il conto normale nella struttura pubblica
  ContoCorrentePub* superClass = aperturaContoCorrente( contoNormale->m_numero_conto( contoNormale ), 
						     contoNormale->m_titolare( contoNormale )
						    );
  ccpriv->pub.contoCorrente = superClass;

  // Metodo getter per la carta di credito
  ccpriv->pub.m_numero_carta = getNumeroCartaDiCredito;

  // inserisco il numero di carta nella struttura privata
  ccpriv->numero_carta = numero_carta;

  // oggetto costruito!
  return Private2Public( ccpriv );
  

}

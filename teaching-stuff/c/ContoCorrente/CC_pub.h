/* CC_pub.h */

#ifndef __CC_INCLUDE_GUARD__
#define __CC_INCLUDE_GUARD__ "CC_pub.h"



// author: Luca Ferrari fluca1978 at gmail.com 




/* 
 * Questo file header definisce la struttura pubblica del ContoCorrente.
 * Si noti che la struttura contiene solo puntatori a funzione, ove ogni
 * funzione rappresenta una singola operazione che può essere effettuata
 * su un ContoCorrente. L'idea di base di questa implementazione è quella
 * di fornire visione della struttura pubblica all'esterno del modulo di 
 * implementazione, nascondendo i dati legati al conto (che in ContoCorrentePub
 * non compaiono nemmeno) e recuperandoli "al volo" quando necessario.
 * Si noti anche che l'operazione di apertura non è legata al conto corrente
 * (non compare nella struttura ContoCorrentePub), poiché è un'operazione
 * che deve essere effettuata prima di assumere possesso del conto corrente,
 * ossia prima di avere un puntatore valido a ContoCorrentePub. Una volta che
 * si ha acquisito un ContoCorrentePub, non ha più senso operare su tale conto
 * un'operazione di apertura. 
 */


typedef struct CCPUB{
  // puntatore alla funzione getSaldo
  int (*saldo)(struct CCPUB*);    
  
  // puntatore alla funzione StampaContoCorrente
  void (*m_stampa)(struct CCPUB*);
  
  // puntatore alla funzione versamento
  int (*m_versamento)(struct CCPUB*, int);
  
  // puntatore alla funzione prelievo
  int (*m_prelievo)(struct CCPUB*, int);
  
  // puntatore alla funzione stampaMovimenti
  void (*m_stampa_movimenti)(struct CCPUB*);
  
  // metodo per ottenere il titolare del conto
  char* (*m_titolare)( struct CCPUB* );

  // metodo per ottenere il numero del conto
  int (*m_numero_conto)( struct CCPUB* );

} ContoCorrentePub;



/* servizi pubblici disponibili per questo modulo */
ContoCorrentePub* aperturaContoCorrente( int numero_conto, char* titolare );



#endif

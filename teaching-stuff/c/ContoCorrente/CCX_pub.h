// CCX_pub.h

#include "CC_pub.h"
#ifndef __CCX_INCLUDE_GUARD__
#define __CCX_INCLUDE_GUARD__ "CCX_pub.h"

/* 
 * File header per una possibile estensione al conto corrente.
 * Viene aggiunto un nuovo metodo che consente
 * di ottenere il numero di una carta di credito legata al conto corrente.
 */

typedef struct CCX_PUB {

  // riferimento ad un conto corrente normale
  ContoCorrentePub* super;

  // metodo che ritorna il numero della carta di credito
  char* (*m_numero_carta)( struct CCX_PUB * );

  // overriding del metodo titolare di ContoCorrentePub
  char* (*m_titolare)( struct CCX_PUB * );

} ContoCorrenteConCartaPub;


/*
 * Questo metodo rappresenta una sorta di costruttore di copia:
 * dato un conto corrente normale lo trasforma in uno con
 * carta di credito abilitata.
 */
ContoCorrenteConCartaPub* abilitaCarta( ContoCorrentePub* contoNormale, char* numero_carta );



#endif

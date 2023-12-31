#ifndef _LINSUBS_
#define _LINSUBS_

#include  <stdio.h>
#include <string.h>
#include <unistd.h>
#include <math.h>

void bal(double *a, double *b, int n) ;

/* linear algebra */
void mulmat(double *a, double *b, double *c, int a1, int a2, int a3) ;
int solvit (double *prod, double *rhs,int n, double *ans);
void pdinv(double *cinv, double *coeff, int n) ;

/* numer recipes p 97 */
int choldc (double *a, int n, double p[]);
void cholsl (double *a, int n, double p[], double b[], double x[]);
void cholesky(double *cf, double *a, int n) ;
void pmat(double *mat, int n)   ;

#endif

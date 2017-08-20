/*

  HIST.C	fast histogramming code

  [C, B] = HIST (DATA, BINS).

  Calculate histogram.  C is the counts in each bin.  B is the centers
  of each bin.

  DATA is treated as a single array

  BINS is a vector of bin boundaries (NOTE: this is different to the
  mathworks HIST which takes bin centers)  If BINS is a scalar it is 
  taken to be a bin count.

  If BINS is specified as a count, or as a regularly spaced vector, a
  rapid binning algorithm is used that depends on this and is linear
  in ndata.  If BINS is irregularly spaced the algorithm used takes
  time proportional to ndata*nbins.

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mex.h"

/* Arguments */

#define absv(x)    ((x) > 0) ? (x) : (-1 * x)
#define	DATA_IN	   prhs[0]
#define	BINS_IN	   prhs[1]
#define	C_OUT	   plhs[0]
#define	B_OUT	   plhs[1]

/* Auxilliary prototypes */
static void findext (double *, int, double *, double *);


/******************************************************************************
  WORKHORSE FUNCTIONS
  */

/*
 * regular bin size histogramming routine (faster)
 */

static void reghist(double	 data[], 
		    int		 ndata, 
		    double	 min, 
		    double	 size, 
		    int		 nbins,
		    double	 cnts[],
		    double	 ctrs[])
{
  int i, bin;
  double max = min + size * nbins;

  for (i = 0; i < nbins; i++) {
    cnts[i] = 0;
    ctrs[i] = min + i*size + size/2;
  }
 
  for (i = 0; i < ndata; i++) {
    if (data[i] < min || data[i] > max)
      continue;
    bin = (int)((data[i] - min)/size);
    if (bin < nbins)
      cnts[bin] ++;
  }
}


static void binhist(double	 data[], 
		    int		 ndata, 
		    double	 bins[],
		    int		 nbins,
		    double	 cnts[],
		    double	 ctrs[])
{
  int i, j;

  for (i = 0; i < nbins; i++) {
    cnts[i] = 0;
    ctrs[i] = (bins[i] + bins[i+1])/2;
  }

  for (i = 0; i < ndata; i++)
    for (j = 0; j < nbins; j++)
      if (data[i] >= bins[j] && data[i] < bins[j+1]) 
			cnts[j] ++;
}


/******************************************************************************
  INTERFACE FUNCTION
  */

void mexFunction(int		nlhs,
		 mxArray	*plhs[],
		 int		nrhs,
		 const mxArray	*prhs[])
{
  double	*data = NULL, *bins = NULL;
  double	*cnts = NULL, *ctrs = NULL;
  int		ndata, nbins;
  double	min, max, size = -1;
  double	*t,*y;
  unsigned int	i,m,n;

  /* Check numbers of arguments */
  if (nrhs == 0) {
    mexErrMsgTxt("HIST: no data to histogram");
  } else if (nrhs > 2) {
    mexErrMsgTxt("HIST: too many arguments.");
  }
  if (nlhs < 2) {
    mexErrMsgTxt("HIST: must be called with two output arguments");
  }

  /* Get data */
  m = mxGetM(DATA_IN);
  n = mxGetN(DATA_IN);
  ndata = m*n;
  if (!mxIsNumeric(DATA_IN) || mxIsComplex(DATA_IN) || 
      !!mxIsSparse(DATA_IN)  || !mxIsDouble(DATA_IN)) {
    mexErrMsgTxt("HIST: data must be a full real valued matrix.");
  }

  data = mxGetPr(DATA_IN);


  /* Get bin specification */
  m = mxGetM(BINS_IN);
  n = mxGetN(BINS_IN);

  if (!mxIsNumeric(BINS_IN) || mxIsComplex(BINS_IN) ||
      !!mxIsSparse(BINS_IN) || !mxIsDouble(BINS_IN) ||
      (m != 1 && n != 1)) {
    mexErrMsgTxt("HIST: bins spec must be a real scalar or vector");
  }
    
  if (m == 1 && n == 1) {	/* number of bins */
    nbins = (int)*(double *)mxGetPr(BINS_IN);
    findext (data, ndata, &min, &max);
	min = min - .0000001;
	max = max + .0000001;
    size = (max-min)/nbins;
  } else {			/* vector of bin boundaries */
    nbins = n*m - 1;
    bins  = mxGetPr (BINS_IN);

    /* check to see if spacing is regular -- if so use fast algorithm */
    size = bins[1] - bins[0];
    for (i = 1; i < nbins; i++)
      if (fabs(bins[i+1] - bins[i] - size) > 1e-9*size) {
	size = 0;
	break;
      }
    if (size) {
      min = bins[0];
    }
  }

  /* Create output matrices */
  C_OUT = mxCreateDoubleMatrix(1, nbins, mxREAL);
  cnts = mxGetPr(C_OUT);

  B_OUT = mxCreateDoubleMatrix(1, nbins, mxREAL);
  ctrs = mxGetPr(B_OUT);
  

  /* Do the actual computations in a subroutine */

  if (size) {
    reghist(data, ndata, min, size, nbins, cnts, ctrs);
  } else {
    binhist(data, ndata, bins, nbins, cnts, ctrs);
  }

  return;
}


/******************************************************************************
  AUXILLIARY FUNCTIONS
  */


static void findext(double	 data[], 
		    int		 ndata, 
		    double	*min, 
		    double      *max)
{
  int i;

  *min = *max = data[0];
  for (i = 1; i < ndata; i++) {
    if (data[i] < *min) *min = data[i];
    if (data[i] > *max) *max = data[i];
  }
}
#include "mex.h"
#include <string.h>
#include <math.h>
#include <vector>
#include <stdint.h>
/*
 * Usage:
 *   e = CC_energy_mex(w, l);
 *
 * compute correlation clustering energy (CC)
 * e = sum_ij -w_ij [li==lj]
 *
 * where [.] = 1 if arg is true
 *
 * W is sparse NxN real matrix 
 * l is double Nx1 vector of labels 
 *
 *
 * compile using:
 * >> mex -O -largeArrayDims CC_energy_mex.cpp -output CCEnergy
 */

#line   __LINE__  "CC_energy_mex"

#define     STR(s)      #s  
#define     ERR_CODE(a,b)   a ":" "line_" STR(b)


// INPUTS
enum {
    WIN = 0,
    LIN,
    NIN 
};

// OUTPUTS
enum {
    LOUT = 0,
    NOUT
};
template<typename T>
void
cc_energy(int nout, mxArray* pout[], int nin, const mxArray* pin[]);        


void
mexFunction(
    int nout,
    mxArray* pout[],
    int nin,
    const mxArray* pin[])
{
    if ( nin != NIN )
         mexErrMsgIdAndTxt(ERR_CODE(__FILE__, __LINE__),"must have %d inputs", NIN);
    if (nout==0)
        return;
    if (nout != NOUT )
         mexErrMsgIdAndTxt(ERR_CODE(__FILE__, __LINE__),"must have exactly %d output", NOUT);
    
    if ( mxIsComplex(pin[WIN]) || !mxIsSparse(pin[WIN]) )
        mexErrMsgIdAndTxt(ERR_CODE(__FILE__, __LINE__),"W must be real sparse matrix");
    
    if ( mxIsComplex(pin[LIN]) || mxIsSparse(pin[LIN]) )
        mexErrMsgIdAndTxt(ERR_CODE(__FILE__, __LINE__),"l must be real full vector");
    
  
    if ( mxGetN(pin[WIN]) != mxGetM(pin[WIN]) || mxGetN(pin[WIN]) != mxGetNumberOfElements(pin[LIN]) || 
            mxGetNumberOfDimensions(pin[WIN])!=2 )
        mexErrMsgIdAndTxt(ERR_CODE(__FILE__, __LINE__),"matrix - vector dimensions mismatch");

    switch (mxGetClassID(pin[LIN])) {
        case mxDOUBLE_CLASS:            
            return cc_energy<double>(nout, pout, nin, pin);
        case mxINT8_CLASS:
        case mxCHAR_CLASS:
            return cc_energy<char>(nout, pout, nin, pin);
        case mxSINGLE_CLASS:
            return cc_energy<float>(nout, pout, nin, pin);
        case mxUINT8_CLASS:
            return cc_energy<unsigned char>(nout, pout, nin, pin);
        case mxINT16_CLASS:
            return cc_energy<short>(nout, pout, nin, pin);
        case mxUINT16_CLASS:
            return cc_energy<unsigned short>(nout, pout, nin, pin);
        case mxINT32_CLASS:
            return cc_energy<int>(nout, pout, nin, pin);
        case mxUINT32_CLASS:
            return cc_energy<unsigned int>(nout, pout, nin, pin);
        case mxINT64_CLASS:
            return cc_energy<int64_t>(nout, pout, nin, pin);
        case mxUINT64_CLASS:
            return cc_energy<uint64_t>(nout, pout, nin, pin);
        default:
            mexErrMsgIdAndTxt(ERR_CODE(__FILE__, __LINE__),
                    "Unknown/unsupported class %s",mxGetClassName(pin[LIN]));
    } 



}

template< typename T >
void 
cc_energy(
    int nout,
    mxArray* pout[],
    int nin,
    const mxArray* pin[])
{
    mwSize N = mxGetN(pin[WIN]); // n and m are equal - W is square
    
    
   
    // label vector
    T* pl = (T*)mxGetData(pin[LIN]);
   
   
    
    /* computation starts */
    double*  pr = mxGetPr(pin[WIN]);
    mwIndex* pir = mxGetIr(pin[WIN]);
    mwIndex* pjc = mxGetJc(pin[WIN]);
 
    double energy(0);
    
    for (mwSize col=0; col< N; col++)  {           
            
        
        // perform sparse multiplication
        for (mwIndex ri = pjc[col] ; // starting row index
        ri < pjc[col+1]  ; // stopping row index
        ri++)  {
            if ( col != pir[ri] ) {
                // only off-diagonal elements are participating
                energy -= pr[ri]*( pl[col] == pl[ pir[ri] ] );
            }
            // pir[ri] -> current row
            // col -> current col
            // pr[ri] -> W[pir[ri], col]
            
        }
        
    }

    // allocate output
    pout[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    double* pe = mxGetPr(pout[0]);
    pe[0] = energy;    
}

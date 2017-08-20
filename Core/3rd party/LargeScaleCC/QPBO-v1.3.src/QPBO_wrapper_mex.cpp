#include "mex.h"
#include "QPBO.h"

#include "time.h"
/*
 * A wrapper for QPBO library by Vladimir Kolmogorov.
 *
 * Usage: 
 *   [x] = QPBO_wrapper_mex(UTerm, PTerm, ig, method... );
 *
 * Inputs:
 *  UTerm - 2xN matrix of unary terms (N-number of variables)
 *          Each term (col) is a pair [Ei(0), Ei(1)].'
 *  PTerm - 6xE matrix of pairwise terms (E-number of pair-wise relations (edges))
 *          Each term (col) is of the form [i j Eij(0,0), Eij(0,1), Eij(1,0), Eij(1,1)].'
 *          Where i,j are the indices of the variables (first variable is of index 1, last one is N)
 *  ig    - initial guess (for "improve" method)
 *  method - What type of method to use for optimization (QPBO/Probe/QPBOI)
 *
 *
 *
 *
 *
 * compiling using:
 * >> mex -O -largeArrayDims QPBO.cpp QPBO_extra.cpp QPBO_maxflow.cpp QPBO_wrapper_mex.cpp QPBO_postprocessing.cpp -output QPBO_wrapper_mex
 */


// inputs
enum {
    iU = 0,
    iP = 1,
    iG = 2,
    iM = 3,
    nI
};

// outputs
enum {
    oX = 0,
    nO
};

void my_err_function(char* msg) {
    mexErrMsgTxt(msg);
}


template <typename T, typename REAL>
void QPBO_wrapper(int nout, mxArray* pout[], int nin, const mxArray* pin[]);


void
mexFunction(
    int nout,
    mxArray* pout[],
    int nin,
    const mxArray* pin[])
{
    if (nin != nI)
        mexErrMsgIdAndTxt("QPBO_wrapper_mex:nin","Expecting %d inputs", nI);
    
    if (nout == 0)
        return;
    if (nout != nO)
         mexErrMsgIdAndTxt("QPBO_wrapper_mex:nout", "Expecting %d outputs", nO);
    
    if ( mxIsComplex(pin[iU]) || mxIsSparse(pin[iU]) )
        mexErrMsgIdAndTxt("QPBO_wrapper_mex:unary_term","Unary term must be full real matrix");
    if ( mxIsComplex(pin[iP]) || mxIsSparse(pin[iP]) )
        mexErrMsgIdAndTxt("QPBO_wrapper_mex:pairwise_term","Pair-wise term must be full real matrix");
    if ( mxIsComplex(pin[iG]) || mxIsSparse(pin[iG]) )
        mexErrMsgIdAndTxt("QPBO_wrapper_mex:initial_guess","Initial guess term must be full real matrix");
    
    if ( mxGetClassID(pin[iP]) != mxGetClassID(pin[iU]) )
        mexErrMsgIdAndTxt("QPBO_wrapper_mex:energy_terms","Both energy terms must be of the same class");
    if ( mxGetClassID(pin[iG]) != mxINT32_CLASS )
        mexErrMsgIdAndTxt("QPBO_wrapper_mex:initial_guess","Initial guess must be of type int32");
        
    if ( mxGetNumberOfDimensions(pin[iU]) != 2 || mxGetM(pin[iU]) != 2 )
        mexErrMsgIdAndTxt("QPBO_wrapper_mex:unary_term_size","Unary term must be Nx2 matrix");
    if ( mxGetNumberOfDimensions(pin[iP]) != 2 || mxGetM(pin[iP]) != 6 )
        mexErrMsgIdAndTxt("QPBO_wrapper_mex:piarwise_term_size","Unary term must be Ex6 matrix");
    
    if (mxGetNumberOfElements(pin[iM])!=1 || mxGetClassID(pin[iM])!=mxCHAR_CLASS)
        mexErrMsgIdAndTxt("QPBO_wrapper_mex:method","Method must be a char q/p/i");
    
    switch (mxGetClassID(pin[iU])) {
        case mxINT8_CLASS:
        case mxCHAR_CLASS:
            return QPBO_wrapper<char, int>(nout, pout, nin, pin);
        case mxDOUBLE_CLASS:
            return QPBO_wrapper<double, double>(nout, pout, nin, pin);
        case mxSINGLE_CLASS:
            return QPBO_wrapper<float, float>(nout, pout, nin, pin);
        case mxUINT8_CLASS:
            return QPBO_wrapper<unsigned char, int>(nout, pout, nin, pin);
        case mxINT16_CLASS:
            return QPBO_wrapper<short, int>(nout, pout, nin, pin);
        case mxUINT16_CLASS:
            return QPBO_wrapper<unsigned short, int>(nout, pout, nin, pin);
        case mxINT32_CLASS:
            return QPBO_wrapper<int, int>(nout, pout, nin, pin);
        case mxUINT32_CLASS:
            return QPBO_wrapper<unsigned int, int>(nout, pout, nin, pin);
        case mxINT64_CLASS:
        case mxUINT64_CLASS:
        default:
            mexErrMsgIdAndTxt("QPBO_wrapper_mex:energy_class","Unknown class %s",mxGetClassName(pin[iU]));
    } 
    return;
}

template <typename T, typename REAL>
void QPBO_wrapper(int nout, mxArray* pout[], int nin, const mxArray* pin[])
{
    typedef typename QPBO<REAL>::NodeId NodeId;
    typedef typename QPBO<REAL>::EdgeId EdgeId;
    typedef typename QPBO<REAL>::ProbeOptions ProbeOptions;
        
    mwSize N = mxGetN(pin[iU]); // number of nodes/variables
    mwSize E = mxGetN(pin[iP]); // number of edges/pairs
    
    T* pU = (T*)mxGetData(pin[iU]);
    T* pP = (T*)mxGetData(pin[iP]);
    
    char method = *(char*)mxGetData(pin[iM]);
    if (method != 'q' && method != 'p' && method != 'i')
        mexErrMsgIdAndTxt("QPBO_wrapper_mex:unknown_method","Unknown method %c, should be one of q/p/i",method);
    
    int enE = E;
    if (method == 'p')
        enE*=2; // for probe it is recommanded to use twice the number of edges
    
    QPBO<REAL>* qpbo = new QPBO<REAL>(N, enE, my_err_function); // construct with an error message function

    qpbo->AddNode(N);
   
    EdgeId* pEdges = new EdgeId[E];
    
    // add unary terms
    for ( mwSize ii=0; ii < N ; ii++ ) {
        if ( pU[2*ii]==0 && pU[2*ii+1]==0 )
            continue; // ignore dummy potentials
        qpbo->AddUnaryTerm(ii, pU[2*ii], pU[2*ii+1]);
    }
    // add pairwise terms
    for ( mwSize ii=0; ii < E ; ii++ ) {
        pEdges[ii] = qpbo->AddPairwiseTerm( (NodeId)pP[6*ii] - 1, (NodeId)pP[6*ii+1] - 1,
            (REAL)pP[6*ii+2], (REAL)pP[6*ii+3], (REAL)pP[6*ii+4], (REAL)pP[6*ii+5]);
    }
    // in case where duplicate edges where insderted
    qpbo->MergeParallelEdges();
    
    // allocate output
    pout[oX] = mxCreateNumericMatrix(N,1,mxINT32_CLASS, mxREAL);
    int* pX = (int*)mxGetData(pout[oX]);
    
    int* pMap;
    ProbeOptions po;
    
    switch (method) {
        case 'q': // basic method
            qpbo->Solve();
            qpbo->ComputeWeakPersistencies();

            // get the labels
            for ( mwSize ii=0; ii < N ; ii++ ) {
                pX[ii] = qpbo->GetLabel(ii);
            }
            
            break;
        case 'p': // probe method to improve standard QPBO

            //mexPrintf("Probe\n");
            
            qpbo->Solve();
            qpbo->ComputeWeakPersistencies();

            pMap = new int[N];
            
            po.directed_constraints = 1; // 1: all possible directed constraints are added, if there is sufficient space for edges (as specified by edge_num_max; see SetEdgeNumMax() function)
            po.weak_persistencies = 1; // 1: use weak persistency in the main loop (but not for probing operations)
            po.order_seed = 1; // otherwise: random permutation with random seed 'order_seed' is used.
            
            //mexPrintf("Probing...\n");
            qpbo->Probe(pMap, po);
            //mexPrintf("Weak percistencies\n");
            qpbo->ComputeWeakPersistencies();
            
            //mexPrintf("Get labels\n");
            for (mwSize ii=0; ii < N ; ii++ ) {
                pX[ii] = qpbo->GetLabel(pMap[ii]/2) + pMap[ii]%2;
            }
            //mexPrintf("clean\n");
            delete[] pMap;
            break;
        case 'i': // improved method
            if (mxGetNumberOfElements(pin[iG]) == N) {
                int* piG = (int*)mxGetData(pin[iG]);
                for (int ni(0); ni < N ; ni++)
                    qpbo->SetLabel(ni, piG[ni]);
            } else {
                delete[] pEdges;
                delete qpbo;                
                mexErrMsgIdAndTxt("QPBO_wrapper_mex:initial_guess","initial guess provided to improve is of wrong size");
            }
            srand( time(NULL) );
            qpbo->Improve();

            // get the labels
            for ( mwSize ii=0; ii < N ; ii++ ) {
                pX[ii] = qpbo->GetLabel(ii);
            }            
            break;
        default:
            mexErrMsgIdAndTxt("QPBO_wrapper_mex:unknown_method","Unknown method %c, should be one of q/p/i",method);
    }

    
    // clean up things
    delete[] pEdges;
    delete qpbo;
}


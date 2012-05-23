#ifndef __MINC2_IOX_H__
#define __MINC2_IOX_H__

// get the minc2 lib function declarations
extern "C" {
#include <minc2.h>
}

// get the Rcpp stuff
#include <Rcpp.h>

   
// maximum number of frames permitted in a volume
#define MAX_FRAMES 100
// maximum buffer size for attributes
#define MAX_STRING_LEN   256
// R return list size (number of list elements)
#define R_RTN_LIST_LEN 15
// debug switch
#define R_DEBUG_rmincIO 0


// function prototypes
RcppExport SEXP read_hyperslab(SEXP filename_,  SEXP start_,  SEXP count_, SEXP nDimensions_);
RcppExport SEXP read_voxel_from_files(SEXP filenames_, SEXP voxCoords_, SEXP noFiles_, SEXP noFrames_);
RcppExport SEXP convert_voxel_to_world(SEXP filename_, SEXP voxCoords_);
RcppExport SEXP convert_world_to_voxel(SEXP filename_, SEXP worldCoords_);
RcppExport SEXP get_volume_dimnames(SEXP filename_);

#endif

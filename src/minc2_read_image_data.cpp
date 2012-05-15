#include "minc2_IOX.h"



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 * Purpose: Read part of a minc volume.
 *          
 *          
 *          
 * Returns: A vector of real voxel values, which will then need to 
 *          be formatted
*/
SEXP read_hyperslab(SEXP filename_,  SEXP start_,  SEXP count_, SEXP nDimensions_) {

   mihandle_t     minc_volume;
   int            result;
   unsigned long  hSlab_start[MI2_MAX_VAR_DIMS];
   unsigned long  hSlab_count[MI2_MAX_VAR_DIMS];
   const char    *dimorder3d[] = { "zspace","yspace","xspace" };
   const char    *dimorder4d[] = { "time", "zspace","yspace","xspace" };

   // start ...
   if ( R_DEBUG_rmincIO ) Rprintf("read_hyperslab: start ...\n");


   // load/convert the input args
   std::string filename = Rcpp::as<std::string>(filename_);
   Rcpp::IntegerVector start(start_);
   Rcpp::IntegerVector count(count_);
   int nDimensions = Rcpp::as<int>(nDimensions_);
 


   // init the hSlab start and count vectors
   int hSlab_num_entries = 1;
   for (int ndx=0; ndx < nDimensions; ++ndx) {
      hSlab_start[ndx] = (unsigned long) start[ndx];
      hSlab_count[ndx] = (unsigned long) count[ndx];
      hSlab_num_entries = hSlab_num_entries * hSlab_count[ndx];
   }
   if ( R_DEBUG_rmincIO ) 
      Rprintf("DEBUG: read_hyperslab: hSlab_start = %d %d %d\n", hSlab_start[0], hSlab_start[1], hSlab_start[2]);


   // open the input volume
   result = miopen_volume(filename.c_str(), MI2_OPEN_READ, &minc_volume);
   if (result != MI_NOERROR) {
      Rf_error("Error opening input file: %s.\n", filename.c_str());
   }

   
   /* set the apparent order to something conventional */
   if ( R_DEBUG_rmincIO ) 
      Rprintf("read_hyperslab: Setting the apparent order for %d dimensions ... \n", nDimensions);
   //
   if ( nDimensions == 3 ) {
      result = miset_apparent_dimension_order_by_name(minc_volume, 3, const_cast<char **>(dimorder3d));
   //
   } else if ( nDimensions == 4 ) {
      result = miset_apparent_dimension_order_by_name(minc_volume, 4, const_cast<char **>(dimorder4d));
   //
   } else {
      Rf_error("Error file %s has %d dimensions and we can only deal with 3 or 4.\n", filename.c_str(), nDimensions);
   }
   if ( result != MI_NOERROR )
      Rf_error("Error returned from miset_apparent_dimension_order_by_name while setting apparent order for %d dimensions.\n", nDimensions); 

   
   
   // this is for fun and Debug confirmation
   misize_t hSlab_size;
   result = miget_hyperslab_size(MI_TYPE_DOUBLE, nDimensions, hSlab_count, &hSlab_size);
   if ( R_DEBUG_rmincIO ) Rprintf("DEBUG: read_hyperslab: hSlab_size in bytes = %d\n", hSlab_size);

   
   // allocate the read buffer
   if ( R_DEBUG_rmincIO ) 
      Rprintf("DEBUG: read_hyperslab: Attempting buffer allocation: %d entries [%d bytes]\n", 
         hSlab_num_entries, 
         hSlab_num_entries * sizeof (double));
   // declare and then allocate
   std::vector<double> hSlab_read_buffer;
   try {
      hSlab_read_buffer.resize(hSlab_num_entries);
      //throw std::bad_alloc();        # test allocation error
   }
   catch (std::bad_alloc &e) {
      // allocation error; return an empty vector
      Rprintf("Exception caught in minc2_readVolume.cpp: %s\n", e.what());
      Rprintf("Error allocating read buffer: %d %d-byte entries\n", 
         hSlab_num_entries, 
         sizeof (double));
      Rcpp::NumericVector error_vector(0);
      return(error_vector);
   }

   
   // read into buffer
   result = miget_real_value_hyperslab(minc_volume, MI_TYPE_DOUBLE,
                                          hSlab_start,
                                          hSlab_count,
                                          &hSlab_read_buffer[0]);
   if ( result != MI_NOERROR )
      Rf_error("Error in miget_real_value_hyperslab: %s.\n", filename.c_str());

   
   // clean-up and then return vector
   if ( R_DEBUG_rmincIO ) Rprintf("read_hyperslab: returning ...\n");
   R_CheckStack();
   return(Rcpp::wrap(hSlab_read_buffer));
}









/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 * Purpose: Given a set of 3-D coordinates in x,y,z order, traverse
 *          through all frames of all specified files, and return a  
 *          matrix containing all of the real values at the given voxel
 *          coordinate.
 *
 *          The dimensions of the returned matrix is:
 *               (number_of_files * number_of_frames) 
 *
 *          Note that passing a single 3-D volume will return a 1x1 matrix.
*/
SEXP read_voxel_from_files(SEXP filenames_,  SEXP voxCoords_,  SEXP noFiles_,  SEXP noFrames_) {
   mihandle_t     minc_volume;
   int            n_dimensions;
   int            output_ndx;
   unsigned long  hSlab_start[MI2_MAX_VAR_DIMS];
   unsigned long  hSlab_count[MI2_MAX_VAR_DIMS];
   const char *dimorder3d[] = { "zspace","yspace","xspace" };
   const char *dimorder4d[] = { "time", "zspace","yspace","xspace" };
   

   // start ...
   if ( R_DEBUG_rmincIO ) Rprintf("read_voxel_from_files: start ...\n");

   // load/convert the input args
   std::vector<std::string> filenames = Rcpp::as<std::vector<std::string> >(filenames_);
   Rcpp::IntegerVector voxCoords(voxCoords_);
   int no_files = Rcpp::as<int>(noFiles_);
   int no_frames = Rcpp::as<int>(noFrames_);

   
   /*set the xyz coords of the sampled point
   ... hSlab_start[0] will hold the frame index */
   hSlab_start[0] = 0;
   hSlab_start[1] = (unsigned long) voxCoords[0];
   hSlab_start[2] = (unsigned long) voxCoords[1];
   hSlab_start[3] = (unsigned long) voxCoords[2];

	// allocate receiving matrix 


   // allocate the AGGREGATE read buffer (3-D volumes always only return 1 column)
   int no_rows = no_files;
   int no_cols = (no_frames == 0) ? 1 : no_frames;
   int outBuf_num_entries = no_rows * no_cols;
   if ( R_DEBUG_rmincIO ) 
      Rprintf("DEBUG: read_voxel_from_files: Attempting buffer allocation: %d entries [%d bytes]\n", 
         outBuf_num_entries, 
         outBuf_num_entries * sizeof (double));
   // declare and then allocate
   std::vector<double> outBuf_read_buffer;
   try {
      outBuf_read_buffer.resize(outBuf_num_entries);
      //throw std::bad_alloc();        # test allocation error
   }
   catch (std::bad_alloc &e) {
      // allocation error; return an empty vector
      Rprintf("Exception caught in read_voxel_from_files: %s\n", e.what());
      Rprintf("Error allocating aggregate output read buffer: %d %d-byte entries\n", 
         outBuf_num_entries, 
         sizeof (double));
      // return an empty vector
      Rcpp::NumericVector error_vector(0);
      return(error_vector);
   }



   // allocate the HYPERSLAB read buffer
   int hSlab_num_entries = no_cols;
   if ( R_DEBUG_rmincIO ) 
      Rprintf("DEBUG: read_voxel_from_files: Attempting buffer allocation: %d entries [%d bytes]\n", 
         hSlab_num_entries, 
         hSlab_num_entries * sizeof (double));
   // declare and then allocate
   std::vector<double> hSlab_read_buffer;
   try {
      hSlab_read_buffer.resize(hSlab_num_entries);
      //throw std::bad_alloc();        # test allocation error
   }
   catch (std::bad_alloc &e) {
      // allocation error; return an empty vector
      Rprintf("Exception caught in read_voxel_from_files: %s\n", e.what());
      Rprintf("Error allocating read buffer: %d %d-byte entries\n", 
         hSlab_num_entries, 
         sizeof (double));
      // return an empty vector
      Rcpp::NumericVector error_vector(0);
      return(error_vector);
   }




   // loop over all volumes and extract a single value for each frame in the volume
   int result;
   for( int i=0; i < no_files; ++i ) {
      //
      if ( R_DEBUG_rmincIO ) Rprintf("Debug: read_voxel_from_files: Processing file %s ... \n", filenames[i].c_str());

      /* open the volume */
      result = miopen_volume(filenames[i].c_str(), MI2_OPEN_READ, &minc_volume);
      //
      if (result != MI_NOERROR)
         Rf_error("Error opening input file: %s.\n", filenames[i].c_str());
      


      // set the apparent order to something conventional
      // ... first need to get the number of dimensions
      if ( R_DEBUG_rmincIO ) Rprintf("Debug: read_voxel_from_files: Setting the apparent order ... ");
      if ( miget_volume_dimension_count(minc_volume, MI_DIMCLASS_ANY, MI_DIMATTR_ALL, &n_dimensions) != MI_NOERROR )
         Rf_error("\nError returned from miget_volume_dimension_count.\n");
         
      if ( R_DEBUG_rmincIO ) Rprintf("%d dimensions detected ... \n", n_dimensions);

      /* ... now set the order */
      if ( n_dimensions == 3 ) {
         result = miset_apparent_dimension_order_by_name(minc_volume, 3, const_cast<char **>(dimorder3d));
      //
      } else if ( n_dimensions == 4 ) {
         result = miset_apparent_dimension_order_by_name(minc_volume, 4, const_cast<char **>(dimorder4d));
      //
      } else {
         Rf_error("Error file %s has %d dimensions and we can only deal with 3 or 4.\n", filenames[i].c_str(), n_dimensions);
      }
      if ( result != MI_NOERROR )
         Rf_error("Error returned from miset_apparent_dimension_order_by_name while setting apparent order for %d dimensions.\n", n_dimensions); 



      // read the hyperslab
      if ( no_frames > 0 ) {

         // read a hyperslab across all frames (i.e. over time)
         hSlab_count[0] = no_frames;
         hSlab_count[1] = hSlab_count[2] = hSlab_count[3] = 1;
         if ( R_DEBUG_rmincIO ) Rprintf("hSlab_count [0..3] = %d, %d, %d, %d\n", 
                     hSlab_count[0], hSlab_count[1], hSlab_count[2], hSlab_count[3]);
      
         result = miget_real_value_hyperslab(minc_volume, MI_TYPE_DOUBLE, 
                                             hSlab_start,
                                             hSlab_count,
                                             &hSlab_read_buffer[0]);
         if ( result != MI_NOERROR )
            Rf_error("Error in miget_real_value_hyperslab: %s.\n", filenames[i].c_str());
         
         // move values from hyper-slab buffer to output buffer
         // ... we're doing this because R expects data in column-major order, 
         // ... and we're writing the frame values as rows
         for ( int ndx=0; ndx < no_frames; ++ndx) {
            output_ndx = (no_files * ndx) +i;
            outBuf_read_buffer[output_ndx] = hSlab_read_buffer[ndx];
         }
         
      } else {
         // no frames (i.e. a 3-d volume)
         if ( R_DEBUG_rmincIO ) {
            Rprintf("Debug: About to read value in 3-D volume\n");
            Rprintf("hSlab_start[1]: %lu\n", hSlab_start[1]);
            Rprintf("hSlab_start[2]: %lu\n", hSlab_start[2]);
            Rprintf("hSlab_start[3]: %lu\n", hSlab_start[3]);
         }
         result = miget_real_value(minc_volume, &hSlab_start[1], 3, &hSlab_read_buffer[0]);
         if ( result != MI_NOERROR ) {
            Rf_error("Error in miget_real_value.  File: %s.\n", filenames[i].c_str());
         }
         outBuf_read_buffer[i] = hSlab_read_buffer[0];

      }

      // done with this volume, so close it
      miclose_volume(minc_volume);
   }

   // clean-up and then return vector
   if ( R_DEBUG_rmincIO ) Rprintf("read_voxel_from_files: returning ...\n");
   R_CheckStack();
   return(Rcpp::wrap(outBuf_read_buffer));
}







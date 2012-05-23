#include "minc2_IOX.h"


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 *  Purpose:
 *
 *    Convert voxel coordinates to a vector of world coords
 *
 * NOTE: 
 *    (1) It is assumed that we are receiving 0-relative voxel coordinates
 *    (2) input voxel coordinates:
 *          (a) are in volume order
 *          (b) do *not* include a value for the 4th dimension
 *          (c) if there IS a 4th dim, it is ASSUMMED to be the
 *                FIRST (most slowly varying) in the volume, and
 *                is SET TO ZERO
 *    (3) returned world coordinates are in xyz order
 *
 * * * * * * * * * * * * * 
 */
SEXP convert_voxel_to_world(SEXP filename_, SEXP voxCoords_) {

   
   int         result;
   int         n_dimensions;
   mihandle_t  minc_volume;
   const char  *dimorder3d[] = { "zspace","yspace","xspace" };
   const char  *dimorder4d[] = { "time", "zspace","yspace","xspace" };

   // start ...
   if ( R_DEBUG_rmincIO ) Rprintf("Debug: convert_voxel_to_world: start ...\n");

   
   // load/convert the input args
   std::string filename = Rcpp::as<std::string>(filename_);
   Rcpp::NumericMatrix voxCoords(voxCoords_);
   int n_coordinates = voxCoords.nrow();

   
   // open the input volume
   result = miopen_volume(filename.c_str(), MI2_OPEN_READ, &minc_volume);
   if (result != MI_NOERROR) {
      Rf_error("Error opening input file: %s.\n", filename.c_str());
   }

   // set the apparent order to something conventional
   // ... first need to get the number of dimensions
   if ( miget_volume_dimension_count(minc_volume, MI_DIMCLASS_ANY, MI_DIMATTR_ALL, &n_dimensions) != MI_NOERROR )
      Rf_error("\nError returned from miget_volume_dimension_count.\n");
   if ( R_DEBUG_rmincIO ) Rprintf("%d dimensions detected ... \n", n_dimensions);

   // ... now set the order
   if ( R_DEBUG_rmincIO ) Rprintf("Debug: convert_voxel_to_world: Setting the apparent order ... \n");
   if ( n_dimensions == 3 ) {
      result = miset_apparent_dimension_order_by_name(minc_volume, 3, const_cast<char **>(dimorder3d));
   //
   } else if ( n_dimensions == 4 ) {
      result = miset_apparent_dimension_order_by_name(minc_volume, 4, const_cast<char **>(dimorder4d));
   //
   } else {
      Rf_error("Error file %s has %d dimensions and we can only deal with 3 or 4.\n", filename.c_str(), n_dimensions);
   }
   if ( result != MI_NOERROR )
      Rf_error("Error returned from miset_apparent_dimension_order_by_name while setting apparent order for %d dimensions.\n", n_dimensions); 



   // declare and then allocate the *input* voxel coordinates buffer
   // ... make it +1 in case the volume has a 4th dimension
   int offset = ( n_dimensions == MI2_3D ) ? 0 : 1;
   int voxel_coords_buffer_size = n_dimensions +offset;
   std::vector<double> voxel_coords_buffer(voxel_coords_buffer_size);
   // ... init a pointer for use with minc call
   const double* voxel_coords_buffer_ptr = &voxel_coords_buffer.front();

   
   // declare and then allocate the *output* world coordinates buffer
   std::vector<double> world_coords_buffer(MI2_3D);
   double* world_coords_buffer_ptr = &world_coords_buffer.front();

   
   // declare aggregate receiving matrix and current entry vector 
   Rcpp::NumericMatrix output_matrix(n_coordinates, MI2_3D);
   Rcpp::NumericVector current_entry(MI2_3D);
   
   // loop over all passed coordinate entries
   for ( int entry=0; entry < n_coordinates; entry++ ) {
   
      // move coords into buffer, allowing for 4th dim (if existing)
      current_entry = voxCoords(entry, Rcpp::_);
      for ( int ndx=0; ndx < MI2_3D; ++ndx ) {
         voxel_coords_buffer[ndx +offset] = current_entry[ndx];
      }

      // zero output buffer
      for ( int ndx=0; ndx < 3; ++ndx ) {
         world_coords_buffer[ndx] = 0;
      }
   
      // do the call
      miconvert_voxel_to_world(minc_volume, voxel_coords_buffer_ptr, world_coords_buffer_ptr);

      // move resulting x,y,z coords to the aggregate matrix
      output_matrix(entry, 0) = world_coords_buffer[0];
      output_matrix(entry, 1) = world_coords_buffer[1];
      output_matrix(entry, 2) = world_coords_buffer[2];
   }
   
   
   // done with volume, so close it
   miclose_volume(minc_volume);

   // clean-up and then return vector
   if ( R_DEBUG_rmincIO ) Rprintf("Debug: convert_voxel_to_world: returning ...\n");
   R_CheckStack();
   return(output_matrix);
}



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 *  Purpose:
 *
 *    Convert world coordinates to a vector of voxel coords
 *
 * NOTE: 
 *    (1) It is assumed that we are receiving world coordinates 
 *    (2) input world coordinates are in xyz order
 *    (3) output voxel coordinates are in volume order
 *    (4) 3 coords are returned for 3D volumes; 4 coords for 4D volumes
 *
 * * * * * * * * * * * * * 
 */
SEXP convert_world_to_voxel(SEXP filename_, SEXP worldCoords_) {

   
   int         result;
   int         n_dimensions;
   mihandle_t  minc_volume;
   const char  *dimorder3d[] = { "zspace","yspace","xspace" };
   const char  *dimorder4d[] = { "time", "zspace","yspace","xspace" };

   // start ...
   if ( R_DEBUG_rmincIO ) Rprintf("Debug: convert_world_to_voxel: start ...\n");

   
   // load/convert the input args
   std::string filename = Rcpp::as<std::string>(filename_);
   Rcpp::NumericMatrix worldCoords(worldCoords_);
   int n_coordinates = worldCoords.nrow();

   
   // open the input volume
   result = miopen_volume(filename.c_str(), MI2_OPEN_READ, &minc_volume);
   if (result != MI_NOERROR) {
      Rf_error("Error opening input file: %s.\n", filename.c_str());
   }

   // set the apparent order to something conventional
   // ... first need to get the number of dimensions
   if ( miget_volume_dimension_count(minc_volume, MI_DIMCLASS_ANY, MI_DIMATTR_ALL, &n_dimensions) != MI_NOERROR )
      Rf_error("\nError returned from miget_volume_dimension_count.\n");
   if ( R_DEBUG_rmincIO ) Rprintf("%d dimensions detected ... \n", n_dimensions);

   // ... now set the order
   if ( R_DEBUG_rmincIO ) Rprintf("Debug: convert_world_to_voxel: Setting the apparent order ... \n");
   if ( n_dimensions == 3 ) {
      result = miset_apparent_dimension_order_by_name(minc_volume, 3, const_cast<char **>(dimorder3d));
   //
   } else if ( n_dimensions == 4 ) {
      result = miset_apparent_dimension_order_by_name(minc_volume, 4, const_cast<char **>(dimorder4d));
   //
   } else {
      Rf_error("Error file %s has %d dimensions and we can only deal with 3 or 4.\n", filename.c_str(), n_dimensions);
   }
   if ( result != MI_NOERROR )
      Rf_error("Error returned from miset_apparent_dimension_order_by_name while setting apparent order for %d dimensions.\n", n_dimensions); 



   // declare and then allocate the *input* world coordinates buffer
   std::vector<double> world_coords_buffer(MI2_3D);
   // ... init a pointer for use with minc call
   const double* world_coords_buffer_ptr = &world_coords_buffer.front();

   
   // declare and then allocate the *output* voxel coordinates buffer
   std::vector<double> voxel_coords_buffer(n_dimensions);
   double* voxel_coords_buffer_ptr = &voxel_coords_buffer.front();

   
   // declare aggregate receiving matrix and current entry vector 
   Rcpp::NumericMatrix output_matrix(n_coordinates, n_dimensions);
   Rcpp::NumericVector current_entry(MI2_3D);
   
   // loop over all passed coordinate entries
   for ( int entry=0; entry < n_coordinates; entry++ ) {
   
      // move coords into buffer
      current_entry = worldCoords(entry, Rcpp::_);
      for ( int ndx=0; ndx < MI2_3D; ++ndx ) {
         world_coords_buffer[ndx] = current_entry[ndx];
      }

      // zero output buffer
      for ( int ndx=0; ndx < n_dimensions; ++ndx ) {
         voxel_coords_buffer[ndx] = 0;
      }
   
      // do the call
      miconvert_world_to_voxel(minc_volume, world_coords_buffer_ptr, voxel_coords_buffer_ptr);

      // move resulting voxel coords to the aggregate matrix
      output_matrix(entry, 0) = voxel_coords_buffer[0];
      output_matrix(entry, 1) = voxel_coords_buffer[1];
      output_matrix(entry, 2) = voxel_coords_buffer[2];
      if ( n_dimensions == 4 ) {
         output_matrix(entry, 3) = voxel_coords_buffer[3];
      }
   }
   
   
   // done with volume, so close it
   miclose_volume(minc_volume);

   // clean-up and then return vector
   if ( R_DEBUG_rmincIO ) Rprintf("Debug: convert_world_to_voxel: returning ...\n");
   R_CheckStack();
   return(output_matrix);
}





/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 *  Purpose:
 *
 *    Get a given volume's dimension names, in volume order
 *
 * NOTE: Nuttin really.
 *
 * * * * * * * * * * * * * 
 */
SEXP get_volume_dimnames(SEXP filename_) {

   
   int            result;
   int            n_dimensions;
   mihandle_t     minc_volume;
   midimhandle_t  *dimensions;
   char           *dim_name;

   // start ...
   if ( R_DEBUG_rmincIO ) Rprintf("Debug: get_volume_dimnames: start ...\n");

   
   // load/convert the input args
   std::string filename = Rcpp::as<std::string>(filename_);

   
   // open the input volume
   result = miopen_volume(filename.c_str(), MI2_OPEN_READ, &minc_volume);
   if (result != MI_NOERROR) {
      Rf_error("Error opening input file: %s.\n", filename.c_str());
   }

   // get the number of dimensions
   if ( miget_volume_dimension_count(minc_volume, MI_DIMCLASS_ANY, MI_DIMATTR_ALL, &n_dimensions) != MI_NOERROR )
      Rf_error("\nError returned from miget_volume_dimension_count.\n");
   if ( R_DEBUG_rmincIO ) Rprintf("%d dimensions detected ... \n", n_dimensions);


   // load up the midimension struct for all dimensions
   // ... check "result" against MI_ERROR, as "result" will contain nDimensions if OK
   dimensions = (midimhandle_t *) malloc( sizeof( midimhandle_t ) * n_dimensions );
   result = miget_volume_dimensions(minc_volume, MI_DIMCLASS_ANY, MI_DIMATTR_ALL, MI_DIMORDER_FILE, n_dimensions, dimensions);
   if ( result == MI_ERROR ) { 
      Rf_error("Error code (%d) returned from miget_volume_dimensions.\n", result);
   }

   
   
   // Loop over the dimensions to grab the remaining info
   if ( R_DEBUG_rmincIO ) Rprintf("Debug: get_volume_dimnames: Loop over dimension entries ...\n");
   std::vector<std::string> dim_names_vector;
   for( int ndx=0; ndx < n_dimensions; ++ndx ){
      /*
      get (and print) the dimension names for all dimensions*
   .. remember that since miget_dimension_name calls strdup which, in turn,
   ...calls malloc to get memory for the new string -- we need to call "mifree" on
   ...our pointer to release that memory.  
      */
      result = miget_dimension_name(dimensions[ndx], &dim_name);
      
      
      // store the dimension name and units
      //dim_names_vector.insert(dim_names_vector.end(), dim_name, dim_name+strlen(dim_name));
      dim_names_vector.push_back(std::string(dim_name));
      if ( R_DEBUG_rmincIO ) {std::cout << dim_names_vector.back() << std::endl;}
      mifree_name(dim_name);
      
   }
   
   // done with volume, so close it
   miclose_volume(minc_volume);

   // clean-up and then return vector
   if ( R_DEBUG_rmincIO ) Rprintf("Debug: get_volume_dimnames: returning ...\n");
   R_CheckStack();
   return(Rcpp::wrap(dim_names_vector));
}







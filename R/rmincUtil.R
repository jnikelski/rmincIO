
# test to see whether files exist and are readable
rmincUtil.isReadable <- function(filenames) {
  rValue <- TRUE
  READ_PERMISSION <- 4
  if (sum(file.access(as.character(filenames), READ_PERMISSION)) != 0
      || is.null(filenames)) {

	# ummm, something is not readable, let's say who
    rValue <- FALSE
	for ( ndx in 1:length(filenames) ) {
		if ( file.access(filenames[ndx], READ_PERMISSION) != 0 ) {
			warning(sprintf("File: %s is not accessible.\n", filenames[ndx]))
		}
	}
  }
  return(rValue)
}


# test to see whether a given file is minc (minc1 or minc2)
rmincUtil.isMinc <- function(filename) {
	rValue <- FALSE
	if ( !file.exists(filename) ) { return(rValue) }
	if ( rmincUtil.isMinc1(filename) ) rValue <- TRUE
	if ( rmincUtil.isMinc2(filename) ) rValue <- TRUE
	#
	return(rValue)
}


# test to see whether a given file is minc1
rmincUtil.isMinc1 <- function(filename) {
	rValue <- FALSE
	sysCmd <- paste("file", filename)
#	print(sysCmd)
	rtnString <- system(sysCmd, intern=TRUE)
#	print(rtnString)
	if ( grepl("NetCDF", rtnString, fixed=TRUE) ) rValue <- TRUE
	return(rValue)
}


# test to see whether a given file is minc2
rmincUtil.isMinc2 <- function(filename) {
	rValue <- FALSE
	sysCmd <- paste("file", filename)
#	print(sysCmd)
	rtnString <- system(sysCmd, intern=TRUE)
#	print(rtnString)
	if ( grepl("Hierarchical Data Format", rtnString, fixed=TRUE) ) rValue <- TRUE
	return(rValue)
}


# convert minc1 volume to minc2
rmincUtil.asMinc2 <- function(filename, keepName=TRUE) {
	
	# is it already minc2? Just return the input filename.
	if ( rmincUtil.isMinc2(filename) ) return(filename)
	
	# if it isn't minc1, tell 'em and run away
	if ( !rmincUtil.isMinc(filename) ) {
		stop(paste("Error: Trying to convert a non-minc file (", filename, ") to minc", sep=""))
	}
	
	# fine. So we now have a minc1 volume that we want to convert to minc2
	#
	# first, get a temporary filename
	cmdOptions <- ""
	if ( keepName ) {
		# we want to use the input filename, but put the file in tmpdir
		# ... allow for overwrite of file in tmpdir
		cmdOptions <- "-clobber"
		tmpFile <- basename(filename)
		tmpFile <- file.path(tempdir(), tmpFile)
		}
	else {
		tmpFile <- tempfile( pattern="R_mincIO_mincconvert_")
	}
	
	# do the conversion
	cat(paste(">> auto-converting", filename, "to minc2 format\n"))
	sysCmd <- paste("mincconvert", cmdOptions, "-2",  filename, tmpFile)
#	print(sysCmd)
	system(sysCmd, wait=TRUE)
	#
	return(tmpFile)
}


rmincUtil.convertVoxelToWorld <- function(filename, voxCoords) {
   # =============================================================================
   # Purpose: Convert voxel to world coordinates
   #
   # Notes: A few:
   #     (1) the C++ routines want:
   #           (a) the coordinates to be 0-relative
   #           (b) to be in volume order
   #           (c) NOT to include a value for the 4th dim (if existing)
   #     (2) input voxel coords are specified in xyz order -- this function
   #           will reorder as needed
   #     (3) the api always only returns 3 values, regardless of
   #           dimensionality of the volume
   #     (4) this function accepts a single set of coordinates (as a vector),
   #           which is converted to a matrix for processing
   #     (5) matrix format is nCoords X xyz. So, 10 coords would be passed
   #           as a 10x3 matrix
   #
   # =============================================================================
   #
   #
   
   if ( R_DEBUG_rmincIO ) cat(sprintf(">>rmincUtil.convertVoxelToWorld\n"))

   # make sure that we have a valid coord structure
   if ( !is.vector(voxCoords) && !is.matrix(voxCoords) ) {
      stop(sprintf("rmincUtil.convertVoxelToWorld requires either a vector or matrix argument"))
   }
   
   # ... and must be numeric
   if ( !is.numeric(voxCoords) ) {
      stop(sprintf("rmincUtil.convertVoxelToWorld requires the coords to be of numeric type"))
   }

   # if we were passed a matrix, validate the dimensions
   if ( is.matrix(voxCoords) ) {
      if ( ncol(voxCoords) != 3 ) {
         stop(sprintf("rmincUtil.convertVoxelToWorld: Exactly 3 coordinates must be specified"))
      }
      # copy and rename prior to changing
      voxCoords.m <- voxCoords
      dimnames(voxCoords.m) <- list(NULL, c("xspace", "yspace", "zspace"))
   }
   
   # if we were passed a vector, recast as a matrix
   if ( is.vector(voxCoords) ) {
      if ( length(voxCoords) != 3 ) {
         stop(sprintf("rmincUtil.convertVoxelToWorld: Exactly 3 coordinates must be specified"))
      }
      voxCoords.m <- matrix(voxCoords, nrow=1, byrow=TRUE, dimnames=list(NULL, c("xspace", "yspace", "zspace")))
   } 

   # map the results -- from xyz -- to volume dim order
   #
   # first, read the dimnames from the volume
   dimnamesVol.v <- rmincUtil.getVolumeDimnames(filename)

   # define offset to jump over the volume's time dim (if there is one)
   # ... assume first dim is time, if 4 dims
   ofx <- ifelse(length(dimnamesVol.v) > 3, 1, 0)

   # rebuild the voxel matrix in xyz order
   if ( R_DEBUG_rmincIO ) {
      cat(sprintf("Debug: Reordering voxel matrix ...\n"))
      cat(sprintf("Debug: offset: [%d] ...\n", ofx))
      cat(sprintf("Debug: dimnamesVol.v:\n"))
      print(dimnamesVol.v)
      print(voxCoords.m)
   }
   voxCoords.m <- matrix(c(voxCoords.m[,dimnamesVol.v[ofx+1]], 
                  voxCoords.m[,dimnamesVol.v[ofx+2]], 
                  voxCoords.m[,dimnamesVol.v[ofx+3]]), ncol=3, byrow=FALSE)

   # subtract 1 to make 0-relative
   voxCoords.m <- voxCoords.m -1


   # dunno why, but the voxel coordinates are passed as doubles
   stopifnot( is.matrix(voxCoords.m), is.double(voxCoords.m) )
   if ( R_DEBUG_rmincIO ) {
      cat(sprintf("rmincUtil.convertVoxelToWorld: calling C++. Function args:\n"))
      cat(sprintf("filename: %s\n", filename))
      cat(sprintf("voxel coordinates:\n"))
      print(voxCoords.m)
   }
   #
   output <- .Call("convert_voxel_to_world",
               as.character(filename),
               voxCoords.m, PACKAGE="rmincIO")

   
   # world coords are returned in x,y,z order. Change back to vector if vector
   # was passed as input, and add col labels
   if ( is.vector(voxCoords) ) {
      stopifnot(nrow(output) == 1)
      output <- as.vector(output[1,])
      names(output) <- c("x", "y", "z")
   }

   # if passed as matrix, add col labels
   if ( is.matrix(voxCoords) ) {
      dimnames(output) <- list(NULL, c("x", "y", "z"))
   }


   if ( R_DEBUG_rmincIO ) cat(sprintf("<<rmincUtil.convertVoxelToWorld\n"))
   return(output)
}



rmincUtil.convertWorldToVoxel <- function(filename, worldCoords) {
   # =============================================================================
   # Purpose: Convert world to voxel coordinates
   #
   # Notes: A few:
   #  (1)   input world coords are in x,y,z order
   #  (2)   the api returns 3 or 4 values, depending on
   #        dimensionality of the volume, however, this function
   #        prunes off the 4th dim -- thus it only returns 3
   #  (3)   returned coords are in volume order
   #  (4)   this function accepts a single set of coordinates (as a vector)
   #        If you need to pass many, call the "many" version of this
   #
   # =============================================================================
   #
   #
   if ( R_DEBUG_rmincIO ) cat(sprintf(">>rmincUtil.convertWorldToVoxel\n"))

   # make sure that we have a valid coord structure
   if ( !is.vector(worldCoords) && !is.matrix(worldCoords) ) {
      stop(sprintf("rmincUtil.convertWorldToVoxel requires either a vector or matrix argument"))
   }
   
   # ... and must be numeric
   if ( !is.numeric(worldCoords) ) {
      stop(sprintf("rmincUtil.convertWorldToVoxel requires the coords to be of numeric type"))
   }

   # if we were passed a matrix, validate the dimensions
   if ( is.matrix(worldCoords) ) {
      if ( ncol(worldCoords) != 3 ) {
         stop(sprintf("rmincUtil.convertWorldToVoxel: Exactly 3 coordinates must be specified"))
      }
      # copy and rename prior to changing
      worldCoords.m <- worldCoords
   }
   
   # if we were passed a vector, recast as a matrix
   if ( is.vector(worldCoords) ) {
      if ( length(worldCoords) != 3 ) {
         stop(sprintf("rmincUtil.convertWorldToVoxel: Exactly 3 coordinates must be specified"))
      }
      worldCoords.m <- matrix(worldCoords, nrow=1, byrow=TRUE)
   } 


   # make the .Call
   stopifnot( is.matrix(worldCoords.m), is.double(worldCoords.m) )
   if ( R_DEBUG_rmincIO ) {
      cat(sprintf("rmincUtil.convertWorldToVoxel: calling C++. Function args:\n"))
      cat(sprintf("filename: %s\n", filename))
      cat(sprintf("world coordinates input:\n"))
      print(worldCoords.m)
   }
   #
   output.m <- .Call("convert_world_to_voxel",
               as.character(filename),
               worldCoords.m, PACKAGE="rmincIO")

   # add 1 to make 1-relative and round (don't need fractional voxels)
   output.m <- round(output.m +1)


   # map the results -- returned in volume order -- to xyz ordered
   #
   # first, read the dimnames from the volume
   dimnames.v <- rmincUtil.getVolumeDimnames(filename)

   # get indices of interest from the dimnames vector
   x_ndx <- match("xspace", dimnames.v)
   y_ndx <- match("yspace", dimnames.v)
   z_ndx <- match("zspace", dimnames.v)

   # rebuild the voxel matrix in xyz order
   xyzVoxelCoords <- matrix(c(output.m[,x_ndx], output.m[,y_ndx],output.m[,z_ndx]), ncol=3, byrow=FALSE)

   
   # change back to vector if vector was passed as input, and add col labels
   if ( is.vector(worldCoords) ) {
      stopifnot(nrow(xyzVoxelCoords) == 1)
      xyzVoxelCoords <- as.vector(xyzVoxelCoords[1,])
      names(xyzVoxelCoords) <- c("x", "y", "z")
   }

   # if passed as matrix, add col labels
   if ( is.matrix(worldCoords) ) {
      dimnames(xyzVoxelCoords) <- list(NULL, c("x", "y", "z"))
   }


   if ( R_DEBUG_rmincIO ) cat(sprintf("<<rmincUtil.convertWorldToVoxel\n"))
   return(xyzVoxelCoords)
}




rmincUtil.getDataTypes <- function() {
	# =============================================================================
	# Purpose: return a data.frame containing the minc2 data types
	#
	# Note: Nothing of note, really.
	#
	# =============================================================================
	#

	# create a data.frame of data types (an enum in the code)
	# needed to produce human-friendly string
	dataType_numCode <- c(1,3,4,5,6,7,100,101,102,1000,1001,1002,1003,-1)
	dataType_string <- c("8-bit signed integer", "16-bit signed integer", "32-bit signed integer", "32-bit floating point",
"64-bit floating point", "ASCII string", "8-bit unsigned integer", "16-bit unsigned integer", "32-bit unsigned integer",
"16-bit signed integer complex", "32-bit signed integer complex", "32-bit floating point complex",
"64-bit floating point complex", "non_uniform record")
	dataType_code <- c("MI_TYPE_BYTE", "MI_TYPE_SHORT", "MI_TYPE_INT", "MI_TYPE_FLOAT", "MI_TYPE_DOUBLE",
"MI_TYPE_STRING", "MI_TYPE_UBYTE", "MI_TYPE_USHORT", "MI_TYPE_UINT", "MI_TYPE_SCOMPLEX",
"MI_TYPE_ICOMPLEX", "MI_TYPE_FCOMPLEX", "MI_TYPE_DCOMPLEX", "MI_TYPE_UNKNOWN")
	dataTypes.df <- data.frame(code=dataType_code, numCode=dataType_numCode, string=dataType_string, stringsAsFactors=FALSE)
	
	# return the valid data types
	return(dataTypes.df)
}



rmincUtil.getDataTypeCode <- function(dataTypeAsString) {
   # =============================================================================
   # Purpose: Given a data type as a string, return a matching enum value
   #
   # Note: Nothing of note, really.
   #
   # =============================================================================
   #

   # create some short-cuts
   dataType <- toupper(dataTypeAsString)
   if (dataType == "FLOAT") dataType <- "MI_TYPE_FLOAT"
   if (dataType == "DOUBLE") dataType <- "MI_TYPE_DOUBLE"
   if (dataType == "INTEGER") dataType <- "MI_TYPE_INT"
   if (dataType == "LONG") dataType <- "MI_TYPE_INT"
   if (dataType == "SHORT") dataType <- "MI_TYPE_SHORT"
   if (dataType == "BYTE") dataType <- "MI_TYPE_BYTE"

   dataType.df <- rmincUtil.getDataTypes()
   enumCode <- which(dataType.df$code == dataType)
   dataTypeCode <- dataType.df$numCode[enumCode]
   
   # return the valid data types
   return(dataTypeCode)
}



rmincUtil.getDataClasses <- function() {
	# =============================================================================
	# Purpose: return a data.frame containing the minc2 data classes
	#
	# Note: Nothing of note, really.
	#
	# =============================================================================
	#

	# create a data.frame of data classes (an enum in the code)
	# needed to produce human-friendly string
	dataClass_numCode <- c(0, 1, 2, 3, 4, 5)
	dataClass_string <- c("REAL", "INTEGER", "LABEL", "COMPLEX", "UNIFORM_RECORD", "NON_UNIFORM_RECORD")
	dataClasses.df <- data.frame(numCode=dataClass_numCode, string=dataClass_string, stringsAsFactors=FALSE)
	
	# return the valid data classes
	return(dataClasses.df)
}



rmincUtil.getDataClassCode <- function(dataClassAsString) {
   # =============================================================================
   # Purpose: Given a data class as a string, return a matching enum value
   #
   # Note: Nothing of note, really.
   #
   # =============================================================================
   #

   dataClass <- toupper(dataClassAsString)
   dataClass.df <- rmincUtil.getDataClasses()
   enumCode <- which(dataClass.df$string == dataClass)
   dataClassCode <- dataClass.df$numCode[enumCode]
   
   # return the valid data types
   return(dataClassCode)
}



rmincUtil.checkForExternalProgram <- function(program, test_string, prog_options="", run_it=TRUE) {
	# =============================================================================
	# Purpose: Check for the existence of an external program.
	#
	# Details:
	#	This function is passed the name of a program or script that is s'posed 
	#	to be on the user's path, along with an option that generates a known
	#	response (the test_string).  If the passed test_string is not found in
	#	the returned output, we send a warning message and then return FALSE.
	#	The user, given a FALSE, can then cobble together a fitting response to
	#	the user.
	#
	# Example:
	#	program <- "xfm2param_nonexisting"
	#	progOptions <- "-version"
	#	test_string <- "mni_autoreg"
	#	result <- rmincUtil.checkForExternalProgram(program, test_string, progOptions)
	#	if ( !result ) { ... }
	#
	# Note: 
   # The R "system" function does not capture the output when an error status is returned.
   # However, redirecting syserr/sysout permits "system" to capture the ascii_binary output
   # So, passing a final progOption of " 2>&1 " should solve this. I encountered this
   # with the ascii_binary program, which , when called with no args, 
   # returns a non-zero (error) status
	#
	# =============================================================================
	#
   if ( R_DEBUG_rmincIO ) cat(sprintf("Debug: >>rmincUtil.checkForExternalProgram\n"))
   if ( R_DEBUG_rmincIO ) cat(sprintf("Debug: rmincUtil.checkForExternalProgram: test_string = %s\n", test_string))

	# first, make sure that the program is on the user's path
   pathname <- Sys.which(program)
   if ( pathname == "" ) {
      warning(sprintf("Program [%s] not found on path", program))
      return(FALSE)
   }

   # OK, we now know that the program is on our PATH. Do we want to see whether
   # we can actually execute the program? If not, just return right now.
   if ( !run_it ) {
      if ( R_DEBUG_rmincIO ) cat(sprintf("Debug: <<rmincUtil.checkForExternalProgram\n"))
      return(TRUE)
   }

   # create string to submit to shell and then run it
	cmd <- paste(program, prog_options)
   if ( R_DEBUG_rmincIO ) cat(sprintf("Debug: rmincUtil.checkForExternalProgram: cmd = %s\n", cmd))
	cmdOut <- system(cmd, intern=TRUE, wait=TRUE)
	
	# collapse all output into a single line for easy grepping
	cmdOutLong <- paste(cmdOut, collapse="")
	#cat(sprintf("cmdOutLong = %s\n", cmdOutLong))

	# look for test string in output
	if ( !grepl(test_string, cmdOutLong, fixed=TRUE) ) {
		# test string not found??
		cat(sprintf("Attempt to execute program \"%s\" within shell failed\n", program))
		cat(sprintf("Shell responded with: \n%s\n", cmdOut))
		warning("\nCheck your path ...")
		return(FALSE)
	}
	
	# return TRUE if we made this far
   if ( R_DEBUG_rmincIO ) cat(sprintf("Debug: <<rmincUtil.checkForExternalProgram\n"))
   return(TRUE)
}



rmincUtil.readLinearXfmFile <- function(xfmFilename) {
	# =============================================================================
	# Purpose: Read the contents of a linear XFM file.
	#
	# Details:
	#	This is done by spawning the xfm2param program from the  
	#	mni_autoreg package.  As such, we need to make sure that this
	#	MNI package is installed and xfm2param is on the user's PATH.
	#
	#
	# Note: Nothing of note, really.
	#
	# =============================================================================
	#

	# check for the external program
	program <- "xfm2param"
	progOptions <- "-version"
	test_string <- "mni_autoreg"
	status <- rmincUtil.checkForExternalProgram(program, test_string, progOptions, run_it=FALSE)
	if ( !status ) { stop("Program xfm2param of package mni_autoreg cannot be found on PATH") }

	# OK, so we have xfm2pram -- now let's do the read
	# ... first have xfm2param place tabular output in a temp file
	tmpfile <- tempfile("rmincUtil.readLinearXfmFile")
	cmd <- paste("xfm2param", xfmFilename, "> ", tmpfile)
   system(cmd, intern=TRUE, wait=TRUE)
	
   # now, before we can read the xfm, we need to know whether we're dealing with a 
   # regular xfm or a "concatenated transform" (as used with nonlinear grid volumes)
   # So ... read the converted xfm and look for a specific keyword
   concatenatedXfm <- FALSE
   xfm.v <- readLines(tmpfile)
   concatenatedXfm <- any(grepl("[CONCATENATED TRANSFORM]", xfm.v, fixed=TRUE))

   # set num of lines to skip (depending on xfm type) and then
   # read the nicely formatted tabular file
   nSkip <- ifelse(concatenatedXfm, 2, 1)
	xfm.df <- read.table(tmpfile, header=FALSE, skip=nSkip, nrows=5, stringsAsFactors=FALSE)
	
	# make first column into row names
	rowNames <- xfm.df[,1]
	rowNames <- gsub("^-", "", rowNames)
	row.names(xfm.df) <- rowNames
	
	# change col names and then remove col 1
	names(xfm.df) <- c("dummy", "x", "y", "z")
	xfm.df <- subset(xfm.df,select=-dummy) 
	
	# return the xfm data.frame
	return(xfm.df)
}


rmincUtil.isMniObj <- function(filename) {
   # =============================================================================
   # Purpose: Test to see whether a given file is a polygon MNI object file.
   #
   # Details:
   #
   # Note: Nothing of note, really.
   #
   # =============================================================================
   #
   rValue <- FALSE
   if ( !file.exists(filename) ) { return(rValue) }
   if ( rmincUtil.isMniObjBinary(filename) ) rValue <- TRUE
   if ( rmincUtil.isMniObjAscii(filename) ) rValue <- TRUE
   #
   return(rValue)
}


rmincUtil.isMniObjBinary <- function(filename) {
   # =============================================================================
   # Purpose: Is this a BINARY polygon file?
   #
   # Details:
   #
   # Note: Nothing of note, really.
   #
   # =============================================================================
   #
   rValue <- FALSE

   # extract the first character and check type code
   typeCode <- readChar(filename, 1, useBytes=TRUE)
   if ( typeCode == "p" ) rValue <- TRUE

   return(rValue)
}


rmincUtil.isMniObjAscii <- function(filename) {
   # =============================================================================
   # Purpose: Is this an ASCII polygon file?
   #
   # Details:
   #
   # Note: Nothing of note, really.
   #
   # =============================================================================
   #
   rValue <- FALSE
   # extract the first character and check type code
   typeCode <- readChar(filename, 1, useBytes=TRUE)
   if ( typeCode == "P" ) rValue <- TRUE

   return(rValue)
}


rmincUtil.asMniObjAscii <- function(filename, keepName=TRUE) {
   # =============================================================================
   # Purpose: Convert MNI object: binary -> Ascii
   #
   # Details:
   #
   # Note: Ummmm, the code is good (I believe) but not very useful.  Initial testing
   #        found errors returned from "ascii_binary" due to endian issues. So,
   #        unless you are absolutely certain that the binary file's endianness matches
   #        your current system, do not use this function.
   #
   # =============================================================================
   #
   if ( R_DEBUG_rmincIO ) cat(sprintf("Debug: >>rmincUtil.asMniObjAscii\n"))
   #
   # is it already Ascii? Just return the input filename.
   if ( rmincUtil.isMniObjAscii(filename) ) return(filename)
   
   # if it isn't binary, tell 'em and run away
   cat(paste(">> auto-converting", filename, "to ASCII format ... \n"))
   if ( !rmincUtil.isMniObj(filename) ) {
      stop(paste("Trying to convert a file that is not an MNI object file (", filename, ")", sep=""))
   }

   # before we do anything, make sure that the conversion program is on the user's PATH
   # note: need to set options to " 2>&1 " because:
   # (1) ascii_binary has no "-help" options
   # (2) ascii_binary, when called with no args, returns a non-zero (error) status
   # (3) the R "system" function does not capture the output when an error status is returned
   # Sooooo .... redirecting syserr/sysout permits "system" to capture the ascii_binary output
   #
   program <- "ascii_binary"
   progOptions <- " 2>&1 "
   test_string <- "Usage:"
   status <- rmincUtil.checkForExternalProgram(program, test_string, progOptions, run_it=FALSE)
   if ( !status ) {
      stop("Program ascii_binary of package bicpl cannot be found on PATH")
   }

   # fine. So we now have a binary .obj file that we're gonna convert to Ascii
   #
   # first, get a temporary filename
   if ( keepName ) {
      # we want to use the input filename, but put the file in tmpdir
      # ... allow for overwrite of file in tmpdir
      tmpFile <- basename(filename)
      tmpFile <- file.path(tempdir(), tmpFile)
   }
   else {
      tmpFile <- tempfile( pattern="R_surfaceIO_asciiBinary_")
   }

   # do the conversion
   sysCmd <- paste("ascii_binary", filename, tmpFile, "ascii")
   if ( R_DEBUG_rmincIO ) print(sysCmd)
   status <- system(sysCmd, wait=TRUE)
   if ( status != 0 ) {
      stop("Program ascii_binary of package bicpl returned an error status.")
   }
   #
   if ( R_DEBUG_rmincIO ) cat(sprintf("Debug: <<rmincUtil.asMniObjAscii\n"))
   return(tmpFile)
}



rmincUtil.getVolumeDimnames <- function(filename) {
   # =============================================================================
   # Purpose: Get a specific volume's dimension names, in volume order
   #
   # Notes: Not really ...
   #     (1) a character vector is returned containing all dimension
   #           names (eg., c("zspace","yspace","xspace")
   #
   # =============================================================================
   #
   
   if ( R_DEBUG_rmincIO ) cat(sprintf(">>rmincUtil.getVolumeDimnames\n"))

   # make sure that we have a valid minc2 volume
   volname_fullpath <- rmincUtil.asMinc2(filename)

   dimnames.v <- .Call("get_volume_dimnames",
                     as.character(volname_fullpath), PACKAGE="rmincIO")
   
   if ( R_DEBUG_rmincIO ) cat(sprintf("<<rmincUtil.getVolumeDimnames\n"))
   return(dimnames.v)
}








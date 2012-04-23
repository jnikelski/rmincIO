#
# =============================================================================
# Purpose: SurfaceIO Class Definition
#
#
# Description:
#	The purpose of this class is to make it possible to read/write and
#	manipulate MNI surface (.obj) files.  As reading binary is a pain, and
#	fraught with all sorts of platform-specific nonsense, I've made an
#	executive decision to only process ASCII obj files.
#
#	Furthermore, in order to save myself a lot of pain for nothing,
#	I've decided to read only .obj files containing polygons (well, triangles).
#	The .obj permits the storing of a bunch of other things, but I suspect
#	that 99.9% of use is with polygons.  Prove me wrong.
#
# ToDo: Nuttin.
#
# Notes: We shall be inheriting from matrix.  The matrix shall be used to store the
#		table of vertex coordinates (x,y,z), permitting us to manipulate these
#		coordinates using normal R matrix manipulation functions.
#
# =============================================================================
#
setClass("SurfaceIO", 
		representation( fileType="character",
						surfaceProperties="numeric",
						nVertices="numeric",
						nTriangles="numeric",
						colorGranularity="numeric",
						colorRGBA="numeric",
						normalsTable="matrix",
						endIndicesVector="numeric",
						trianglesTable="matrix",
						filename="character"),
		contains="matrix"
)



# =============================================================================
# Purpose:	Methods for print()/show() generic functions
#
# Notes:	None
# =============================================================================
# 
# print object details
setMethod(
	"show", 
	signature=signature(object="SurfaceIO"),
	definition=function(object) {

		if ( R_DEBUG_rmincIO ) cat(">> SurfaceIO::show() ... \n")

		# display a little something about the volume data itself
		cat(paste("Filename: ", object@filename, "\n", sep=""))
		cat(paste("Object file type: ", object@fileType, "\n", sep=""))

		cat("Surface Properties: [")
		for ( ndx in 1:length(object@surfaceProperties) ) {
			cat(sprintf(" %3.4f", object@surfaceProperties[ndx]))
		}
		cat(" ]\n")

		cat(paste("Number of vertices: ", object@nVertices, "\n", sep=""))
		cat(paste("Number of triangles: ", object@nTriangles, "\n", sep=""))
		cat(paste("Color granularity: ", object@colorGranularity, "\n", sep=""))

		cat("Color values (RGBA): [ ")
		for ( ndx in 1:length(object@colorRGBA) ) {
			cat(sprintf(" %2.4f", object@colorRGBA[ndx]))
		}
		cat(" ]\n")

		if ( R_DEBUG_rmincIO ) cat("<< SurfaceIO::show() ... \n")
	
	}
)


# use the plot() generic to display the image
setMethod(
	"plot", 
	signature=signature(x="SurfaceIO", y="missing"),
	definition=function(x, y, ..., computeNormals=TRUE) {

		if ( R_DEBUG_rmincIO ) cat(">> SurfaceIO::plot() ... \n")

		# transpose the vertex and triangles information
		vt <- t(getDataPart(x))
		tt <- t(x@trianglesTable)

		# open the rgl device and create a mesh object
		open3d()
		myMesh <- tmesh3d(vt, tt, homogeneous=FALSE)
		
		# compute the normals?
		if ( computeNormals ) {
			myMesh <- addNormals(myMesh)
		}

		# display the object
		material3d(color=rgb(0.5,0.5,0.7), alpha=1.0, shininess=50, specular="white", smooth=TRUE)
		shade3d(myMesh)
		bg3d(color="black")
		par3d(FOV=1)					# no perspective effect
      
      if ( R_DEBUG_rmincIO ) cat("<< SurfaceIO::plot() ... \n")

	}
)




# =============================================================================
# Purpose:  Create a generic function for each "readSurface" function, and then
#           add various methods that attach to that generic
#
# Input:
#     The input will consist of one filename.
#
# Output:
#  A SurfaceIO object is returned, containing all of the goodness of the
#  input volume
# =============================================================================
# 
setGeneric( 
	name="readSurface", 
	def = function(filename) { standardGeneric("readSurface") }
) 

# read the file containing the surface
setMethod(
	"readSurface", 
	signature=signature(filename="character"),
	definition=function(filename) {

      if ( R_DEBUG_rmincIO ) cat(">> SurfaceIO::readSurface() ... \n")

		# determine whether the passed volume is a valid ascii polygon file
		if ( !rmincUtil.isMniObj(filename) ) {
			stop(sprintf("Specified filename [%s] either does not exist or is not a valid .obj file"))
		}
		# is it binary?
		if ( rmincUtil.isMniObjBinary(filename) ) {
			stop(sprintf("Specified .obj file [%s] is in binary format. Use ascii_binary to convert to ASCII."))
		}


		# read the object file into a buffer
		fileCon <- file(filename, open="rt", blocking=TRUE)
		buffer <- readLines(fileCon)
		close(fileCon)


		# Step 1: Process the first line in the file
		# ... read and spit fields by space
		currentLine <- 1
		tmp <- buffer[currentLine]
		tmp <- strsplit(tmp, " ")[[1]]

		# my sample file has got 7 fields in the first line -- this should also
		if ( length(tmp) != 7 ) {
			stop(sprintf("Input file [%s] does not have 7 fields in the first line.\n", filename))
		}

		# rename the variables to something more descriptive
		fileType <- tmp[1]
		surfaceProperties <- as.numeric(tmp[2:6])
		nVertices <- as.numeric(tmp[7])


		# Step 2: Load the vertex table
		#		... this is comprised of 3 xyz coordinates for each vertex (per line)
		#		... skip the header line

      if ( R_DEBUG_rmincIO ) cat(">> SurfaceIO::readSurface() -- Load the vertex table ... \n")
		currentLine <- currentLine +1
		lineCounter <- 0
		for ( ndx in currentLine:length(buffer) ) {
			if ( buffer[ndx] == "" ) { break() }
			lineCounter <- lineCounter +1
		}

		# the number of lines should equal the number of vertices
		if ( lineCounter != nVertices) {
			stop(sprintf("Input file [%s] is not valid. Number of vertex lines not equal number of vertices.\n", filename))
		}

		# read the data in from the file directly (it's easier this way)
		vertexTable <- matrix(scan(filename, n= nVertices*3, skip=currentLine -1, nlines=nVertices, quiet=TRUE), 
								nrow=nVertices, 
								ncol=3,
								byrow=TRUE,
								dimnames=list(NULL, c("x", "y", "z"))
								)

		# adjust the current line to point after the empty line
		currentLine <- currentLine + nVertices +1



		# Step 3: Load the normals table
		#		... this is comprised of 3 values for each vertex (per line)
      if ( R_DEBUG_rmincIO ) cat(">> SurfaceIO::readSurface() -- Load the normals table ... \n")
		lineCounter <- 0
		for ( ndx in currentLine:length(buffer) ) {
			if ( buffer[ndx] == "" ) { break() }
			lineCounter <- lineCounter +1
		}

		# the number of lines should equal the number of vertices
		if ( lineCounter != nVertices) {
			stop(sprintf("Input file [%s] is not valid. Number of normals lines not equal number of vertices.\n", filename))
		}

		# read the data in from the file directly (it's easier this way)
		normalsTable <- matrix(scan(filename, n= nVertices*3, skip=currentLine -1, nlines=nVertices, quiet=TRUE), 
								nrow=nVertices, 
								ncol=3,
								byrow=TRUE,
								dimnames=list(NULL, c("x", "y", "z"))
								)

		# adjust the current line to point after the empty line
		currentLine <- currentLine + nVertices +1




		# Step 4: Read the number of triangles
		nTriangles <- as.numeric(scan(filename, n=1, skip=currentLine -1, quiet=TRUE))
		currentLine <- currentLine +1



		# Step 5: Read the color-coding details
		#		... I am currently assuming that all elements (vertices/triangles) within
		#		...	the file have the same color attributes.
		#		... IFF this ever changes, I will have to change my code to deal with it
		tmp <- as.numeric(scan(filename, n=5, skip=currentLine -1, quiet=TRUE))
		colorGranularity <- tmp[1]
		colorRGBA <- tmp[2:5]
		if ( colorGranularity != 0 ) {
			stop(sprintf("Input file [%s] is using granular (triangle/vertex) color.  Contact Jim to correct this\n", filename))
		}
		currentLine <- currentLine +2


		# Step 6: Read the end indices
		#		... I really have no idea how to use these, so I can't compute
		#		...	how many I should expect.  So, I'll just need to loop over the
		#		... lines until I hit an empty line (the terminator)
		lineCounter <- 0
		for ( ndx in currentLine:length(buffer) ) {
			if ( buffer[ndx] == "" ) { break() }
			lineCounter <- lineCounter +1
		}

		# read the data in from the file directly (it's easier this way)
		endIndicesVector <- scan(filename, skip=currentLine -1, nlines= lineCounter, quiet=TRUE)

		# adjust the current line to point after the empty line
		currentLine <- currentLine + lineCounter +1


		# Step 7: Read the surfaces (triangles) information
		lineCounter <- 0
		for ( ndx in currentLine:length(buffer) ) {
			if ( buffer[ndx] == "" ) { break() }
			lineCounter <- lineCounter +1
		}

		# read the data in from the file directly to see exactly how many elements we have
		tmpVector <- scan(filename, skip=currentLine -1, nlines= lineCounter, quiet=TRUE)

		# since 3 vectors are needed to form one triangle, the number of elements / 3
		# should equal the number of triangles
		if ( (length(tmpVector)/3) != nTriangles) {
			stop(sprintf("Input file [%s] is not valid. Number of vertex indices does not correspond to the number of triangles.\n", filename))
		}

		# read the data in from the file (this time, into a matrix)
		trianglesTable <- matrix(scan(filename, skip=currentLine -1, nlines=lineCounter, quiet=TRUE), 
								nrow=nTriangles, 
								ncol=3,
								byrow=TRUE,
								dimnames=list(NULL, c("v1", "v2", "v3"))
								)
		# add 1 to every index to make it 1-relative, since the vertexTable is 1-relative (as is everyting in R)
		trianglesTable <- trianglesTable +1

		# adjust the current line to point after the empty line
		currentLine <- currentLine + lineCounter +1


		# create the MincVolumeIO object and set assorted fields
		mniObj <- new("SurfaceIO",
			 					vertexTable,
								fileType=fileType, 
								surfaceProperties=surfaceProperties,
								nVertices=nVertices,
								nTriangles=nTriangles,
								colorGranularity=colorGranularity,
								colorRGBA=colorRGBA,
								normalsTable=normalsTable,
								endIndicesVector=endIndicesVector,
								trianglesTable=trianglesTable,
								filename=filename)

		# return the surfaceIO object
      if ( R_DEBUG_rmincIO ) cat("<< SurfaceIO::readSurface() ... \n")

		return(mniObj)

	}
)











#
# =============================================================================
# Purpose: MincVolumeIO Class Definition
#
# Description:
#	OK, here is the conceptual overview.  Volumes are read in their entirety 
#	using read volume, placing the entire 3D volume into an array.  Slices 
#	within this array are then read from and written to this 3D array
#	using the methods defined in this class. Sound reasonable?
#
#	Also, note the semantics: "read/write" prefix indicates *file* IO,
#	whereas a "get/put" prefix suggests manipulation within *memory*.
#
# TODO: 
#
#
# Notes: 
#	A.	I experimented with the idea of inheriting from class "matrix".  Doing
#		this allows you to initialize the data part of the object simply by
#		putting the data vector/matrix/array as the 2nd element in the 
#		constructor.  Doing this creates a ".Data" slot, which permits one to
#		directly access the object's data by via the usual index "[]" operators.
#		Other important methods: (1) getDataPart() gets the ".Data" data, 
#		(2) setDataPart() replaces the ".Data" slot contents.
#
#       B.      Valid volume types and associated colormaps are:
#               (a) "anatomical" / "gray"   [default]
#               (b) "functional" / "rainbow"
#               (c) "mask" / "gray"
#               (d) "label" / "rainbow"
#
# =============================================================================
#
setClass("MincVolumeIO", 
		representation( mincInfo="MincInfo",
						volumeIntensityRange="numeric",
						frameNumber="numeric",
						volumeType="character",
						colorMap="character"),
		prototype( volumeIntensityRange=c(0,0),
					frameNumber=0,
		 			volumeType="default",
					colorMap="default"),
		contains="array"
)




# =============================================================================
# Methods to get/set a desired property value from a MincVolumeIO object
#
# =============================================================================

# METHOD: mincIO.getProperty(MincVolumeIO)
# PURPOSE: get a property from a MincVolumeIO object
setMethod(
	"mincIO.getProperty", 
	signature=signature(mincIOobj="MincVolumeIO", propertyId="character"),
	definition=function(mincIOobj, propertyId) {

		if ( R_DEBUG_rmincIO ) cat(">> MincVolumeIO::mincIO.getProperty() ... \n")

		# does the property exist in the MincVolumeIO object?
		propertyHit <- FALSE
		if ( propertyId %in% slotNames(mincIOobj) ) {
			value <- slot(mincIOobj, propertyId)
			propertyHit <- TRUE
		}

		# not found yet; does the property exist in the embedded MincInfo object?
		if ( !propertyHit ) {
			value <- mincIO.getProperty(mincIOobj@mincInfo, propertyId)
			if ( !is.null(value) ) {
				propertyHit <- TRUE
			}  
		}

		# property not found: warn and return NULL
		if ( !propertyHit ) {
			warning(sprintf("Property \"%s\" was not found in object \"%s\" [class %s]\n", 
		                              propertyId, 
		                              deparse(substitute(mincIOobj)),
		                              class(mincIOobj)))
			value <- NULL
		}

		if ( R_DEBUG_rmincIO ) cat("<< MincVolumeIO::mincIO.getProperty() ... \n")

		# return
		return(value)
	}
)


# METHOD: mincIO.setProperty(MincVolumeIO)
# PURPOSE: set a property from a MincVolumeIO object
setMethod(
	"mincIO.setProperty", 
	signature=signature(mincIOobj="MincVolumeIO", propertyId="character"),
	definition=function(mincIOobj, propertyId, value) {

		if ( R_DEBUG_rmincIO ) cat(">> MincVolumeIO::mincIO.setProperty() ... \n")


		# get the variable name for the passed MincVolumeIO object
		# ... we'll need it later to write out the updated object in place
		objName <- deparse(substitute(mincIOobj))

		# does the property exist in the MincVolumeIO object? i.e., valid slot name passed?
		propertyHit <- FALSE
		prevValue <- mincIO.getProperty(mincIOobj, propertyId)
		if ( !is.null(prevValue) ) {
				propertyHit <- TRUE
		}

		# property not found: warn and return NULL
		if ( !propertyHit ) {
			warning(sprintf("Property \"%s\" was not found in object \"%s\" [class %s]\n", 
		                              propertyId, 
		                              objName,
		                              class(mincIOobj)))
			return(invisible())
		}

		# setting new property
		#
		# define settable properties (for this class)
		valid_properties <- c("filename",
		                      "volumeIntensityRange",
		                      "frameNumber",
		                      "volumeType",
		                      "colorMap",
		                      "volumeDataClass",
		                      "volumeDataType")

		# is the passed property settable?
		if ( !propertyId %in% valid_properties ) {
			warning(sprintf("Property \"%s\" is not settable in object \"%s\" [class %s]\n", 
		                              propertyId, 
		                              objName,
		                              class(mincIOobj)))
			return(invisible())
		}

		# set the property
		if ( propertyId == "filename") mincIOobj@mincInfo@filename <- as.character(value)
		if ( propertyId == "volumeIntensityRange") mincIOobj@mincInfo@volumeIntensityRange <- as.numeric(value)
		if ( propertyId == "volumeIntensityRange") mincIOobj@volumeIntensityRange <- as.numeric(value)

		if ( propertyId == "frameNumber") mincIOobj@frameNumber <- as.numeric(value)
		if ( propertyId == "volumeType") mincIOobj@volumeType <- as.character(value)
		if ( propertyId == "colorMap") mincIOobj@colorMap <- as.character(value)

		if ( propertyId == "volumeDataClass") mincIOobj@mincInfo@volumeDataClass <- as.numeric(value)
		if ( propertyId == "volumeDataType") mincIOobj@mincInfo@volumeDataType <- as.numeric(value)

		# assign newly updated object to parent frame and then return nothing
		if ( R_DEBUG_rmincIO ) {
			cat(sprintf("MincVolumeIO::mincIO.setProperty(). Old property: %s\n", as.character(prevValue)))
			cat(sprintf("MincVolumeIO::mincIO.setProperty(). New property: %s\n", as.character(value)))
			cat(sprintf("MincVolumeIO::mincIO.setProperty(). Updating object: %s\n", as.character(objName)))
		}
		#
		assign(objName, mincIOobj, envir=parent.frame())
		if ( R_DEBUG_rmincIO ) cat("<< MincVolumeIO::mincIO.setProperty() ... \n")
		return(invisible())
	}
)




# =============================================================================
# Methods for print()/show() generic functions
#
# Notes:	(1) the name of the argument *must* match that used in the
#			print() generic function (that is, 'x' in this case)
#			(2) Note that the "print" and "show" methods can be set to 
#				produce different displays (*Cool*)
# =============================================================================
# 

# METHOD: print(MincVolumeIO)
# PURPOSE: print MincVolumeIO info
setMethod(
	"print", 
	signature=signature(x="MincVolumeIO"),
	definition=function(x, ...) {

		if ( R_DEBUG_rmincIO ) cat(">> MincVolumeIO::print() ... \n")

		# assume a MincInfo object has been passed
		if ( R_DEBUG_rmincIO ) cat("MincVolumeIO::print() >> mincIO.printMincInfo() ... \n")
		mincIO.printMincInfo(x@mincInfo)

		# print out frame info (if we got it)
		if ( x@frameNumber > 0 ) {
			cat("\n---- Frame Specific Information ----\n")
			cat(sprintf("Frame Number: %d / %d\n", x@frameNumber, x@mincInfo@nFrames))
		}

		# the following fields mostly effect display
		cat("\n---- Volume Display-Related Properties ----\n")
		cat(sprintf("volumeType: %s\n", x@volumeType))
		cat(sprintf("colorMap used for display: %s\n\n", x@colorMap))

		if ( R_DEBUG_rmincIO ) cat("<< MincVolumeIO::print() ... \n")

	}
)


# METHOD: show(MincVolumeIO)
# PURPOSE: print MincVolumeIO info by simply typing "obj" at the prompt
setMethod(
	"show", 
	signature=signature(object="MincVolumeIO"),
	definition=function(object) {

		if ( R_DEBUG_rmincIO ) cat(">> MincVolumeIO::show() ... \n")

		# assume a MincInfo object has been passed
		if ( R_DEBUG_rmincIO ) cat("MincVolumeIO::show() >> mincIO.printMincInfo() ... \n")
		mincIO.printMincInfo(object@mincInfo)

		# print out frame info (if we got it)
		if ( object@frameNumber > 0 ) {
			cat("\n---- Frame Specific Information ----\n")
			cat(sprintf("Frame Number: %d / %d\n", object@frameNumber, object@mincInfo@nFrames))
		}

		# the following fields mostly effect display
		cat("\n---- Volume Display-Related Properties ----\n")
		cat(sprintf("volumeType: %s\n", object@volumeType))
		cat(sprintf("colorMap used for display: %s\n\n", object@colorMap))

		if ( R_DEBUG_rmincIO ) cat("<< MincVolumeIO::show() ... \n")
	
	}
)


# METHOD: plot(MincVolumeIO, ANY)
# PURPOSE: display a volume summary plot
setMethod(
	"plot", 
	signature=signature(x="MincVolumeIO", y="ANY"),
	definition=function(x, y, ...) {

		if ( R_DEBUG_rmincIO ) cat(">> MincVolumeIO::plot() ... \n")


		# set some useful variables (instead of hard-coding in the function body)
		offset <- x@mincInfo@nDimensions -3
		zDim <- offset +1
		yDim <- offset +2
		xDim <- offset +3
		nSlicesDisplay <- 21
		imgLayout <- c(7,3)

		# we are not going to plot every slice in the volume (takes too long)
		# so, lets select a number of equally-spaced slices
		#
		# don't try to display more slices than in volume
		nSlicesVolume <- x@mincInfo@dimInfo$sizes[zDim]
		nSlicesDisplay <- min(nSlicesVolume, nSlicesDisplay)
		selectedSlices <- round(seq(1, nSlicesVolume, length.out=nSlicesDisplay))
		sliceIds <- paste("slice", selectedSlices)



		# sub-sample the 3D volume, selecting only the slices for plotting
		plotVol <- x[,,selectedSlices]

		# compute the aspect ratio for axial slices
		aspectRatio <- (( x@mincInfo@dimInfo$sizes[yDim] * x@mincInfo@dimInfo$steps[yDim] )  /
						( x@mincInfo@dimInfo$sizes[xDim] * x@mincInfo@dimInfo$steps[xDim] ))
		aspectRatio <- abs(aspectRatio)


		# init the colormap to use for display
		# ... first ensure that a valid colormap was specified
		clrmaps <- c("gray", "rainbow", "heat.colors", "terrain.colors", "topo.colors", "cm.colors")
		if ( !(x@colorMap %in% clrmaps) ) {
			warning(sprintf("Invalid colormap specified [%s].  Using grayscale colormap instead.\n", x@colorMap))
			colorMap <- "gray"
		} else {
			colorMap <- x@colorMap
		}

		# generate a 256 level color gradient
		if ( colorMap == "gray") {
			colorMap.v <- eval(call(colorMap,quote(0:255/255)))
		} else {
			colorMap.v <- eval(call(colorMap,quote(256)))
		}
		
		# create the image plot (using lattice for the time being)
		myLevelPlot <- levelplot(plotVol, 
								layout=imgLayout,
								col.regions=colorMap.v, 
								cuts=255, 
								as.table=TRUE, 
								labels=FALSE,
								aspect=aspectRatio,
								xlab=NULL,
								ylab=NULL,
								main=list(basename(x@mincInfo@filename), col="yellow"),
								scales=list(draw=FALSE),
								between=list(x=c(0.5), y=c(0.5)),
								strip=strip.custom(style=1, 
													bg="black", 
													factor.levels = sliceIds, 
													par.strip.text=list(col="white", cex=.8)),
								colorkey=list(labels=list(col="yellow"))
						)

		# create the histogram (also with lattice)
		myHistPlot <- histogram(x[,,],
								col="yellow",
								xlab=list("Volume Real Intensity Values", col="yellow"),
								ylab=list(col="yellow"),
								nint=50,
								scales=list(x=list(tick.number=10), col="yellow", col.line="yellow")
						)

		# use grid graphics to plot the volume slices on top and the histogram below
		#
		# plot a black background
		grid.rect(gp=gpar(fill="black"))

		# plot the slices (create viewport, then plot)
		image.vp <- viewport(x=unit(.0,"npc"), 
								y=unit(0.40,"npc"), 
								width=unit(1.0,"npc"), 
								height=unit(0.60,"npc"), 
								just=c("left", "bottom"),
								name="image.vp")
		pushViewport(image.vp)
#		grid.rect()
		print(myLevelPlot, newpage=FALSE)

		# now plot the histogram (pop up one viewport level first)
		popViewport()
		histogram.vp <- viewport(x=unit(0,"npc"), 
									y=unit(0,"npc"), 
									width=unit(1.0,"npc"), 
									height=unit(0.4,"npc"), 
									just=c("left", "bottom"),
									name="histogram.vp")
		pushViewport(histogram.vp)
#		grid.rect()
		print(myHistPlot, newpage=FALSE)

		if ( R_DEBUG_rmincIO ) cat("<< MincVolumeIO::plot() ... \n")
		
	}
)



# =====================================================================
# Volume read methods
# =====================================================================


# METHOD: mincIO.readVolume(MincInfo)
# PURPOSE: read the volume specified by the MincInfo object
setMethod(
	"mincIO.readVolume", 
	signature=signature(object="MincInfo"),
	definition=function(object, frameNo, ..., volumeType, colorMap) {

		if ( R_DEBUG_rmincIO ) cat(">> mincIO.readVolume() ... \n")

		#
		# we've been passed a MincInfo object, so we can start the read directly
		if ( R_DEBUG_rmincIO ) cat("mincIO.readVolume() >> mincIO.readVolumeX() ... \n")
		mincVolume <- mincIO.readVolumeX(object, frameNo, volumeType, colorMap)
	}
)


# METHOD: mincIO.readVolume(character, numeric)
# PURPOSE: read the volume specified by a fully qualified volume name
setMethod(
	"mincIO.readVolume", 
	signature=signature(object="character"),
	definition=function(object, frameNo, ..., volumeType, colorMap) {

		if ( R_DEBUG_rmincIO ) cat(">> mincIO.readVolume() ... \n")

		# mincId is a filename
		filename <- object
	
		# make sure that the input file is minc/minc2
		if ( !rmincUtil.isMinc(filename) ) {
			errmsg <- paste("File", filename, "does not appear to be a valid minc volume")
			stop(errmsg)
		}
		# convert if needed
		filename <- rmincUtil.asMinc2(filename)

		# get some volume info
		mincInfo <- mincIO.readMincInfo(filename)
	
		# do the read
		if ( R_DEBUG_rmincIO ) cat("mincIO.readVolume() >> mincIO.readVolumeX() ... \n")
		mincVolume <- mincIO.readVolumeX(mincInfo, frameNo, volumeType, colorMap)

		if ( R_DEBUG_rmincIO ) cat("<< mincIO.readVolume() ... \n")
		return(mincVolume)
	}
)



mincIO.readVolumeX <- function(mincInfo, frameNo, volumeType, colorMap) {
#
# =============================================================================
# Purpose: Common 3D volume read routine.
#
# Description:
#	Read a 3D volume or a single 4D frame into a 3D array and return 
#	a MincVolumeIO object.
#
# TODO: 
#    (1) I am copying the output of read_hyperslab into the
#        MincVolumeIO object.  I should consider calling
#        a C function "read_volume" which calls read_hyperslab,
#        but returns an instantiated MincVolumeIO object.
#
#
# Notes: 
#
# =============================================================================
#
	if ( R_DEBUG_rmincIO ) cat(">> mincIO.readVolumeX() ... \n")


	# If this is a 4d volume, make sure that a valid frame number has been passed
	if ( mincInfo@nDimensions == 4 ) {
		if ( !hasArg(frameNo) ) {
			stop(sprintf("Reading a 4D volume requires a valid frame number to be passed"))
		} else {
			if ( frameNo < 1 || frameNo > mincInfo@nFrames) {
				stop(sprintf("Invalid frame number [%d] passed.  Must be between [1,%d]", frameNo, mincInfo@nFrames))
			}
		}
	}


	# set start indices and counts to read an entire volume, then read
	# make some adjustments in the case of 4 dimensions (time is dim #1)
	if (  mincInfo@nDimensions == 3 )  { 
		startIndices <-  rep(0, 3)
		zyxSizes <- mincInfo@dimInfo$sizes
		readSizes <- zyxSizes
	} else {
		startIndices <- c(frameNo -1, rep(0, 3))
		tzyxSizes <- mincInfo@dimInfo$sizes
		zyxSizes <- tzyxSizes[2:4]
		readSizes <- c(1, zyxSizes)
	}
	
	# do the read
	volume <- .Call("read_hyperslab",
               as.character(mincInfo@filename),
               as.integer(startIndices),
               as.integer(readSizes),
               as.integer(mincInfo@nDimensions), PACKAGE="rmincIO")


	# make into an array
	# note that while minc expects the slowest varying dimension to be first,
	# R expects it to be last. So, we need to reverse the dim order here.
	dim(volume) <- rev(zyxSizes)

	# update volume-related fields in the MincInfo object before storing it
	mincInfo@volumeIntensityRange = c(min(volume), max(volume))

	# create the MincVolumeIO object and set assorted fields
	mincVolume <- new("MincVolumeIO",
	 					volume,
						mincInfo=mincInfo, 
						volumeIntensityRange=mincInfo@volumeIntensityRange,
						frameNumber=frameNo)


	# set the display properties
	mincIO.setProperty(mincVolume, "volumeType", volumeType)

	# if the colorMap arg has been passed, then use it, else use defaults
	if ( hasArg(colorMap) ) {
	  mincIO.setProperty(mincVolume, "colorMap", colorMap)
	} else {
	  if ( mincIO.getProperty(mincVolume, "volumeType") == "anatomical" ) mincIO.setProperty(mincVolume, "colorMap", "gray")
	  if ( mincIO.getProperty(mincVolume, "volumeType") == "mask" ) mincIO.setProperty(mincVolume, "colorMap", "gray")
	  if ( mincIO.getProperty(mincVolume, "volumeType") == "functional" ) mincIO.setProperty(mincVolume, "colorMap", "rainbow")
	  if ( mincIO.getProperty(mincVolume, "volumeType") == "label" ) mincIO.setProperty(mincVolume, "colorMap", "rainbow")
	}




	# if we are dealing with a mask or label volume, do some special things
	# ...    call round() to make the floats more integer-like, thus allowing 
	# ...    the user to use the "==" operator in comparisons
	if ( mincIO.getProperty(mincVolume, "volumeType") == "mask" || 
	    mincIO.getProperty(mincVolume, "volumeType") == "label" ) {
	    mincVolume <- round(mincVolume)
	    volMin <- min(mincVolume, na.rm=TRUE)
	    volMax <- max(mincVolume, na.rm=TRUE)
	    mincIO.setProperty(mincVolume, "volumeIntensityRange", c(volMin, volMax))
	}


	# DONE. Return the new volume array object.
	if ( R_DEBUG_rmincIO ) cat("<< readVolumeX ... \n")
	return(mincVolume)
	
}



# =====================================================================
# Volume write methods
# =====================================================================


# METHOD: mincIO.writeVolume(MincVolumeIO, character)
# PURPOSE: write the MincVolumeIO object to the specified file
setMethod(
	"mincIO.writeVolume", 
	signature=signature(object="MincVolumeIO"),
	definition=function(object, filename, clobber) {

		if ( R_DEBUG_rmincIO ) cat(">> mincIO.writeVolume() ... \n")

		# if no filename has been specified, take it from the object to be written
		if ( missing(filename) ) {
			filename <- object@mincInfo@filename
		}

		# if the file already exists AND clobber=TRUE, 
		# ... then delete the file, as we are going to replace it
		if ( file.exists(filename) ) {
			if ( clobber ) {
				file.remove(filename)
			} else {
				stop("Attempting to over-write pre-existing volume without Clobber flag set\n")
			}
		}
		
		# minc2 API does not like unexpanded paths (i.e., with "~", or "..", etc)
		# so let's ensure that it's expanded
		filename <- path.expand(filename)

		# OK, yes I know that the actual volume write could be inserted directly
		# in here, but at this stage, I'm not sure if I might overload this 
		# function more in the near future. So, let's just init and then call 
		# the function that does all of the real work.
		#
		# note that we really only care about the "side effect" here (i.e. writing
		# out the volume), so we do not need to capture a return value.

		if ( R_DEBUG_rmincIO ) cat("mincIO.writeVolume() >> mincIO.writeVolumeX() ... \n")
			mincIO.writeVolumeX(object, filename)
		if ( R_DEBUG_rmincIO ) cat("<< mincIO.writeVolume() ... \n")
		
		
	}
)




mincIO.writeVolumeX <- function(mincVolume, filename) {
#
# =============================================================================
# Purpose: Common 3D volume write routine.
#
# Description:
#	Write a 3D volume from the 3D array (i.e. the MincVolumeIO object).
#
# TODO: 
#    (1) Ummm, general efficiency issues should be explored.
#
#
#
# Notes: 
#
# =============================================================================
#
	if ( R_DEBUG_rmincIO ) cat(">> mincIO.writeVolumeX() ... \n")

   # set start indices and counts to write an entire volume, then write
	if ( R_DEBUG_rmincIO ) cat(">> mincIO.writeVolumeX() >> mincIO.write_volume() ... \n")
	callStatus <- .Call("write_volume",
               as.character(filename),
               as.integer(mincVolume@mincInfo@nDimensions),
               as.integer(mincVolume@mincInfo@dimInfo$sizes),
               as.double(mincVolume@mincInfo@dimInfo$starts),
               as.double(mincVolume@mincInfo@dimInfo$steps),
               as.integer(mincVolume@mincInfo@volumeDataType),
               as.integer(mincVolume@mincInfo@volumeDataClass),
               as.double( c( min(mincVolume), max(mincVolume) ) ),
               as.double( getDataPart(mincVolume) ), PACKAGE="rmincIO")

	# DONE. Return nothing.
	if ( R_DEBUG_rmincIO ) cat("<< mincIO.writeVolumeX() ... \n")
	return
	
}



# =====================================================================
# Methods to create a new, initialized MincVolumeIO object
#	Note:
#		This generic is heavily over-loaded, linking to 3 different methods.
#		Please remember the following S4 info:
#		(1) the args in the generic and the methods must match exactly
#		(2) the args in the signature are only used for method selection, so we
#			only need to specify those args that provide a unqiue signature,
#			however, this messes up the Rd doc, which always requires a full
#			signature ... so specify a full signature.
#		(3) the signature for "likeTemplate" and "likeFile" are both 
#			c("character", "character"), so the args names need to be specified
#			in the signature.  I have explicitly set "missing" where appropriate
#			to emphasize the differences in these signatures.
# =====================================================================

# METHOD: mincIO.makeNewVolume(character, numeric,numeric,numeric)
# PURPOSE: Create a new, empty MincVolumeIO object, by passing a filename
#          and sampling details
setMethod(
	"mincIO.makeNewVolume", 
	signature=signature(filename="character", 
						dimLengths="numeric", 
						dimSteps="numeric", 
						dimStarts="numeric",
						likeTemplate="missing",
						likeFile="missing"),
	definition=function(filename=filename, 
						dimLengths=NULL, dimSteps=NULL, dimStarts=NULL,
						likeTemplate, likeFile) {

		if ( R_DEBUG_rmincIO ) cat(">> mincIO.makeNewVolume() ... \n")


		# use the passed parameters to create a MincInfo object
		# ... use some reasonable defaults
		mincInfo <- new("MincInfo")

		# set filename
		mincInfo@filename <- filename

		# set the default data class to REAL
		dataClass.df <- rmincUtil.getDataClasses()
		enumCode <- which(dataClass.df$string == "REAL")
		mincInfo@volumeDataClass <- dataClass.df$numCode[enumCode]

		# set the default data storage type to 16-bit unsigned integer
		dataType.df <- rmincUtil.getDataTypes()
		enumCode <- which(dataType.df$code == "MI_TYPE_USHORT")
		mincInfo@volumeDataType <- dataType.df$numCode[enumCode]

		# options: "native____", "talairach_", etc
		mincInfo@spaceType <- "talairach_"

		mincInfo@nDimensions <- 3

		# set dim-related goodness
		# Note: In order to keep the user experience consistent, we are requiring 
		# dimensional information be entered in xyz order.
		# Of course, the minc conventions is to have the slowest  varying dimension to be first,
		# ... so we will have to reverse the user-specified (input) order.
		# ... That is, xyz --> zyx
		mincInfo@dimInfo <- data.frame(sizes=rev(dimLengths), 
										steps=rev(dimSteps), 
										starts=rev(dimStarts), 
										row.names=c("zspace", "yspace", "xspace"), 
										units=c("mm", "mm", "mm"), stringsAsFactors=FALSE)

		# use this mincInfo to create a new, empty volume
		mincVolume <- mincIO.makeNewVolumeX(mincInfo)

		# DONE. Return MincInfo object.
		if ( R_DEBUG_rmincIO ) cat("<< mincIO.makeNewVolume() ... \n")
		return(mincVolume)

		
	}
)


# METHOD: mincIO.makeNewVolume(character, character)
# PURPOSE: Create a new, empty MincVolumeIO object, by passing a filename
#          and a 'like' template designator
setMethod(
	"mincIO.makeNewVolume", 
	signature=signature(filename="character", 
						dimLengths="missing", 
						dimSteps="missing", 
						dimStarts="missing",
						likeTemplate="character",
						likeFile="missing"),
	definition=function(filename=filename, 
						dimLengths, dimSteps, dimStarts,
						likeTemplate="icbm152", likeFile) {


		if ( R_DEBUG_rmincIO ) cat(">> mincIO.makeNewVolume()/templates ... \n")

		# make sure that a valid template volume has been specified
		if ( likeTemplate != "icbm152" &&
		 	likeTemplate != "mni305linear" &&
		 	likeTemplate != "mni305PET" ) {
			stop(sprintf("Error: Specified template volume [%s] is not supported.\n", likeTemplate));
		}

		# Yes. Very nice.  Now create an empty MincInfo object
		mincInfo <- new("MincInfo")


		#
		# Now let's tailor the MincInfo to reflect a given known template volume
		#

		# (1) volume should look like an ICBM152-sampled volume
		if ( likeTemplate == "icbm152" ) {

			# set the MincInfo fields
			mincInfo@filename <- filename

			dataClass.df <- rmincUtil.getDataClasses()
			enumCode <- which(dataClass.df$string == "REAL")
			mincInfo@volumeDataClass <- dataClass.df$numCode[enumCode]

			dataType.df <- rmincUtil.getDataTypes()
			enumCode <- which(dataType.df$code == "MI_TYPE_SHORT")
			mincInfo@volumeDataType <- dataType.df$numCode[enumCode]

			mincInfo@spaceType <- "talairach_"
			mincInfo@nDimensions <- 3
			# dim info ordering is zyx
			mincInfo@dimInfo <- data.frame(sizes=c(181, 217, 181), 
											steps=c(1, 1, 1), 
											starts=c(-72, -126, -90), 
											row.names=c("zspace", "yspace", "xspace"), 
											units=c("mm", "mm", "mm"), stringsAsFactors=FALSE)
		}


		# (2) volume should look like the MNI 305 linear volume 
		#	(as found in the mni-models_average305-lin-1.0 package)
		if ( likeTemplate == "mni305linear" ) {

			# set the MincInfo fields
			mincInfo@filename <- filename

			dataClass.df <- rmincUtil.getDataClasses()
			enumCode <- which(dataClass.df$string == "REAL")
			mincInfo@volumeDataClass <- dataClass.df$numCode[enumCode]

			dataType.df <- rmincUtil.getDataTypes()
			enumCode <- which(dataType.df$code == "MI_TYPE_SHORT")
			mincInfo@volumeDataType <- dataType.df$numCode[enumCode]

			mincInfo@spaceType <- "talairach_"
			mincInfo@nDimensions <- 3
			# dim info ordering is zyx
			mincInfo@dimInfo <- data.frame(sizes=c(156, 220, 172), 
											steps=c(1, 1, 1), 
											starts=c(-68.25, -126.51, -86.095), 
											row.names=c("zspace", "yspace", "xspace"), 
											units=c("mm", "mm", "mm"), stringsAsFactors=FALSE)
		}


		# (3) volume should look like the MNI 305 volume used for PET
		if ( likeTemplate == "mni305PET" ) {

			# set the MincInfo fields
			mincInfo@filename <- filename

			dataClass.df <- rmincUtil.getDataClasses()
			enumCode <- which(dataClass.df$string == "REAL")
			mincInfo@volumeDataClass <- dataClass.df$numCode[enumCode]

			dataType.df <- rmincUtil.getDataTypes()
			enumCode <- which(dataType.df$code == "MI_TYPE_SHORT")
			mincInfo@volumeDataType <- dataType.df$numCode[enumCode]

			mincInfo@spaceType <- "talairach_"
			mincInfo@nDimensions <- 3
			# dim info ordering is zyx
			mincInfo@dimInfo <- data.frame(sizes=c(80, 128, 128), 
											steps=c(1.5, 1.72, 1.34), 
											starts=c(-37.5, -126.08, -85.76), 
											row.names=c("zspace", "yspace", "xspace"), 
											units=c("mm", "mm", "mm"), stringsAsFactors=FALSE)
		}


		# OK. We've now built a descriptive MincInfo object
		# new use this mincInfo to create a new, empty volume
		mincVolume <- mincIO.makeNewVolumeX(mincInfo)

		# DONE. Return MincVolumeIO object.
		if ( R_DEBUG_rmincIO ) cat("<< mincIO.makeNewVolume()/templates ... \n")
		return(mincVolume)

		
	}
)


# METHOD: mincIO.makeNewVolume(character, character)
# PURPOSE: Create a new, empty MincVolumeIO object, by passing a filename
#          and a 'like' volume name
setMethod(
	"mincIO.makeNewVolume", 
	signature=signature(filename="character", 
						dimLengths="missing", 
						dimSteps="missing", 
						dimStarts="missing",
						likeTemplate="missing",
						likeFile="character"),
	definition=function(filename=filename, 
						dimLengths, dimSteps, dimStarts,
						likeTemplate, likeFile="dummy") {


		if ( R_DEBUG_rmincIO ) cat(">> mincIO.makeNewVolume()/like_file ... \n")

		# make sure that the "like" file exists, and is minc
		if ( !rmincUtil.isMinc(likeFile) ) {
			stop(sprintf("Error: The \"like\" file [%s] either does not exist, or is not minc", likeFile));
		}
		
		# Ok, it's minc.  Make sure it's minc2
		likeFile <- rmincUtil.asMinc2(likeFile);
		

		# Great, off to the races.  
		mincInfo <- mincIO.readMincInfo(likeFile);

		# update filename and then instantiate a MincVolumeIO object
		mincInfo@filename <- filename
		mincVolume <- mincIO.makeNewVolumeX(mincInfo)

		# DONE. Return MincVolumeIO object.
		if ( R_DEBUG_rmincIO ) cat("<< mincIO.makeNewVolume()/like_file ... \n")
		return(mincVolume)

		
	}
)



mincIO.makeNewVolumeX <- function(mincInfo) {
#
# =============================================================================
# Purpose: Common 3D volume creation routine.
#
# Description:
#	Create and return a new MincVolumeIO object, given a MincInfo object. 
#
# TODO: 
#    (1) Nuttin.
#
#
# Notes: 
#
# =============================================================================
#
	if ( R_DEBUG_rmincIO ) cat(">> mincIO.makeNewVolumeX() ... \n")

	# create a pre-initialized (to zero) 3D array
	nVoxels <- cumprod(mincInfo@dimInfo$sizes)[mincInfo@nDimensions]
	volumeData <- array(rep(0, nVoxels), dim=rev(mincInfo@dimInfo$sizes))

	# create the MincVolumeIO object
	mincVolume <- new("MincVolumeIO",
						volumeData,
						mincInfo=mincInfo, 
						volumeIntensityRange=mincInfo@volumeIntensityRange)

   # set display-related properties for an anatomical volume
	mincIO.setProperty(mincVolume, "volumeType", "anatomical")
	mincIO.setProperty(mincVolume, "colorMap", "gray")


	# DONE. Return MincVolumeIO object
	if ( R_DEBUG_rmincIO ) cat("<< mincIO.makeNewVolumeX() ... \n")
	return(mincVolume)

}



# =====================================================================
# Methods for conversion to MincVolumeIO objects
# =====================================================================

# METHOD: mincIO.asVolume(array, MincVolumeIO)
# PURPOSE: convert 3D array into a MincVolumeIO object
#          by passing a template MincVolumeIO object
setMethod(
	"mincIO.asVolume", 
	signature=signature(array3D="array", 
						likeVolObject="MincVolumeIO", 
						likeTemplate="missing"),
	definition=function(array3D, likeVolObject, likeTemplate) {

		if ( R_DEBUG_rmincIO ) cat(">> mincIO.asVolume (likeVolume) ... \n")
		
		# Ok, so we're going to make the passed array into a volume
		# object that looks like the passed object
		
		# validation.  Make sure that the dimension sizes match.
		sameDim <- !all.equal(dim(likeVolObject), dim(array3D))
		if ( class(sameDim) == "character" ) {
			stop(sprintf("Array and \"like\" volume differ in dimensions. Conversion not permitted\n"))
		}

		# copy the "like" volume to get the S4 attributes
		myVolume <- likeVolObject

		# move the new array data in
		myVolume <- setDataPart(myVolume, array3D)
		
		# update volume-related fields
		volMin <- min(myVolume, na.rm=TRUE)
		volMax <- max(myVolume, na.rm=TRUE)
		mincIO.setProperty(myVolume, "volumeIntensityRange", c(volMin, volMax))


		# DONE. Return MincInfo object.
		if ( R_DEBUG_rmincIO ) cat("<< mincIO.asVolume (likeVolume) ... \n")
		return(myVolume)
		
	}
)


# METHOD: mincIO.asVolume(array, character)
# PURPOSE: convert 3D array into a MincVolumeIO object 
#          by passing a volume template type
setMethod(
	"mincIO.asVolume", 
	signature=signature(array3D="array", 
						likeVolObject="missing", 
						likeTemplate="character"),
	definition=function(array3D, likeVolObject, likeTemplate) {

		if ( R_DEBUG_rmincIO ) cat(">> mincIO.asVolume (likeTemplate) ... \n")
		
		# Ok, so we're going to make the passed array into a volume
		# object that looks like the passed template volume
		
		# create the "like" volume to get the S4 attributes
		myVolume <- mincIO.makeNewVolume(filename="created_by_asVolume_function", likeTemplate=likeTemplate)

		# move the new array data in
		myVolume <- setDataPart(myVolume, array3D)
		
		# update volume-related fields
		volMin <- min(myVolume, na.rm=TRUE)
		volMax <- max(myVolume, na.rm=TRUE)
		mincIO.setProperty(myVolume, "volumeIntensityRange", c(volMin, volMax))


		# DONE. Return MincInfo object.
		if ( R_DEBUG_rmincIO ) cat("<< mincIO.asVolume (likeTemplate) ... \n")
		return(myVolume)
		
	}
)



# =====================================================================
# MincVolumeIO arithmetic operator overloading
# =====================================================================


# METHOD: mincIO.+(MincVolumeIO, MincVolumeIO)
# PURPOSE: Add 2 MincVolumeIO objects (ADIDTION)
#
setMethod(
	"+", 
	signature=signature(e1="MincVolumeIO", 
						e2="MincVolumeIO"), 
	definition=function(e1, e2) {

		if ( R_DEBUG_rmincIO ) cat(">> mincIO.+ ovrloaded operator ... \n")
		
		# A I sees it, we should have been passed 2 MincVolumeIO object
		# ... do the math
		newVol <- getDataPart(e1) + getDataPart(e2)
		# convert to MincVolumeIO object reflecting the first object passed
		newVol <- mincIO.asVolume(newVol, e1)
		
		# update volume-related fields
		volMin <- min(newVol, na.rm=TRUE)
		volMax <- max(newVol, na.rm=TRUE)
		mincIO.setProperty(newVol, "volumeIntensityRange", c(volMin, volMax))

		# DONE. Return MincInfo object.
		if ( R_DEBUG_rmincIO ) cat("<< mincIO.+ ovrloaded operator ... \n")
		return(newVol)
		
	}
)


# METHOD: mincIO.-(MincVolumeIO, MincVolumeIO)
# PURPOSE: Subtract 2 MincVolumeIO objects (SUBTRACTION)
#
setMethod(
	"-", 
	signature=signature(e1="MincVolumeIO", 
						e2="MincVolumeIO"), 
	definition=function(e1, e2) {

		if ( R_DEBUG_rmincIO ) cat(">> mincIO.- ovrloaded operator ... \n")
		
		# A I sees it, we should have been passed 2 MincVolumeIO object
		# ... do the math
		newVol <- getDataPart(e1) - getDataPart(e2)
		# convert to MincVolumeIO object reflecting the first object passed
		newVol <- mincIO.asVolume(newVol, e1)
		
		# update volume-related fields
		volMin <- min(newVol, na.rm=TRUE)
		volMax <- max(newVol, na.rm=TRUE)
		mincIO.setProperty(newVol, "volumeIntensityRange", c(volMin, volMax))

		# DONE. Return MincInfo object.
		if ( R_DEBUG_rmincIO ) cat("<< mincIO.- ovrloaded operator ... \n")
		return(newVol)
		
	}
)

# METHOD: mincIO.*(MincVolumeIO, MincVolumeIO)
# PURPOSE: Multiply 2 MincVolumeIO objects (MULTIPLICATION)
#
setMethod(
	"*", 
	signature=signature(e1="MincVolumeIO", 
						e2="MincVolumeIO"), 
	definition=function(e1, e2) {

		if ( R_DEBUG_rmincIO ) cat(">> mincIO.* ovrloaded operator ... \n")
		
		# A I sees it, we should have been passed 2 MincVolumeIO object
		# ... do the math
		newVol <- getDataPart(e1) * getDataPart(e2)
		# convert to MincVolumeIO object reflecting the first object passed
		newVol <- mincIO.asVolume(newVol, e1)
		
		# update volume-related fields
		volMin <- min(newVol, na.rm=TRUE)
		volMax <- max(newVol, na.rm=TRUE)
		mincIO.setProperty(newVol, "volumeIntensityRange", c(volMin, volMax))

		# DONE. Return MincInfo object.
		if ( R_DEBUG_rmincIO ) cat("<< mincIO.* ovrloaded operator ... \n")
		return(newVol)
		
	}
)

# METHOD: mincIO./(MincVolumeIO, MincVolumeIO)
# PURPOSE: Divide 2 MincVolumeIO objects (DIVISION)
#
setMethod(
	"/", 
	signature=signature(e1="MincVolumeIO", 
						e2="MincVolumeIO"), 
	definition=function(e1, e2) {

		if ( R_DEBUG_rmincIO ) cat(">> mincIO./ ovrloaded operator ... \n")
		
		# A I sees it, we should have been passed 2 MincVolumeIO object
		# ... do the math
		newVol <- getDataPart(e1) / getDataPart(e2)
		# convert to MincVolumeIO object reflecting the first object passed
		newVol <- mincIO.asVolume(newVol, e1)
		
		# update volume-related fields
		volMin <- min(newVol, na.rm=TRUE)
		volMax <- max(newVol, na.rm=TRUE)
		mincIO.setProperty(newVol, "volumeIntensityRange", c(volMin, volMax))

		# DONE. Return MincInfo object.
		if ( R_DEBUG_rmincIO ) cat("<< mincIO./ ovrloaded operator ... \n")
		return(newVol)
		
	}
)





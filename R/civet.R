# ========================== Overall Purpose ==================================
#	Replicate the Civet access middle-ware that exists for Ruby.
#   Difference: Whereas the Ruby middle-ware is explicitly written to be used
#   within the Beagle processing pipeline, this code was written to be used
#   more broadly. 
#   Therefore, whereas the Ruby middle-ware passes a bunch of settings and
#   run options passed on from Beagle, this version, instead, needs to
#   pass settings/options explicitly. In addition, some settings, such as
#   the Civet root directory, needs to be passed as a mandatory arg, 
#   rather than knowing that it is automatically passed (via Beagle) in
#   settings.
#
#   At any rate, an attempt was made to try to keep the function signatures
#   as similar as possible between the Ruby/R versions.  
#
# ========================== Handy Function Signatures ==================================
#
# == Internal
#bool <- civet.accessorIsImplemented(permitted_civet_versions, civet_version)
#updated_settings$ <- civet.processArgsSettings(settings) 
#updated_opt$ <- civet.processArgsOpt(opt)
#civet.checkVersion(civet_version, opt)
#
# == Get Subject's Scan Dir Name
#rx/bool <- civet.getScanDirectoryName(civet_keyname, civet_scanid, settings, opt, fullpath=FALSE, checkExistence=FALSE)
#
# == Tissue Classification
#rx/bool <- civet.getDirnameClassify(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx/bool <- civet.getFilename <- function(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath=FALSE, checkExistence=FALSE)
#rx/bool <- civet.getFilenameClassify(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#rx/bool <- civet.getFilenameGrayMatterPve(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#rx/bool <- civet.getFilenameWhiteMatterPve(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#rx/bool <- civet.getFilenameCsfPve(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#
# == Final
#rx/bool <- civet.getDirnameFinal(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx/bool <- civet.getFilenameStxT1(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#
# == Masks (Stx Space)
#rx/bool <- civet.getDirnameMask(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx/bool <- civet.getFilenameCerebrumMask(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#rx/bool <- civet.getFilenameSkullMask(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#
# == Native
#rx/bool <- civet.getDirnameNative(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx/bool <- civet.getFilenameNative(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#rx/bool <- civet.getFilenameNativeNUC(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#rx/bool <- civet.getFilenameSkullMaskNative(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#
# == Surfaces
#rx/bool <- civet.getDirnameSurfaces(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx$lh,rh/bool,bool <- civet.getFilenameGrayMatterSurfaces(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, resampled=TRUE)
#rx$lh,rh/bool,bool <- civet.getFilenameWhiteMatterSurfaces(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, resampled=TRUE)
#rx$lh,rh/bool,bool <- civet.getFilenameMidSurfaces(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, resampled=TRUE)
#
# == Thickness
#rx/bool <- civet.getDirnameThickness(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx$lh,rh/bool,bool <- civet.getFilenameCorticalThickness(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, resampled=TRUE)
#rx$lh,rh/bool,bool <- civet.getFilenameMeanSurfaceCurvature(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, resampled=TRUE)
#
# == Transforms
#rx/bool <- civet.getDirnameTransforms(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx/bool <- civet.getDirnameTransformsLinear(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx/bool <- civet.getDirnameTransformsNonlinear(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx/bool <- civet.getFilenameLinearTransform(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
#rx$lh,rh/bool,bool <- civet.getFilenameNonlinearTransform(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, inverted=FALSE)
#
# == VBM
#rx/bool <- civet.getDirnameVbm(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx$gm,wm,csf/bool,bool,bool <- civet.getFilenameVbmBlurred(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, symmetrical=FALSE)
#
# == Assorted Civet Directories
#rx/bool <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence=TRUE)
#rx/bool <- civet.getDirnameLogs(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#rx/bool <- civet.getDirnameVerify(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE)
#
# == Non-File-Access Auxilliary Functions
# list() <- civet.readCivetDatFiles(civet_keyname, civet_scanid, settings, opt)
# list() <- civet.computeStxTissueVolumes(civet_keyname, civet_scanid, settings, opt)
# list() <- civet.computeNativeToStxRescalingFactor(civet_keyname, civet_scanid, settings, opt)
# list() <- civet.computeNativeTissueVolumes(civet_keyname, civet_scanid, settings, opt)
# =============================================================================
#
#
#
#
#
#
# =============================================================================
# Purpose: 
#	Check to see whether this accessor function is available for the specified 
#   Civet version?
#
# Example:
#   permitted_civet_versions <- c('1.1.7', '1.1.9')
#	if ( !civet.accessorIsImplemented(permitted_civet_versions, '1.1.11') ) { ... error ... }
# =============================================================================
#
civet.accessorIsImplemented <- function(permitted_civet_versions, civet_version) {
    if ( !civet_version %in% permitted_civet_versions ) {
        cat(sprintf("\n*** Error: Civet version %s does not implement this function. Your code will likely fail. Sorry :(\n", civet_version))
        cat(sprintf("*********: Your code will likely fail. Sorry :(\n\n"))
        return(FALSE)
    }
    return(TRUE)
}


# =============================================================================
# Purpose: 
#	Process the settings() input arg ... set defaults, etc.
#
# Example:
#	settings <- civet.processArgsSettings(settings)
# =============================================================================
#
civet.processArgsSettings <- function(settings) {
    # first, make sure that mandatory settings jave been set
    if ( is.null(settings$CIVET_PREFIX) ) {
        
        stop('The CIVET_PREFIX setting has not been specified. Please specify this setting before calling any rmincIO Civet accessor functions.')
    }
    if ( is.null(settings$CIVET_ROOT_DIR) ) {
        stop('The CIVET_ROOT_DIR setting has not been specified. Please specify this setting before calling any rmincIO Civet accessor functions.')
    }
    if ( is.null(settings$CIVET_VERSION) ) {
        stop('The CIVET_VERSION setting has not been specified. Please specify this setting before calling any rmincIO Civet accessor functions.')
    }

    # set defaults, if unset
    if ( is.null(settings$CIVET_SCANID_APPEND_SCANDATE_TO_KEYNAME) ) {settings$CIVET_SCANID_APPEND_SCANDATE_TO_KEYNAME <- TRUE}

    return(settings)
}


# =============================================================================
# Purpose: 
#	Process the opt() input arg ... set defaults, etc.
#
# Example:
#	opt <- civet.processArgsOpt(opt)
# =============================================================================
#
civet.processArgsOpt <- function(opt) {
    # set defaults, if unset
    if ( is.null(opt$verbose) ) {opt$verbose <- FALSE}
    if ( is.null(opt$debug) ) {opt$debug <- FALSE}
    return(opt)
}


# =============================================================================
# Purpose: 
#	Check whether the passed Civet version is one for which we have tested.
#
# Example:
#	civet.checkVersion("1.1.8", list())
# =============================================================================
#
civet.checkVersion <- function(civet_version, opt) {

    # check/update options
    opt <- civet.processArgsOpt(opt)

    if ( opt$debug) {cat(sprintf("Entering method *civet.checkVersion* ...\n"))}

    versions = c("1.1.7", "1.1.9", "1.1.11")
    if ( !civet_version %in% versions ) {
        cat(sprintf("This function has not been tested with Civet version %s. Use at your own risk.\n", civet_version))
    }

    if ( opt$debug) {cat(sprintf("Exiting method *civet.checkVersion* ...\n"))}
    return
}


# =============================================================================
# Purpose: 
#	Return the Civet scan directory name for a specified keyname and scan date
#
# Args:
#   civet_keyname:  (string) keyname
#   civet_scanid:   (string) scan identifier -- often the scan date. NOT scan subdir name (that's what this function returns)
#   settings:       (list) various settings
#                       CIVET_PREFIX is mandatory
#                       CIVET_ROOT_DIR is mandatory
#                       CIVET_SCANID_APPEND_SCANDATE_TO_KEYNAME defaults to 'TRUE'
#                       CIVET_VERSION defaults to '1.1.11'
#   opt:            (list) various optional run options (e.g., debug, verbose, etc)
#                       opt$verbose defaults to 'FALSE'
#                       opt$debug defaults to 'FALSE'
#
# Example 1:
#   civet_keyname <- "0548-F-NC"
#	civet_scanid <- ""
#	civet_root_dir <- "~/tmp/ADNI/civet/pipeOut"
#
#   settings <- list()
#   settings$CIVET_SCANID_APPEND_SCANDATE_TO_KEYNAME <- FALSE
#   settings$CIVET_ROOT_DIR <- "/data/raid01/adni1Data/pipeOut"
#   settings$CIVET_PREFIX <- "ADNI"
#
#   opt <- list()
#
#	filename <- civet.getScanDirectoryName(civet_keyname, civet_scanid, settings, opt)
#   [[returns "0548-F-NC"]]
#
# Example 2:
#   civet_keyname <- "mookie"
#	civet_scanid <- "20180315"
#
#   settings <- list()
#   settings$CIVET_SCANID_APPEND_SCANDATE_TO_KEYNAME <- TRUE
#   settings$CIVET_ROOT_DIR <- "/data/raid01/Civet/pipeOut"
#   settings$CIVET_PREFIX <- "HCLab"
#
#   opt <- list()
#   opt$verbose <- TRUE
#   opt$debug <- TRUE
#
#	filename <- civet.getScanDirectoryName(civet_keyname, civet_scanid, settings, opt)
#   [[returns "mookie-20180315"]]
#
# Note: 
#   Similar to the Ruby implementation.
# =============================================================================
#
civet.getScanDirectoryName <- function(civet_keyname, civet_scanid, settings, opt, fullpath=FALSE, checkExistence=FALSE) {
	
    # check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getScanDirectoryName* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    # allow for the naming of the Civet output directories in 2 different ways:
    # 1. just the subjects keyname [e.g. 0640-F-NC -- used in the ADNI output]
    # 2. subject keyname and scan identifier (usually scan date) [e.g. AF008-20141027]
    if ( settings$CIVET_SCANID_APPEND_SCANDATE_TO_KEYNAME == 'ON' ) {
        civetScanDirname <- paste(civet_keyname, civet_scanid, sep='-')
    } else {
        civetScanDirname <- civet_keyname
    }

    if ( fullpath ) {
        civetScanDirname <- file.path(settings$CIVET_ROOT_DIR, civetScanDirname)
    }

    # check for file existence if requested
    if ( checkExistence && fullpath ) {
        if ( !file.exists(civetScanDirname) ) {
            cat(sprintf("\n*** Error: Required directory does not exist\n"))
            cat(sprintf("*********: Fullpath of directory: [%s]\n\n", civetScanDirname))
            civetScanDirname = false
        }
    }

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getScanDirectoryName* ...\n"))}
    return(civetScanDirname)

}


# =============================================================================
# Purpose: 
#	Return the Civet scan directory name for a specified keyname and scan date
#
# Args:
#   civet_keyname:  (string) keyname
#   civet_scanid:   (string) scan identifier -- often the scan date. NOT scan subdir name (that's what this function returns)
#   civet_subdir:   (string) Civet subdir name (e.g., 'classify', 'thickness', 'mask', 'final')
#   civet_suffix:   (string) Civet file suffix name of volume of interest (e.g., '_t1_final.mnc')
#   settings:       (list) various optional settings
#   opt:            (list) various optional run options (e.g., debug, verbose, etc)
#
# Note: 
#   Similar to the Ruby implementation.
#   Mandatory args are positional, whereas optional args are placed into either settings/opt 
# =============================================================================
#
civet.getFilename <- function(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath=FALSE, checkExistence=FALSE) {
	
    # check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilename* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    # get the scan's directory name (not the fullpath, unless explicitly requested)
    civet_scan_dirname <- civet.getScanDirectoryName(civet_keyname, civet_scanid, settings, opt, fullpath=FALSE, checkExistence=FALSE)
    civet_scan_dirname_fullpath <- civet.getScanDirectoryName(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=FALSE)

    # define the Civet-generated  volume name
    civet_volname = paste(settings$CIVET_PREFIX, '_', civet_scan_dirname, civet_suffix, sep="")

    # construct a full path name
    civet_volname_fullPath = file.path(civet_scan_dirname_fullpath, civet_subdir, civet_volname)

    # check for file existence if requested
    if ( checkExistence && fullpath ) {
        if ( !file.exists(civet_volname_fullPath) ) {
            cat(sprintf("\n*** Error: Required volume does not exist\n"))
            cat(sprintf("*********: Fullpath filename: [%s]\n\n", civet_volname_fullPath))
            civet_volname_fullPath <- FALSE
        }
        msg <- if ( is.character(civet_volname_fullPath) ) "EXISTS" else "DOES NOT EXIST"
        if ( opt$debug ) {cat(sprintf("%s\n", msg))}
    }

    # if we pass the existence check, return fullpath or not (as requested)
    if ( is.character(civet_volname_fullPath) ) {
        civet_volname_rtn <- if ( fullpath ) civet_volname_fullPath else civet_volname
    } else {
      civet_volname_rtn <- FALSE
    }

    if ( opt$debug) {cat(sprintf("Returning result: %s\n", civet_volname_rtn))}
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getScanDirectoryName* ...\n"))}
    
    # we ruturn either the full filename or Boolean false if file does not exist
    return(civet_volname_rtn)
}


# =============================================================================
# Purpose: 
#	Return the fully-qualified filename of the *_classify.mnc volume
#
# Args:
#   civet_keyname:  (string) keyname
#   civet_scanid:   (string) scan identifier -- often the scan date. NOT scan subdir name (that's what this function returns)
#   settings:       (list) various optional settings
#   opt:            (list) various optional run options (e.g., debug, verbose, etc)
#
# Example:
#	filename <- civet.getFilenameClassify('mookie', '20180315', settings, opt)
#
# =============================================================================
#
civet.getFilenameClassify <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameClassify* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'classify'

    # there was a name change in the name of the classify volume, *after* 
    # Civet version 1.1.9 -- so, construct the name according to the specified version
    if ( settings$CIVET_VERSION == '1.1.9' ) {
        civet_suffix <- '_classify.mnc'
    } else {
        civet_suffix <- '_pve_classify.mnc'
    }

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameClassify* ...\n"))}
   return(rx)
}   


# =============================================================================
# Purpose: 
#	Return the fully-qualified filename of the *_pve_*.mnc volumes
#
# Example: See civet.getFilenameClassify
# Note: civet.getFilenameClassify
# =============================================================================
#
civet.getFilenameGrayMatterPve <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameGrayMatterPve* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'classify'
    civet_suffix <- '_pve_gm.mnc'

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameGrayMatterPve* ...\n"))}
   return(rx)
}   

civet.getFilenameWhiteMatterPve <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameWhiteMatterPve* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'classify'
    civet_suffix <- '_pve_wm.mnc'

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameWhiteMatterPve* ...\n"))}
   return(rx)
}   

civet.getFilenameCsfPve <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameCsfPve* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'classify'
    civet_suffix <- '_pve_csf.mnc'

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameCsfPve* ...\n"))}
   return(rx)
}   


# =============================================================================
# Purpose: 
#	Return the fully-qualified filename of the *_t1_final.mnc volumes
#
# Example: See civet.getFilenameClassify
# Note: civet.getFilenameClassify
# =============================================================================
#
civet.getFilenameStxT1 <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameStxT1* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'final'
    civet_suffix <- '_t1_final.mnc'

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameStxT1* ...\n"))}
   return(rx)
}   


# =============================================================================
# Purpose: 
#	Return the fully-qualified filename of the *_brain_mask.mnc or 
#	*_skull_mask.mnc volumes.
#
# Example: See civet.getFilenameClassify
# Note: The brain mask differentiates itself from the skull mask in that
#		the brain mask does *not* include the cerebellum.
# =============================================================================
#
civet.getFilenameCerebrumMask <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameCerebrumMask* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'mask'
    civet_suffix <- '_brain_mask.mnc'

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameCerebrumMask* ...\n"))}
   return(rx)
}   

civet.getFilenameSkullMask <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameSkullMask* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'mask'
    civet_suffix <- '_skull_mask.mnc'

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameSkullMask* ...\n"))}
   return(rx)
}   



# =============================================================================
# Purpose: 
#	Return the fully-qualified filename of assorted Native-space volumes
#
# Example: See civet.getFilenameClassify
# =============================================================================
#
civet.getFilenameNative <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameNative* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'native'
    civet_suffix <- '_t1.mnc'

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameNative* ...\n"))}
   return(rx)
}   

civet.getFilenameNativeNUC <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameNativeNUC* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'native'
    civet_suffix <- '_t1_nuc.mnc'

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameNativeNUC* ...\n"))}
   return(rx)
}   

civet.getFilenameSkullMaskNative <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
    # Note: The skull mask DOES include the cerebellum
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameSkullMaskNative* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'mask'
    civet_suffix <- '_skull_mask_native.mnc'

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameSkullMaskNative* ...\n"))}
   return(rx)
}   


# =============================================================================
# Purpose: 
#	Return the fully-qualified gray/mid/white matter surface filenames 
#	(left and right).
#
# Example: See civet.getFilenameClassify
# Note: civet.getFilenameClassify
# =============================================================================
#
civet.getFilenameGrayMatterSurfaces <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, resampled=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameGrayMatterSurfaces* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'surfaces'
    civet_suffix <- '_gray_surface'
    rsl <- ifelse(resampled, "_rsl", "")

    # get LH/RH surfaces
    civet_suffix_lh <- paste(civet_suffix, rsl, '_left', '_81920.obj', sep="")
    rxLh <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_lh, settings, opt, fullpath, checkExistence)
    #
    civet_suffix_rh <- paste(civet_suffix, rsl, '_right', '_81920.obj', sep="")
    rxRh <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_rh, settings, opt, fullpath, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameGrayMatterSurfaces* ...\n"))}
    return(list(lh=rxLh, rh=rxRh))
}   

civet.getFilenameWhiteMatterSurfaces <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, resampled=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameWhiteMatterSurfaces* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'surfaces'
    civet_suffix <- '_white_surface'
    rsl <- ifelse(resampled, "_rsl", "")

    # get LH/RH surfaces
    civet_suffix_lh <- paste(civet_suffix, rsl, '_left', '_calibrated_81920.obj', sep="")
    rxLh <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_lh, settings, opt, fullpath, checkExistence)
    #
    civet_suffix_rh <- paste(civet_suffix, rsl, '_right', '_calibrated_81920.obj', sep="")
    rxRh <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_rh, settings, opt, fullpath, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameWhiteMatterSurfaces* ...\n"))}
    return(list(lh=rxLh, rh=rxRh))
}   

civet.getFilenameMidSurfaces <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, resampled=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameMidSurfaces* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'surfaces'
    civet_suffix <- '_mid_surface'
    rsl <- ifelse(resampled, "_rsl", "")

    # get LH/RH surfaces
    civet_suffix_lh <- paste(civet_suffix, rsl, '_left', '_81920.obj', sep="")
    rxLh <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_lh, settings, opt, fullpath, checkExistence)
    #
    civet_suffix_rh <- paste(civet_suffix, rsl, '_right', '_81920.obj', sep="")
    rxRh <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_rh, settings, opt, fullpath, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameMidSurfaces* ...\n"))}
    return(list(lh=rxLh, rh=rxRh))
}   


# =============================================================================
# Purpose: 
#	Return the fully-qualified cortical thickness and mean curvature filenames 
#	(left and right).
#
# Example: See civet.getFilenameClassify
# Note: civet.getFilenameClassify
# =============================================================================
#
civet.getFilenameCorticalThickness <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, resampled=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameCorticalThickness* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'thickness'
    civet_suffix <- '_native_rms'
    rsl <- ifelse(resampled, "_rsl", "")

    # get LH/RH surfaces
    civet_suffix_lh <- paste(civet_suffix, rsl, '_tlink_20mm_left.txt', sep="")
    rxLh <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_lh, settings, opt, fullpath, checkExistence)
    #
    civet_suffix_rh <- paste(civet_suffix, rsl, '_tlink_20mm_right.txt', sep="")
    rxRh <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_rh, settings, opt, fullpath, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameCorticalThickness* ...\n"))}
    return(list(lh=rxLh, rh=rxRh))
}   

civet.getFilenameMeanSurfaceCurvature <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, resampled=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameMeanSurfaceCurvature* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    # is this accessor function available for the specified Civet version? 
    implemented_versions = c('1.1.7', '1.1.9')
    if ( !civet.accessorIsImplemented(implemented_versions, settings$CIVET_VERSION) ) {stop()}

    civet_subdir <- 'thickness'
    civet_suffix <- '_native_mc'
    rsl <- ifelse(resampled, "_rsl", "")

    # get LH/RH surfaces
    civet_suffix_lh <- paste(civet_suffix, rsl, '_20mm_left.txt', sep="")
    rxLh <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_lh, settings, opt, fullpath, checkExistence)
    #
    civet_suffix_rh <- paste(civet_suffix, rsl, '_20mm_right.txt', sep="")
    rxRh <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_rh, settings, opt, fullpath, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameMeanSurfaceCurvature* ...\n"))}
    return(list(lh=rxLh, rh=rxRh))
}   


# =============================================================================
# Purpose: 
#	Return the fully-qualified transform filenames (linear and nonlinear).
#
# Example: See civet.getFilenameClassify
# Note: The request for the nonlinear transform file, returns 2 filenames: 
#		the xfm filename and the grid volume name.
# =============================================================================
#
civet.getFilenameLinearTransform <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameLinearTransform* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'transforms/linear'
    civet_suffix <- '_t1_tal.xfm'

    rx <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix, settings, opt, fullpath, checkExistence)
    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameLinearTransform* ...\n"))}
    return(rx)
}   

civet.getFilenameNonlinearTransform <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, inverted=FALSE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameNonlinearTransform* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'transforms/nonlinear'
    civet_suffix_xfm <- ifelse( inverted , '_nlfit_invert.xfm', '_nlfit_It.xfm')
    rxXfm <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_xfm, settings, opt, fullpath, checkExistence)

    civet_suffix_grid <- ifelse( inverted , '_nlfit_invert_grid_0.mnc', '_nlfit_It_grid_0.mnc')
    rxGrid <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_grid, settings, opt, fullpath, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameNonlinearTransform* ...\n"))}
    return(list(xfm=rxXfm, grid=rxGrid))
}

# =============================================================================
# Purpose: 
#	Return the fully-qualified VBM blurred volume filenames 
#	(gm, wm, csf).
#
# Example: See civet.getFilenameClassify
# Note: civet.getFilenameClassify
# =============================================================================
#
civet.getFilenameVbmBlurred <- function(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE, symmetrical=FALSE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getFilenameVbmBlurred* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'VBM'
    civet_suffix <- '_smooth_8mm'
    sym <- ifelse(symmetrical, "_sym", "")

    # get gm/wm/csf volume names
    civet_suffix_gm <- paste(civet_suffix, '_gm', sym, '.mnc', sep="")
    rxGm <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_gm, settings, opt, fullpath, checkExistence)
    #
    civet_suffix_wm <- paste(civet_suffix, '_wm', sym, '.mnc', sep="")
    rxWm <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_wm, settings, opt, fullpath, checkExistence)
    #
    civet_suffix_csf <- paste(civet_suffix, '_csf', sym, '.mnc', sep="")
    rxCsf <- civet.getFilename(civet_keyname, civet_scanid, civet_subdir, civet_suffix_csf, settings, opt, fullpath, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getFilenameVbmBlurred* ...\n"))}
    return(list(gm=rxGm, wm=rxWm, csf=rxCsf))
}   




# =============================================================================
# Purpose: 
#	Return the fully-qualified Civet directory names
# =============================================================================
#
civet.getDirname <- function(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirname* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    # allow for the naming of the Civet output directories in 2 different ways:
    # 1. just the subjects keyname [e.g. 0640-F-NC -- used in the ADNI output]
    # 2. subject keyname and scan identifier (usually scan date) [e.g. AF008-20141027]
    if ( settings$CIVET_SCANID_APPEND_SCANDATE_TO_KEYNAME  ) {
        civetScanDirname <- paste(civet_keyname, civet_scanid, sep='-')
    } else {
        civetScanDirname <- civet_keyname
    }

    civetScanDirname <- file.path(settings$CIVET_ROOT_DIR, civetScanDirname, civet_subdir)

    # check for file existence if requested
    if ( checkExistence ) {
        if ( !file.exists(civetScanDirname) ) {
            cat(sprintf("\n*** Error: Requested Civet path does not exist\n"))
            cat(sprintf("*********: Fullpath of directory: [%s]\n\n", civetScanDirname))
            civetScanDirname = false
        }
    }

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirname* ...\n"))}
    return(civetScanDirname)
}


civet.getDirnameClassify <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameClassify* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'classify'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameClassify* ...\n"))}
    return(rx)
}

civet.getDirnameFinal <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameFinal* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'final'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameFinal* ...\n"))}
    return(rx)
}

civet.getDirnameLogs <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameLogs* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'logs'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameLogs* ...\n"))}
    return(rx)
}

civet.getDirnameMask <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameMask* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'mask'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameMask* ...\n"))}
    return(rx)
}

civet.getDirnameNative <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameNative* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'native'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameNative* ...\n"))}
    return(rx)
}

civet.getDirnameSurfaces <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameSurfaces* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'surfaces'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameSurfaces* ...\n"))}
    return(rx)
}

civet.getDirnameThickness <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameThickness* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'thickness'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameThickness* ...\n"))}
    return(rx)
}

civet.getDirnameTransforms <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameTransforms* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'transforms'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameTransforms* ...\n"))}
    return(rx)
}

civet.getDirnameTransformsLinear <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameTransformsLinear* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'transforms/linear'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameTransformsLinear* ...\n"))}
    return(rx)
}

civet.getDirnameTransformsNonlinear <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameTransformsNonlinear* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'transforms/nonlinear'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameTransformsNonlinear* ...\n"))}
    return(rx)
}

civet.getDirnameVbm <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameVbm* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'VBM'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameVbm* ...\n"))}
    return(rx)
}

civet.getDirnameVerify <- function(civet_keyname, civet_scanid, settings, opt, checkExistence=TRUE) {
	#
	# check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.getDirnameVerify* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    civet_subdir <- 'verify'
    rx <- civet.getDirname(civet_keyname, civet_scanid, civet_subdir, settings, opt, checkExistence)

    if ( opt$debug) {cat(sprintf("Exiting method *civet.getDirnameVerify* ...\n"))}
    return(rx)
}


# =============================================================================
# Purpose: 
#	Read a selection of Civet-generated *.dat files and return the
#	contents in a list.
#
# Note: Nothing really.
# =============================================================================
#
civet.readCivetDatFiles <- function(civet_keyname, civet_scanid, settings, opt) {
	#
    # check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug) {cat(sprintf("Entering method *civet.readCivetDatFiles* ...\n"))}

    # check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)

    # get the scan's directory name (not the fullpath, unless explicitly requested)
    civet_scan_dirname <- civet.getScanDirectoryName(civet_keyname, civet_scanid, settings, opt, fullpath=FALSE, checkExistence=FALSE)
    civet_scan_dirname_fullpath <- civet.getScanDirectoryName(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=FALSE)
	
	# init returning list
	return_list <-list()
	
	
	# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	# load the tissue classify volume info
	#	
	# get a list of matching filenames in the classify dir, and return
    if ( opt$debug) {cat(sprintf("... load *cls_volumes.dat* file ...\n"))}
    if ( !civet.accessorIsImplemented(c('1.1.9', '1.1.11'), settings$CIVET_VERSION) ) {stop()}
    filename_fullpath <- civet.getFilename(civet_keyname, civet_scanid, 'classify', '_cls_volumes.dat', settings, opt, fullpath=TRUE, checkExistence=TRUE)
	myDf <- read.table(filename_fullpath,
								row.names=c("csf", "gm", "wm"),
								col.names=c("tissueType_code", "volume"))
	#	
	return_list$native_tissue_volumes <- myDf


	# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	# load gyrification indices
	# ... left
	if ( opt$debug) {cat(sprintf("... load *gi_left.dat* files ...\n"))}
    if ( !civet.accessorIsImplemented(c('1.1.7', '1.1.9', '1.1.11'), settings$CIVET_VERSION) ) {stop()}
    gi_left_file_fullPath <- civet.getFilename(civet_keyname, civet_scanid, 'surfaces', '_gi_left.dat', settings, opt, fullpath=TRUE, checkExistence=TRUE)
	gi_left.df <- read.table(gi_left_file_fullPath, sep=":")
    colnames(gi_left.df) <- c("surfaceType", "gi")
    if ( opt$debug ) cat(sprintf("Debug: civet.readCivetDatFiles: gi_left_file_fullPath: %s \n", gi_left_file_fullPath))
    if ( opt$debug ) print(gi_left.df)

	# ... right
    gi_right_file_fullPath <- civet.getFilename(civet_keyname, civet_scanid, 'surfaces', '_gi_right.dat', settings, opt, fullpath=TRUE, checkExistence=TRUE)
	gi_right.df <- read.table(gi_right_file_fullPath, sep=":")
    colnames(gi_right.df) <- c("surfaceType", "gi")
    if ( opt$debug ) cat(sprintf("Debug: civet.readCivetDatFiles: gi_right_file_fullPath: %s \n", gi_right_file_fullPath))
    if ( opt$debug ) print(gi_right.df)
	#
	return_list$gyrification_index <- c(lh=gi_left.df[1,"gi"], rh=gi_right.df[1,"gi"]) 


	# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	# load the cerebral volume info
	#	
    if ( opt$debug) {cat(sprintf("... load *cerebral_volume.dat* file ...\n"))}
    if ( !civet.accessorIsImplemented(c('1.1.9', '1.1.11'), settings$CIVET_VERSION) ) {stop()}
    cerebral_volumes_fullPath <- civet.getFilename(civet_keyname, civet_scanid, 'thickness', '_cerebral_volume.dat', settings, opt, fullpath=TRUE, checkExistence=TRUE)
    cerebral_volumes.df <- read.table(cerebral_volumes_fullPath, 
											row.names=c("extra_cerebral_csf", "cortical_gray", "wmSurface_plus_contents"),
											col.names=c("code", "volume"))
	#	
	return_list$native_cerebral_volumes <- cerebral_volumes.df



	# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	# load the percentage values from the verify subdir
	#	
	#
	
	# create containing list
	quality_control <- list()
	
	# (A) Load *_brainmask_qc.txt
	#	e.g., "native skull mask in stx space (11.77%)"
	#
	# ... open file connection, read 1 line, then close()
    if ( opt$debug) {cat(sprintf("... load *brainmask_qc.txt* file ...\n"))}
    if ( !civet.accessorIsImplemented(c('1.1.7', '1.1.9', '1.1.11'), settings$CIVET_VERSION) ) {stop()}
    verify_qc_fullPath <- civet.getFilename(civet_keyname, civet_scanid, 'verify', '_brainmask_qc.txt', settings, opt, fullpath=TRUE, checkExistence=TRUE)
	verify_qc.con <- file(verify_qc_fullPath, open="rt")
	txtLine <- readLines(verify_qc.con, n=1)
	close(verify_qc.con)
	#
	# ... extract the percentage value
	ndx <- regexpr("[[:digit:]]+.[[:digit:]]+", txtLine)
	pctValue <- substr(txtLine, ndx, ndx-1+attr(ndx, "match.length"))
	pctValue <- as.numeric(pctValue)
	#	
	quality_control$brainmask_qc <- pctValue


	#
	# (B) Load *_classify_qc.txt
	#	e.g., "classified image CSF 15.01%  GM 47.86%  WM 37.13%"
	#
	# ... open file connection, read 1 line, then close()
    if ( opt$debug) {cat(sprintf("... load *classify_qc.txt* file ...\n"))}
	if ( !civet.accessorIsImplemented(c('1.1.7', '1.1.9', '1.1.11'), settings$CIVET_VERSION) ) {stop()}
    verify_qc_fullPath <- civet.getFilename(civet_keyname, civet_scanid, 'verify', '_classify_qc.txt', settings, opt, fullpath=TRUE, checkExistence=TRUE)
    verify_qc.con <- file(verify_qc_fullPath, open="rt")
	txtLine <- readLines(verify_qc.con, n=1)
	close(verify_qc.con)
	
	
	# init receiving data.frame
	classify.df <- data.frame(pct=rep(0,3), row.names=c("csf", "gm", "wm"))
	
	# ... extract the indices to the percentage values
	ndx <- gregexpr("[[:digit:]]+.[[:digit:]]+", txtLine)
	csf_ndx <- c(ndx[[1]][1], 
	             ndx[[1]][1] - 1 + attr(ndx[[1]], "match.length")[1])

	gm_ndx <- c(ndx[[1]][2], 
	             ndx[[1]][2] - 1 + attr(ndx[[1]], "match.length")[2])

	wm_ndx <- c(ndx[[1]][3], 
	             ndx[[1]][3] - 1 + attr(ndx[[1]], "match.length")[3])
		
	# ... extract and store the values
	csf_pct <- substr(txtLine, csf_ndx[1], csf_ndx[2])
	classify.df["csf", "pct"] <- as.numeric(csf_pct)
	#	
	gm_pct <- substr(txtLine, gm_ndx[1], gm_ndx[2])
	classify.df["gm", "pct"] <- as.numeric(gm_pct)
	#
	wm_pct <- substr(txtLine, wm_ndx[1], wm_ndx[2])
	classify.df["wm", "pct"] <- as.numeric(wm_pct)
	#
	quality_control$classify_qc <- classify.df


	#
	# (C) Load *_surface_qc.txt
	#	e.g., "white surface ( 8.06%), gray surface (10.03%)"
	#
	# ... open file connection, read 1 line, then close()
    if ( opt$debug) {cat(sprintf("... load *surface_qc.txt* file ...\n"))}
	if ( !civet.accessorIsImplemented(c('1.1.7', '1.1.9', '1.1.11'), settings$CIVET_VERSION) ) {stop()}
    verify_qc_fullPath <- civet.getFilename(civet_keyname, civet_scanid, 'verify', '_surface_qc.txt', settings, opt, fullpath=TRUE, checkExistence=TRUE)
    verify_qc.con <- file(verify_qc_fullPath, open="rt")
	txtLine <- readLines(verify_qc.con, n=1)
	close(verify_qc.con)
	
	
	# init receiving data.frame
	surface.df <- data.frame(pct=rep(0,2), row.names=c("gm", "wm"))
	
	# ... extract the indices to the percentage values
	ndx <- gregexpr("[[:digit:]]+.[[:digit:]]+", txtLine)
	wm_ndx <- c(ndx[[1]][1], 
	             ndx[[1]][1] - 1 + attr(ndx[[1]], "match.length")[1])

	gm_ndx <- c(ndx[[1]][2], 
	             ndx[[1]][2] - 1 + attr(ndx[[1]], "match.length")[2])
		
	# ... extract and store the values
	gm_pct <- substr(txtLine, gm_ndx[1], gm_ndx[2])
	surface.df["gm", "pct"] <- as.numeric(gm_pct)
	#	
	wm_pct <- substr(txtLine, wm_ndx[1], wm_ndx[2])
	surface.df["wm", "pct"] <- as.numeric(wm_pct)
	#
	quality_control$surface_qc <- surface.df
	
	#
	return_list$quality_control <- quality_control

	# return final list
    if ( opt$debug) {cat(sprintf("Exiting method *civet.readCivetDatFiles* ...\n"))}
	return(return_list)

}



# =============================================================================
# Purpose: 
#	Return a named vector containing the tisse volumes, in stx space, derived from 
#	the final tissue classification volume.
#
# =============================================================================
#
civet.computeStxTissueVolumes <- function(civet_keyname, civet_scanid, settings, opt) {
	#
    # check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug ) {cat(sprintf("Entering method *civet.computeStxTissueVolumes* ...\n"))}
    #
	# check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)
	
	# get classify volume name
    filename_fullpath <- civet.getFilenameClassify(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
	cls_vol <- mincIO.readVolume(filename_fullpath)

	# explode classify into components
	clsX <- volume.explodeLabelVolume(cls_vol, opt, civetLabels=TRUE, labels=c(1,2,3))
	
	# store elements into named vector
	cls_vec <- numeric(3)
	names(cls_vec) <- c("csf", "gm", "wm")
	cls_vec["csf"] <- sum(clsX$csf)
	cls_vec["gm"] <- sum(clsX$gm)
	cls_vec["wm"] <- sum(clsX$wm)
	
    if ( opt$debug ) {cat(sprintf("Exiting method *civet.computeStxTissueVolumes* ...\n"))}
	return(cls_vec)
}
#

# =============================================================================
# Purpose: 
#	XFM files contain information to transform a given volume to a model.
#	In the case of Civet and rescaling, the XFM contains the rescaling 
#	factors (x,y,z) needed to transform the Native volume to the model, which
#	currently, is usually the symmetrical icbm-152 model.
#
#	This functuon serves to compute a global rescaling factor by reading
#	the individual x,y,z rescales from the XFM, and returning the
#	product.
#
#	Interpretation of rescaling factors:
#	(a) > 1.0 = native brain is expanded to fit model
#	(b) < 1.0 = native brain is reduced to fit model
#
# =============================================================================
#
civet.computeNativeToStxRescalingFactor <- function(civet_keyname, civet_scanid, settings, opt) {
	#
    # check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug ) {cat(sprintf("Entering method *civet.computeNativeToStxRescalingFactor* ...\n"))}
    #
	# check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)
	
	# read linear xfm file
    xfmFilename <- civet.getFilenameLinearTransform(civet_keyname, civet_scanid, settings, opt, fullpath=TRUE, checkExistence=TRUE)
	xfm.df <- rmincUtil.readLinearXfmFile(xfmFilename)
	
	# compute global linear scaling factor
	scaling_factor <- prod(xfm.df["scale",])
	
	# return
    if ( opt$debug ) {cat(sprintf("Exiting method *civet.computeNativeToStxRescalingFactor* ...\n"))}
	return(scaling_factor)
}
#



# =============================================================================
# Purpose: 
#	Return a named vector containing NATIVE space tisse volumes, derived from 
#	the final tissue classification volume.
#
# =============================================================================
#
civet.computeNativeTissueVolumes <- function(civet_keyname, civet_scanid, settings, opt) {
	#
    # check/update input settings/options
    settings <- civet.processArgsSettings(settings)
    opt <- civet.processArgsOpt(opt)
    if ( opt$debug ) {cat(sprintf("Entering method *civet.computeNativeTissueVolumes* ...\n"))}
	#
	# check whether the Civet version has been tested
	civet.checkVersion(settings$CIVET_VERSION, opt)
	
	# get vector of tissue volumes in stx space first
    cls_vec <- civet.computeStxTissueVolumes(civet_keyname, civet_scanid, settings, opt) 

	# compute the global rescaling factor
    scaling_factor <- civet.computeNativeToStxRescalingFactor(civet_keyname, civet_scanid, settings, opt)
	
	# divide the stx volumes by the scaling factor
	cls_vec <- cls_vec / scaling_factor
	
	# return
    if ( opt$debug ) {cat(sprintf("Exiting method *civet.computeNativeTissueVolumes* ...\n"))}
	return(cls_vec)
}





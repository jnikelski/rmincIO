.onLoad <- function(libname_fullpath, pkgname) {
   #
   # Note:  .onLoad is used for processing that should be done after the package 
   #        namespace has been loaded -- the the package is not yet attached:
   #        For example:
   #
   #  1. Loading dynamic libraries
   #  2. ????

   #  library and package names are the same (in this case)
   packageStartupMessage(paste("Loading namespace from R Library: ", libname_fullpath, "  (Package: ", pkgname, ")", sep=""))
   
   # do the library load via the NAMESPACE file
   #library.dynam(libName, package=pkgname, lib.loc=libpath)
}



.onAttach <- function(libname_fullpath, pkgname) {
   #
   # Note:  .onAttach is used for processing that can only be done after the package 
   #        and its namespace has been completely loaded and attached. For example:
   #
   #  1. Displaying package start-up messages
   #  2. Loading package variables into the global environment
   #

   #  library and package names are the same (in this case)
   packagename_fullpath <- file.path(libname_fullpath, pkgname)
   packageStartupMessage(paste("Attaching package: ", packagename_fullpath, "\n", sep=""))
   
   # set or clear the debug switch (and report, as needed)
   R_DEBUG_rmincIO <<- 0
   if ( R_DEBUG_rmincIO ) {
      packageStartupMessage("Package rmincIO. Debugging is turned ON.\n")
   }
}



.Last.lib <- function(libpath) {
	#
	#  library and package names are the same (in this case)
	libName <- "rmincIO"
	pkgName <- "rmincIO"
	cat(paste("Unloading shared library: ", libName, ". Library unload path is ", libpath,"\n", sep=""))
	library.dynam.unload(libName, file.ext=".so", verbose=TRUE, libpath=libpath)
}

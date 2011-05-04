.First.lib <- function(libpath, pkgname) {
#
	# set or clear the debug switch
	R_DEBUG_rminc2 <<- 0

#  library and package names are the same (in this case)
	libName = pkgname
	packageStartupMessage(paste("Loading library: ", libName, "  (Package: ", pkgname, ", Library path: ", libpath,")\n", sep=""))
	library.dynam(libName, package=pkgname, lib.loc=libpath)

	if ( R_DEBUG_rminc2 ) {
		cat("Package rminc2. Debugging is turned ON.\n")
	}

}

.Last.lib <- function(libpath) {
	#
	#  library and package names are the same (in this case)
	libName <- "rminc2"
	pkgName <- "rminc2"
	cat(paste("Unloading shared library: ", libName, ". Library unload path is ", libpath,"\n", sep=""))
	library.dynam.unload(libName, file.ext=".so", verbose=TRUE, libpath=libpath)
}

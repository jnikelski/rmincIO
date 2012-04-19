\name{rmincIO.isMinc}
\Rdversion{1.1}
\alias{rmincIO.isMinc}
\title{
    Check File For Minc Volume Format
}
\description{
    This logical function returns \code{TRUE} if the input volume is structured
    as a minc1 (netcdf) or minc2 (hdf5) volume.  Else, \code{FALSE} is returned.
}
\usage{
rmincIO.isMinc(filename)
}

\arguments{
  \item{filename}{Minc filename.}
}

\details{
    This routine calls the \code{\link{rmincIO.isMinc1}} and \code{\link{rmincIO.isMinc2}} functions to do
    the minc checking.
}
\value{ 
    \code{TRUE} is returned for minc volumes, \code{FALSE} for everything else.
}

\author{Jim Nikelski \email{nikelski@bic.mni.mcgill.ca}}

\seealso{
    \code{\link{rmincIO.isMinc1}} \code{\link{rmincIO.isMinc2}} \code{\link{rmincIO.asMinc2}} \code{\link{rmincIO.isReadable}}
}

\examples{
\dontshow{
# clear debug flag and get full volume pathname
# ... dunno why zzz.R debug setting is not passed
    R_DEBUG_rmincIO <- 0      
    volDir <- system.file("packageData/volumes", package="rmincIO")
}
# check for minc
myFile <- file.path(volDir, "icbm_avg_152_t1_tal_lin.mnc")
if ( rmincIO.isMinc(myFile) ) {
    myFile <- rmincIO.asMinc2(myFile)           # could be minc1, so call converter
    myFileInfo <- mincIO.readMincInfo(myFile)   # read the mincInfo for this volume
    print(myFileInfo)                           # ... and print it
}
}


\name{rmincUtil.isMinc}
\Rdversion{1.1}
\alias{rmincUtil.isMinc}
\title{
    Check File For Minc Volume Format
}
\description{
    This logical function returns \code{TRUE} if the input volume is structured
    as a minc1 (netcdf) or minc2 (hdf5) volume.  Else, \code{FALSE} is returned.
}
\usage{
rmincUtil.isMinc(filename)
}

\arguments{
  \item{filename}{Minc filename.}
}

\details{
    This routine calls the \code{\link{rmincUtil.isMinc1}} and \code{\link{rmincUtil.isMinc2}} functions to do
    the minc checking.
}
\value{ 
    \code{TRUE} is returned for minc volumes, \code{FALSE} for everything else.
}

\author{Jim Nikelski \email{nikelski@bic.mni.mcgill.ca}}

\seealso{
    \code{\link{rmincUtil.isMinc1}} \code{\link{rmincUtil.isMinc2}} \code{\link{rmincUtil.asMinc2}} \code{\link{rmincUtil.isReadable}}
}

\examples{
\dontrun{
# check for minc
myFile <- file.path(volDir, "icbm_avg_152_t1_tal_lin.mnc")
if ( rmincUtil.isMinc(myFile) ) {
    myFile <- rmincUtil.asMinc2(myFile)         # could be minc1, so call converter
    myFileInfo <- mincIO.readMincInfo(myFile)   # read the mincInfo for this volume
    print(myFileInfo)                           # ... and print it
}
}}


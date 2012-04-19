\name{rmincIO.isMinc1}
\Rdversion{1.1}
\alias{rmincIO.isMinc1}
\title{
    Test File For Minc1 Volume Format
}
\description{
    This logical function returns \code{TRUE} if the input volume is structured
    as a minc1 (netcdf) volume.  Else, \code{FALSE} is returned.
}
\usage{
rmincIO.isMinc1(filename)
}

\arguments{
  \item{filename}{Minc filename.}
}

\details{
    This function uses the \command{file} system command to determine whether \code{filename}
    refers to a netcdf file. As such, execution of the \command{file} command must return
    the string \dQuote{NetCDF} for minc1 files.
}
\value{ 
    \code{TRUE} is returned for minc1 volumes, \code{FALSE} for everything else.
}

\author{Jim Nikelski \email{nikelski@bic.mni.mcgill.ca}}

\seealso{
    \code{\link{rmincIO.isMinc2}} \code{\link{rmincIO.isMinc}} \code{\link{rmincIO.asMinc2}} \code{\link{rmincIO.isReadable}}
}

\examples{
\dontshow{
# clear debug flag and get full volume pathname
# ... dunno why zzz.R debug setting is not passed
    R_DEBUG_rmincIO <- 0      
    volDir <- system.file("packageData/volumes", package="rmincIO")
}
# check for minc1, convert if necessary
myFile <- file.path(volDir, "average305_PET_t1_tal_lin.mnc")
if ( rmincIO.isMinc1(myFile) ) {
    myFile <- rmincIO.asMinc2(myFile)
}
}


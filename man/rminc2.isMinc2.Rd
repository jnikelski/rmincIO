\name{rminc2.isMinc2}
\Rdversion{1.1}
\alias{rminc2.isMinc2}
\title{
    Test File For Minc2 Volume Format
}
\description{
    This logical function returns \code{TRUE} if the input volume is structured
    as a minc2 (hdf5) volume.  Else, \code{FALSE} is returned.
}
\usage{
rminc2.isMinc2(filename)
}

\arguments{
  \item{filename}{Minc filename.}
}

\details{
    This function uses the \command{file} system command to determine whether \code{filename}
    refers to an hdf5 file. As such, execution of the \command{file} command must return
    the string \dQuote{Hierarchical Data Format} for minc2 files.
}
\value{ 
    \code{TRUE} is returned for minc2 volumes, \code{FALSE} for everything else.
}

\author{Jim Nikelski \email{nikelski@bic.mni.mcgill.ca}}

\seealso{
    \code{\link{rminc2.isMinc1}} \code{\link{rminc2.isMinc}} \code{\link{rminc2.asMinc2}} \code{\link{rminc2.isReadable}}
}

\examples{
\dontshow{
# clear debug flag and get full volume pathname
# ... dunno why zzz.R debug setting is not passed
    R_DEBUG_rminc2 <- 0      
    volDir <- system.file("packageData/volumes", package="rminc2")
}
# very contrived example, but gets the point across
myFile <- file.path(volDir, "average305_PET_t1_tal_lin.mnc")
if ( !rminc2.isMinc2(myFile) && rminc2.isMinc1(myFile) ) {
    myFile <- rminc2.asMinc2(myFile)
}
}


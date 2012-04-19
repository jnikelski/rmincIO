\name{rmincIO.getDataClasses}
\Rdversion{1.1}
\alias{rmincIO.getDataClasses}

\title{
    Get Minc2 Data Classes
}
\description{
    Returns a data.frame containing the minc2 data classes.
}
\usage{
rmincIO.getDataClasses()
}

\details{
    Returns a data.frame comprised of a minc2 data class numeric code and a string descriptor.  Use
    of this data.frame permits us to get the descriptive string, given the numeric code.
}

\value{A data.frame containing the minc2 data classes.}

\note{Internal use only.}

\author{Jim Nikelski \email{nikelski@bic.mni.mcgill.ca}}

\examples{
dataClasses <- rmincIO.getDataClasses()
print(dataClasses)
}

\seealso{
    \code{\link{rmincIO.getDataTypes}}
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{internal}
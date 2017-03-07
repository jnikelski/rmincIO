\name{rmincUtil.getDataClassCode}
\Rdversion{1.0}
\alias{rmincUtil.getDataClassCode}
\title{
    Get a Data Class Numeric Code
}
\description{
    Returns a single numeric code reflecting the Minc2 data class to be written.
}

\usage{
rmincUtil.getDataClassCode(dataClassAsString)
}

\details{
    Returns a single numeric code reflecting the Minc2 data class to be written. Note that the data type reflects the class of data to be written. The possible classes include: "REAL", "INTEGER", "LABEL", "COMPLEX", "UNIFORM_RECORD", "NON_UNIFORM_RECORD".
}
\value{A single numeric code reflecting the Minc2 data class to be written.}

\author{Jim Nikelski \email{nikelski@bic.mni.mcgill.ca}}

\seealso{
    \code{\link{rmincUtil.getDataClasses}} \code{\link{rmincUtil.getDataTypeCode}}
}

\examples{
\dontrun{
# write new volume as real/double
# ... set class as real in object property
mincIO.setProperty(newVolumeFilled.vol, "volumeDataClass", rmincUtil.getDataClassCode("INTEGER"))
# ... set type as double
mincIO.setProperty(newVolumeFilled.vol, "volumeDataType", rmincUtil.getDataClassCode("LONG"))
# ... write it out
mincIO.writeVolume(newVolumeFilled.vol, "volume_out.mnc", clobber=TRUE)
}}

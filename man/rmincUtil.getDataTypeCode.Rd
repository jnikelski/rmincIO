\name{rmincUtil.getDataTypeCode}
\Rdversion{1.0}
\alias{rmincUtil.getDataTypeCode}
\title{
    Get a Data Type Numeric Code
}
\description{
    Returns a single numeric code reflecting the Minc2 data type to be written.
}

\usage{
rmincUtil.getDataTypeCode(dataTypeAsString)
}

\details{
    Returns a single numeric code reflecting the Minc2 data type to be written. Note that the data type reflects the actual storage format used within the minc volume. The possible storage formats include, for example, "MI_TYPE_BYTE", "MI_TYPE_SHORT", "MI_TYPE_INT", "MI_TYPE_FLOAT", "MI_TYPE_DOUBLE", etc. The following, more memorable, short-cut values are also permitted: "FLOAT", "DOUBLE", "INTEGER", "LONG", "SHORT", "BYTE".
}
\value{A single numeric code reflecting the Minc2 data type to be written.}

\author{Jim Nikelski \email{nikelski@bic.mni.mcgill.ca}}

\seealso{
    \code{\link{rmincUtil.getDataTypes}} \code{\link{rmincUtil.getDataClassCode}}
}

\examples{
\dontrun{
# write new volume as real/double
# ... set class as real in object property
mincIO.setProperty(newVolumeFilled.vol, "volumeDataClass", rmincUtil.getDataClassCode("REAL"))
# ... set type as double
mincIO.setProperty(newVolumeFilled.vol, "volumeDataType", rmincUtil.getDataTypeCode("DOUBLE"))
# ... write it out
mincIO.writeVolume(newVolumeFilled.vol, "volume_out.mnc", clobber=TRUE)
}}


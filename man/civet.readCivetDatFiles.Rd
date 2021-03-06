\name{civet.readCivetDatFiles}
\Rdversion{1.1}
\alias{civet.readCivetDatFiles}

\title{
    Read Civet-Generated Dat Files
}
\description{
    Returns a list containing the contents of various Civet-generated text files (.dat, .txt).
}
\usage{
civet.readCivetDatFiles(scanID, baseDir, civetVersion="1.1.9")

}
\arguments{
	\item{scanID}{A string specifying the unique scan-id (and thus sub-directory) within
			the Civet root output directory.}
	\item{baseDir}{A string specifying the Civet root output directory.  This directory 
			will, in turn, contain all of the scanIDs.}
	\item{civetVersion}{An optional string specifying the version of Civet used to create
			the output.  This is significant since filenames and directory structures may
			change across difference versions of Civet.}
}

\details{
    The Civet pipeline produces a number of files during its execution.  The purpose of this function
is to read the contents of these files and return the most significant values in a list.
}

\value{A list is returned containing the following components:
	\item{native_tissue_volumes}{The volumes, in cubic millimeters, of the 3 primary classification components. Note that the values that are returned reflect the volumes within the \bold{native} brain.  These values are computed by dividing the stereotactic volume values by a re-scaling factor comprised of xScale * yScale * zScale (as defined in the linear xfm file).}
	\item{gyrification_index}{The gyrification index is computed per hemisphere and reflects the degree of gyrification at the cortical surface.  Value are computed by dividing the cortical gray matter area by the area of a convex (smooth) hull over the same area.  This computation will always yield a number greater than 1, with larger numbers indicating greater gyrification.}
	\item{native_cerebral_volumes}{While 3 values are returned, only one is a particular use.  The value labeled ``cortical_gray'' reflects the volume of all cortical gray matter in the native space brain.  The ``extra_cerebral_csf'' value reflects the volume of all extra-cerebral csf (i.e., that at the cortical surface and within the sulci), and the ``wmSurface_plus_contents'' value reflects the volume of the white matter surface and the volume of all components encapsulated by that surface. All volume measurements are relative to the \bold{native} space brain.}
	\item{quality_control}{Most of these values are only of interest to the Civet developers.  The values labelled ``classify_qc'' reflect the proportion of the various components identified by tissue classification.  As these values are percentages, they are applicable to both native and stereotactic space.}

}


\author{Jim Nikelski \email{nikelski@bic.mni.mcgill.ca}}

\examples{
\dontrun{
library(rmincIO)

# set Civet root path and scan-identifier
basePath <- "~/tmp/ADNI/civet/pipeOut"
scanID = "0221-M-AD"

# read in the dat files contents
myDats <- civet.readCivetDatFiles(scanID, basePath)
print(myDats)

# print GI info
print(myDats$gyrification_index)
print(myDats$gyrification_index["lh"])

# print and extract cortical volume
print(myDats$native_cerebral_volumes)
native_space_cortical_gray_volume <- myDats$native_cerebral_volumes["cortical_gray", "volume"]
print(native_space_cortical_gray_volume)

}}





\name{rmincUtil.convertVoxelToWorld}
\Rdversion{1.1}
\alias{rmincUtil.convertVoxelToWorld}
\title{
    Convert Voxel to World Coordinates
}
\description{
    Converts 1-relative 3 dimensional ijk (voxel) coordinates into xyz (world) coordinates.
}

\usage{
rmincUtil.convertVoxelToWorld(filename, voxCoords)
}

\arguments{
  \item{filename}{The name of a minc2 volume to be used to do the conversion to world space.}
  \item{voxCoords}{A 3 item vector of 1-relative voxel coordinates.}
}

\details{
    I believe that all coordinates are in xyz order.  I am pretty sure that this would not 
    work with a 4D volume, but have not yet come up with a use-case, given that no 4D 
    internal structures exist.  Perhaps, reading a frame from a 4D volume, and then wanting
    to do a coordinate conversion. Hmmmmm, must ponder.
}
\value{A 3-item vector of world coordinates.}

\author{Jim Nikelski \email{nikelski@bic.mni.mcgill.ca}}

\seealso{
    \code{\link{rmincUtil.convertWorldToVoxel}}
}

\examples{
\dontrun{
# set the xyz voxel coordinates
ijkCoords <- c(10, 20, 30)

# create a full pathname to the sample volumes
v305PET <- file.path(volDir, "average305_PET_t1_tal_lin.mnc")
print(v305PET)

# convert and show it
xyzCoords <- rmincUtil.convertVoxelToWorld(v305PET, ijkCoords)
print(xyzCoords)
}}


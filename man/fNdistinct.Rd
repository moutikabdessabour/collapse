\name{fNdistinct}
\alias{fNdistinct}
\alias{fNdistinct.default}
\alias{fNdistinct.matrix}
\alias{fNdistinct.data.frame}
\alias{fNdistinct.grouped_df}
\title{Fast (Grouped) Distinct Value Count for Matrix-Like Objects}  % Vectors, Matrix and Data Frame Columns}
\description{
\code{fNdistinct} is a generic function that (column-wise) computes the number of distinct values in \code{x}, (optionally) grouped by \code{g}. It is significantly faster than \code{length(unique(x))}. The \code{\link{TRA}} argument can further be used to transform \code{x} using its (grouped) distinct value count.
}

\usage{
fNdistinct(x, \dots)

\method{fNdistinct}{default}(x, g = NULL, TRA = NULL, na.rm = TRUE,
           use.g.names = TRUE, \dots)

\method{fNdistinct}{matrix}(x, g = NULL, TRA = NULL, na.rm = TRUE,
           use.g.names = TRUE, drop = TRUE, \dots)

\method{fNdistinct}{data.frame}(x, g = NULL, TRA = NULL, na.rm = TRUE,
           use.g.names = TRUE, drop = TRUE, \dots)

\method{fNdistinct}{grouped_df}(x, TRA = NULL, na.rm = TRUE,
           use.g.names = FALSE, keep.group_vars = TRUE, \dots)
}
\arguments{
\item{x}{a vector, matrix, data frame or grouped tibble (\code{dplyr::grouped_df}).}

\item{g}{a factor, \code{\link{GRP}} object, atomic vector (internally converted to factor) or a list of vectors / factors (internally converted to a \code{\link{GRP}} object) used to group \code{x}.}

\item{TRA}{an integer or quoted operator indicating the transformation to perform:
1 - "replace_fill"     |     2 - "replace"     |     3 - "-"     |     4 - "-+"     |     5 - "/"     |     6 - "\%"     |     7 - "+"     |     8 - "*"     |     9 - "\%\%"     |     10 - "-\%\%". See \code{\link{TRA}}.}


\item{na.rm}{logical. \code{TRUE}: Skip missing values in \code{x} (faster computation). \code{FALSE}: Also consider 'NA' as one distinct value.}

\item{use.g.names}{logical. Make group-names and add to the result as names (default method) or row-names (matrix and data frame methods). No row-names are generated for \emph{data.table}'s.}

\item{drop}{\emph{matrix and data.frame method:} Logical. \code{TRUE} drops dimensions and returns an atomic vector if \code{g = NULL} and \code{TRA = NULL}.}

\item{keep.group_vars}{\emph{grouped_df method:} Logical. \code{FALSE} removes grouping variables after computation.}

\item{\dots}{arguments to be passed to or from other methods.}

}
\details{
\code{fNdistinct} implements a fast algorithm to find the number of distinct values utilizing index- hashing implemented in the \code{Rcpp::sugar::IndexHash} class.

If \code{na.rm = TRUE} (the default), missing values will be skipped yielding substantial performance gains in data with many missing values. If \code{na.rm = TRUE}, missing values will simply be treated as any other value and read into the hash-map. Thus with the former, a numeric vector \code{c(1.25,NaN,3.56,NA)} will have a distinct value count of 2, whereas the latter will return a distinct value count of 4.

Grouped computations are performed by mapping the data to a sparse-array and then hash-mapping each group. This is often not much slower than using a larger hash-map for the entire data when \code{g = NULL}.

\code{fNdistinct} preserves all attributes of non-classed vectors / columns, and only the 'label' attribute (if available) of classed vectors / columns (i.e. dates or factors). When applied to data frames and matrices, the row-names are adjusted as necessary.

}
\value{
Integer. The number of distinct values in \code{x}, grouped by \code{g}, or (if \code{\link{TRA}} is used) \code{x} transformed by its distinct value count, grouped by \code{g}.
}
\seealso{
\code{\link{fNobs}}, \link[=A1-fast-statistical-functions]{Fast Statistical Functions}, \link[=collapse-documentation]{Collapse Overview}
}
\examples{
## default vector method
fNdistinct(airquality$Solar.R)                   # Simple distinct value count
fNdistinct(airquality$Solar.R, airquality$Month) # Grouped distinct value count

## data.frame method
fNdistinct(airquality)
fNdistinct(airquality, airquality$Month)
fNdistinct(wlddev)                               # Works with data of all types!
head(fNdistinct(wlddev, wlddev$iso3c))

## matrix method
aqm <- qM(airquality)
fNdistinct(aqm)                                  # Also works for character or logical matrices
fNdistinct(aqm, airquality$Month)

## method for grouped tibbles - for use with dplyr:
library(dplyr)
airquality \%>\% group_by(Month) \%>\% fNdistinct
wlddev \%>\% group_by(country) \%>\%
             select(PCGDP,LIFEEX,GINI,ODA) \%>\% fNdistinct

}
\keyword{univar}
\keyword{manip}

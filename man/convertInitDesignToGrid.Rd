% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cm_convertInitDesignToGrid.R
\name{convertInitDesignToGrid}
\alias{convertInitDesignToGrid}
\title{Converts an Initial Design into a Cell Mapping Grid}
\usage{
convertInitDesignToGrid(init, lower, upper, blocks)
}
\arguments{
\item{init}{[\code{\link{data.frame}}]\cr
The initial design, consisting of \code{d + 1} columns ({d} dimensions and
one column for the objective value) and one row per observation.}

\item{lower}{[\code{\link{numeric}} or \code{\link{integer}}]\cr
The lower limits per dimension.}

\item{upper}{[\code{\link{numeric}} or \code{\link{integer}}]\cr
The upper limits per dimension.}

\item{blocks}{[\code{\link{integer}}]\cr
The number of blocks per dimension.}
}
\value{
[\code{\link{data.frame}}].\cr
  A \code{data.frame}, which includes an additional column (\code{cell.ID})
  compared to the initial design (\code{init}). The \code{cell.ID} will be a
  value between 1 and \code{prod(blocks)}.
}
\description{
This function takes an initial design -- with rows being the observations
  and columns standing for the dimensions (plus the corresponding objective)
  -- and adds an additional column to the \code{data.frame}. This additional
  column states the cell ID for each observation.
}
\examples{
# (1) create an initial design:
X = t(replicate(n = 200, expr = runif(n = 5, min = -10, max = 10)))
f = function(x) sum(x^2)
y = apply(X = X, MARGIN = 1, FUN = f)
init = data.frame(X, y = y)

# (2) compute the cell mapping grid
convertInitDesignToGrid(init = init, lower = -10, upper = 10, blocks = 20)

}

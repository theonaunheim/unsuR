#' r betaPERT Function
#'
#' This function allows you to sample a Modified Beta PERT distribution.
#' Initially inspired by: https://www.riskamp.com/beta-pert.
#' Improved upon based on statistical guidance in:
#' "Risk Analysis-A Quantitative Guide" by David Vose (John Wiley & Sons, 2000).
#' @param lambda Confidence/kurtosis modifier. Defaults to 4.
#' @param n 
#' @param x.min
#' @param x.max
#' @param x.mode
#' @keywords rpert
#' @export
#' @examples
#' rpert()

rpert <- function( n, x.min, x.max, x.mode, lambda = 4 ){
  if( x.min > x.max || x.mode > x.max || x.mode < x.min ) stop( "invalid parameters" );
  x.range <- x.max - x.min;
  if( x.range == 0 ) return( rep( x.min, n ));
  mu <- ( x.min + x.max + lambda * x.mode ) / ( lambda + 2 );
  # special case if mu == mode
  if( mu == x.mode ){
    v <- ( lambda / 2 ) + 1
  }
  else {
    v <- (( mu - x.min ) * ( 2 * x.mode - x.min - x.max )) /
      (( x.mode - mu ) * ( x.max - x.min ));
  }
  w <- ( v * ( x.max - mu )) / ( mu - x.min );
  return ( rbeta( n, v, w ) * x.range + x.min );
}

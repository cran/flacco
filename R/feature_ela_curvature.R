calculateCurvatureFeatures = function(feat.object, control) {
  assertClass(feat.object, "FeatureObject")
  if (is.null(feat.object$fun))
    stop("The curvature features require the exact function!")
  if (missing(control))
    control = list()
  assertList(control)
  allow.costs = control_parameter(control, "allow_costs", TRUE)
  if (!allow.costs)
    stop("You can not prohibit additional costs and still try to compute these features!")
  measureTime(expression({
    f = initializeCounter(feat.object$fun)
    X = extractFeatures(feat.object)
    d = feat.object$dim
    low = feat.object$lower
    upp = feat.object$upper
    N = control_parameter(control, "ela_curv.sample_size", 100L * d)
    delta = control_parameter(control, "ela_curv.delta", 1e-4)
    eps = control_parameter(control, "ela_curv.eps", 1e-4)
    zero.tol = control_parameter(control, "ela_curv.zero_tol",
      sqrt(.Machine$double.eps / 7e-07))
    r = control_parameter(control, "ela_curv.r", 4)
    v = control_parameter(control, "ela_curv.v", 2)
    if (N > feat.object$n.obs) {
      warningf("As the size of the sample used for computing the curvature features (ela_curv.sample_size = %i) exceeds the total number of observations (%i) in this object, it has automatically been reduced to %i.",
        N, feat.object$n.obs, feat.object$n.obs)
      N = feat.object$n.obs
    }
    calcNumDeriv = function(par) {
      h0 = abs(delta * par) + eps * (abs(par) < zero.tol)
      side = ((par - low) <= h0) - ((upp - par) <= h0)
      side = ifelse(side == 0, NA, side)
      gr = abs(numDeriv::grad(f, par, side = side, method.args = list(d = delta,
        eps = eps, zero.tol = zero.tol, r = r, v = v)))
      gr_scale = ifelse(min(gr) > 0, max(gr) / min(gr), NA)
      hess = flaccoHessian(f, par, method.args = list(d = delta,
        eps = eps, zero.tol = zero.tol, r = r, v = v), lower = low, upper = upp)
      eig = abs(eigen(hess)$values)
      hess_cond = ifelse(min(eig) > 0, max(eig) / min(eig), NA)
      return(c(curv.grad_norm = sqrt(sum(gr^2)),
        curv.grad_scale = gr_scale,
        curv.hessian_cond = hess_cond))
    }
    ids = sample(feat.object$n.obs, N, replace = FALSE)
    res = apply(X[ids, ], 1, calcNumDeriv)
    fn = apply(res, 1, function(x) {
      z = fivenum(x)
      if (all(is.na(x))) {
        m = NA_real_
      } else {
        m = mean(x, na.rm = TRUE)
      }
      return(c(z[seq_len(2L)], m, z[3L:5L], sd(x, na.rm = TRUE), nas = mean(is.na(x))))
    })
    fn = as.vector(fn, mode = "list")
    nn = c("min", "lq", "mean", "med", "uq", "max", "sd", "nas")
    names(fn) = paste(rep(rownames(res), each = length(nn)), nn, sep = ".")
    names(fn) = paste0("ela_", names(fn))
    fn
    return(c(fn, ela_curv.costs_fun_evals = showEvals(f)))
  }), "ela_curv")
}

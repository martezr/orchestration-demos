plan kuber(
   TargetSpec $nodes,
) {
   apply_prep([$nodes])

  apply($nodes) {
    class { 'kubernetes':
     controller => true,
    }
  }

}

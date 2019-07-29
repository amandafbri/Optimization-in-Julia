<h1> Optimization in Julia Language </h1>

This repo presents two different decomposition strategies for control and optimization systems implemented in Julia Language with JuMP package.

The first one is a bilevel decomposition approach to a predictive model control (MPC) for dynamic systems coupled by resource constraints. The implemented proposal has a hierarchical structure of bilevel decomposition, which results in the same solution that would be obtained by a centralized controller, demonstrating a better computational robustness than the centralized fashion. It is also shown that this decomposition allows computional parallelization. Numerical experiments with synthetic but representative systems were studied.

The Benders decomposition approach is being developed.

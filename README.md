# Robust and efficient pre-processing techniques for particle-based methods including dynamic boundary generation

[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15730554.svg)](https://doi.org/10.5281/zenodo.15730554)

This repository contains information and code to reproduce the results presented in the
article
```bibtex
@misc{neher2025robustefficientpreprocessingtechniques,
      title={Robust and efficient pre-processing techniques for particle-based methods including dynamic boundary generation},
      author={Niklas S. Neher and Erik Faulhaber and Sven Berger and Christian Weißenfels and Gregor J. Gassner and Michael Schlottke-Lakemper},
      year={2025},
      eprint={2506.21206},
      archivePrefix={arXiv},
      primaryClass={math.NA},
      url={https://arxiv.org/abs/2506.21206},
}
```

If you find these results useful, please cite the article mentioned above. If you
use the implementations provided here, please **also** cite this repository as
```bibtex
@misc{Neher2025reproducibility,
  title={Reproducibility repository for
         "{R}obust and efficient pre-processing techniques for particle-based methods including dynamic boundary generation"},
  author={Neher, Niklas S. and Faulhaber, Erik and Berger, Sven and Weißenfels Christian and Gassner, Gregor J. and Schlottke-Lakemper, Michael},
  year= {2025},
  howpublished={\url{https://github.com/trixi-framework/paper-2025-particle-based_preprocessing}},
  doi={10.5281/zenodo.15730554}
}
```


## Abstract

Obtaining high-quality particle distributions for stable and accurate particle-based simulations poses significant challenges, especially for complex geometries.
We introduce a preprocessing technique for 2D and 3D geometries, optimized for smoothed particle hydrodynamics (SPH) and other particle-based methods.
Our pipeline begins with the generation of a resolution-adaptive point cloud near the geometry's surface employing a face-based neighborhood search.
This point cloud forms the basis for a signed distance field,
enabling efficient, localized computations near surface regions.
To create an initial particle configuration, we apply a hierarchical winding number method for fast and accurate inside-outside segmentation.
Particle positions are then relaxed using an SPH-inspired scheme, which also serves to pack boundary particles.
This ensures full kernel support and promotes isotropic distributions while preserving the geometry interface.
By leveraging the meshless nature of particle-based methods,
our approach does not require connectivity information and is thus straightforward to integrate into existing particle-based frameworks.
It is robust to imperfect input geometries and memory-efficient without compromising performance.
Moreover, our experiments demonstrate that with increasingly higher resolution, the
resulting particle distribution converges to the exact geometry.


## Numerical experiments

The numerical experiments presented in the paper use
[TrixiParticles.jl](https://github.com/trixi-framework/TrixiParticles.jl).
To reproduce the numerical experiments, you need to install
[Julia](https://julialang.org/).

The subfolder `code` of this repository contains a `README.md` file with
instructions to reproduce the numerical experiments.
The subfolders also include the input data, result data and scripts for postprocessing.

All numerical experiments were carried out using Julia v1.11.5.

## Authors

- Niklas S. Neher
- Erik Faulhaber
- Sven Berger
- Christian Weißenfels
- Gregor J. Gassner
- Michael Schlottke-Lakemper

## License

The contents of this repository are available under the [MIT license](LICENSE.md). If you reuse our
code or data, please also cite us (see above).


## Disclaimer

Everything is provided as is and without warranty. Use at your own risk!

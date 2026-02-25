""" Taken from /project/biocomplexity/dtra/Toxin_Building_2025/chem-poison-godot/analysis/health_model_analysis.ipynb"""

import numpy as np
import random

def hill_response(dose, ec50=19.19, hill_coefficient=5, e_max=1.07):
    """
    Calculate the Hill dose-response.

    Parameters:
    - dose: float or array-like, dose of the substance
    - ec50: float, dose at which 50% of max response is achieved
    - hill_coefficient: float, describes steepness (default: 1)
    - e_max: float, max response (default: 1.0)

    Returns:
    - response: float or array-like, proportion of max response
    """
    response = (e_max * dose**hill_coefficient) / (ec50**hill_coefficient + dose**hill_coefficient)
    return response

def sample_bimodal(n_samples=1,
                   mu1=2.5, sigma1=0.6, weight1=0.4,
                   mu2=6.0, sigma2=1.0, weight2=0.6):
    """
    Sample random values from a bimodal distribution defined by two Gaussians.

    Parameters:
    - n_samples: int, number of random values to generate
    - mu1, sigma1: mean and std dev of the first peak
    - weight1: weight of the first peak (between 0 and 1)
    - mu2, sigma2: mean and std dev of the second peak
    - weight2: weight of the second peak (1 - weight1)

    Returns:
    - samples: numpy array of generated values
    """
    assert np.isclose(weight1 + weight2, 1.0), "Weights must sum to 1"
    
    # Choose which component each sample comes from
    components = np.random.choice([1, 2], size=n_samples, p=[weight1, weight2])

    # Preallocate samples
    samples = np.zeros(n_samples)

    # Sample from corresponding Gaussian
    samples[components == 1] = np.random.normal(mu1, sigma1, size=np.sum(components == 1))
    samples[components == 2] = np.random.normal(mu2, sigma2, size=np.sum(components == 2))

    return samples
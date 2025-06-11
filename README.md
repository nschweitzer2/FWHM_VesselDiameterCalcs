# FWHM_VesselDiameterCalcs

Code to calculate diameter based on FWHM of skeleton cross section adapted from following repository:
https://github.com/optobrain/adp-1-3xtg-cortex

Please cite following paper if used:

Walek, K.W., Stefan, S., Lee, JH. et al. Near-lifespan longitudinal tracking of brain microvascular morphology, topology, and flow in male mice. Nat Commun 14, 2982 (2023). https://doi.org/10.1038/s41467-023-38609-z

**Processing Steps**

Step 1: Run "input_code_crosssection.m", making sure the skeleton and original image file are inputted correctly. Additionally, make sure these two .nii files are aligned correctly, as sometimes in postprocessing the skeleton image is rotated 90 degrees + flipped. **Important note** if you want to process faster, test out using "parfor" instead of "for" to perform parallel processing on line 10 of "find_diam.m"

Step 2: This is if you want to visualize results. The code is still pretty raw, you can definitely improve it. Run "for_pyvista.m"

Step 3: Open jupyter notebook and run through "Visualize_pyvista.ipynb"

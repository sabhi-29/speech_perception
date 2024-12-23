# Exemplar models of speech perception do not prevent the need for normalization
This GitHub repo is to document the code and data for the Independent Study Project that I took during my final semester of the master's program. The objective was to computationally model the exemplar theory of speech perception and see the effect of normalization.

## Files in the Repository

1. **Datasets.zip**: Contains the following datasets:
   - **Lie_Xie_2020**: Vowels data of native English speakers, which we call the phonetic database.
   - **Experiment_NORM_AB_after_exclusion**: The perceptual database comprising natural and synthetically produced sounds. Listeners were asked to identify the correct vowel sounds. It contains various metadata.

2. **EDA.ipynb**: Contains the initial exploratory data analysis done on the datasets. The insights derived from this analysis were used to build the final report.

3. **environment.yml**: Contains all the libraries used during this project.

4. **exemplar_model.ipynb**: The initial Naive Bayes exemplar model trained and tested on the Lie_Xie_2020 dataset.

5. **optimization on Li_Xie exemplar dataset.ipynb**: The same exemplar model in which a constrained optimization was performed to find the best set of parameters for the Naive Bayes exemplar model.

6. **main.ipynb**: The main notebook that the reader should refer to. In this notebook, we obtained the exemplars from the phonetic dataset, optimized it on a held-out dataset from the perceptual database, and observed the effect of normalization on the overall model performance. All the details will be better understood by referring to the report.

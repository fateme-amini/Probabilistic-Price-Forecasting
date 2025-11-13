# Probabilistic Price Forecasting with Stochastic Scenario Generation

This repository contains the code and analysis for a probabilistic energy price forecast, as featured in [Your Book Chapter / Project Title Here].

The project demonstrates a common workflow in energy analytics:
1.  A **deterministic forecast** is created using Facebook's Prophet to capture seasonal trends.
2.  The model's **errors (residuals)** are analyzed, revealing strong autocorrelation and a non-Gaussian distribution.
3.  Five different **stochastic models** are implemented to generate 1,000 plausible scenarios for these residuals.
4.  The models are rigorously evaluated for **statistical fairness** (does the distribution match?) and **dynamic plausibility** (does the autocorrelation match?).

## Key Models Compared

This analysis compares five methods for scenario generation:
* **Model 1: Monte Carlo (Parametric)**
* **Model 2: Latin Hypercube Sampling (LHS) (Parametric)**
* **Model 3: Bootstrap (Non-Parametric, i.i.d.)**
* **Model 4: Markov Chain (Autoregressive, Discrete)**
* **Model 5: Gaussian Copula (Autoregressive, Continuous)**

## How to Run This Project

### 1. Get the Data
This project requires the **"Energy Consumption Generation Prices and Weather"** dataset.
* Download it from Kaggle: [https://www.kaggle.com/datasets/nicholasjhana/energy-consumption-generation-prices-and-weather](https://www.kaggle.com/datasets/nicholasjhana/energy-consumption-generation-prices-and-weather)
* From the archive, you only need `energy_dataset.csv`.
* Create a folder named `data` in the root of this project.
* Place the `energy_dataset.csv` file inside the `data` folder.

The final structure should be:
```
probabilistic-price-forecasting/
├── data/
│   └── energy_dataset.csv
├── run_analysis.ipynb
├── requirements.txt
└── README.md
```

### 2. Set Up Your Environment
It is highly recommended to use a Python virtual environment.
```bash
# Clone this repository (or download the ZIP)
git clone [https://github.com/YOUR_USERNAME/probabilistic-price-forecasting.git](https://github.com/YOUR_USERNAME/probabilistic-price-forecasting.git)
cd probabilistic-price-forecasting

# Create a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install the required libraries
pip install -r requirements.txt
```

### 3. Run the Analysis
With your environment active, you can now run the analysis.
```bash
# Start Jupyter Notebook
jupyter notebook run_analysis.ipynb
```
This will open the notebook in your browser. You can run all cells to reproduce the figures and analysis tables.

## Key Findings

The analysis reveals a critical trade-off between statistical fairness and dynamic accuracy:

1.  **Statistical Fairness:** Only the **Bootstrap** and **Gaussian Copula** models perfectly replicated the original errors' non-Gaussian, fat-tailed distribution. The `Markov Chain` model, due to its "binning" method, produced a statistically flawed, artificial distribution.

2.  **Dynamic Plausibility:** Only the **Markov Chain** and **Gaussian Copula** models successfully captured the strong hour-to-hour autocorrelation (the "stickiness") of the price errors. The i.i.d. models (MC, LHS, Bootstrap) failed this test by design.

3.  **Final Accuracy (CRPS):** The `Markov Chain` model achieved the best (lowest) CRPS score, indicating it was the most accurate probabilistic forecast. The `Gaussian Copula` and `Bootstrap` models, despite being "fair," performed poorly on this metric.

**Conclusion:** For this problem, modeling the **temporal dynamics** (autocorrelation) was more critical for forecast accuracy than perfectly matching the static statistical distribution. The `Markov Chain`, despite its statistical flaws, provided the most accurate and useful scenarios for decision-making.

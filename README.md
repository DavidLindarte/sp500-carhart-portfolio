# S&P 500 factor portfolio: screening, Carhart four-factor model and QP optimisation

[![monthly-rerun](https://github.com/DavidLindarte/sp500-carhart-portfolio/actions/workflows/monthly-rerun.yml/badge.svg)](https://github.com/DavidLindarte/sp500-carhart-portfolio/actions/workflows/monthly-rerun.yml)

**Dashboard:** https://davidlindarte.github.io/sp500-carhart-portfolio/ · **Full notebook with outputs:** https://davidlindarte.github.io/sp500-carhart-portfolio/report.html

This project builds a long-only **US$10 million portfolio of S&P 500 stocks** for a client. Stocks are screened statistically, expected returns come from a **Carhart four-factor model**, and the portfolio is built by **quadratic optimisation** with sector caps. It is validated in a **quarterly walk-forward**: each quarter the whole pipeline is rebuilt using only the data available at that date, held to the next rebalance and compared with SPY. A scheduled job re-executes the notebook every month on fresh market data.

## Pipeline

1. **Universe and data:** S&P 500 constituents and GICS sectors, daily adjusted prices from Yahoo Finance (log returns), and Fama–French + momentum factors from the Ken French data library.
2. **Screening:** Lo (2002)-adjusted Sharpe-ratio significance, positive beta, and beta stability (Chow / Quandt–Andrews structural-break tests).
3. **Expected returns:** a Carhart regression per stock, with residual diagnostics (Breusch–Pagan, RESET, Jarque–Bera, Durbin–Watson), VIF checks and a ridge fallback. Compared against CAPM and FF3 using out-of-sample RMSE and Diebold–Mariano tests.
4. **Risk:** the sample covariance when the estimation window allows it, otherwise a factor-model covariance Ω = BΣ_FB′ + D.
5. **Construction:** QP (cvxpy): long-only, 25% sector cap, L1 penalty λ chosen by sensitivity analysis.
6. **Policy selection (Part A):** estimation window (1–5 years) and rebalance frequency (21 or 63 days) chosen on a separate two-year comparison period. Adopted: **3-year window, 63-day rebalancing**.
7. **Out-of-sample test (Part B):** quarterly walk-forward from 4 Sep 2025, re-screening at every rebalance and compounding the realised capital.
8. **Downside:** historical-simulation VaR at each construction date, backtested with the **Kupiec** proportion-of-failures test.

## Results (market data through 11 Sep 2026)

| Period | Stocks | Portfolio | SPY | Alpha |
|---|---|---|---|---|
| Q1 (Sep–Dec 2025) | 24 | −4.6% | +5.6% | −10.3% |
| Q2 (Dec 2025–Mar 2026) | 27 | +4.3% | −1.4% | +5.7% |
| Q3 (Mar–Jun 2026) | 17 | +18.2% | +10.0% | +8.3% |
| Q4 (Jun–Sep 2026) | 26 | +0.8% | +4.7% | −3.9% |
| **Cumulative (incl. hold to 11 Sep)** | | **+17.7%** | **+19.0%** | **−1.4%** |

- The strategy **made money (+17.7% on US$10M) but slightly trailed the S&P 500**. It beat SPY in 2 of the 4 full quarters, with high dispersion between them.
- **The VaR model is well calibrated:** 14 breaches in 252 days (5.56% vs 5% expected), Kupiec LR = 0.158, p = 0.69.
- The current target allocation (26 stocks, built 5 Jun 2026) is on the [dashboard](https://davidlindarte.github.io/sp500-carhart-portfolio/).

## Repository

```
notebooks/sp500_carhart_portfolio.ipynb   the full pipeline: data → screening → Carhart → covariance → QP → walk-forward → VaR
docs/index.html                            dashboard (reads docs/data/latest.json, written by the notebook's last cell)
docs/report.html                           static render of the executed notebook
.github/workflows/monthly-rerun.yml        papermill re-execution on fresh data + report render
```

```bash
pip install -r requirements.txt
papermill notebooks/sp500_carhart_portfolio.ipynb notebooks/sp500_carhart_portfolio.ipynb --cwd .
bash scripts/build_report.sh
```

## Limitations

- The universe comes from **today's** S&P 500 list, so the walk-forward carries some survivorship bias (a separate point-in-time check was done for 31 Aug 2025).
- Policy choices (model, λ, window) share one comparison period. A nested walk-forward would be the next level of rigour.
- Expected returns are daily regression point estimates scaled to one quarter, so they are noisy and should be read as rankings rather than promises.

## Credits

Group project for ECOM6003 Predictive Analytics in Business, MSc Predictive Analytics, Curtin University (2026). Built together by the project team.

*Educational project, not investment advice.*

---
**David Lindarte Burgos** · [Portfolio](https://davidlindarte.github.io)

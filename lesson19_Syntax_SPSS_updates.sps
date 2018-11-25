* Encoding: UTF-8.
* ============================================.
* LESSON 19 - Logistic Regression
*
* Melinda Higgins, PhD
* updated 11/25/2018
* ============================================.

* ============================================.
* For this lesson we'll use the helpmkh dataset
*
* Let's focus on homeless as the main outcome variable
* which is dichotomous coded 0 and 1. We'll use
* logistic regression to look at predicting whether someone
* was homeless or not using these variables
* age, gender, pss_fr, pcs, mcs, cesd and indtot
* ============================================.

* ============================================.
* let's look at the correlations between these variables
* ============================================.

CORRELATIONS
  /VARIABLES=homeless age female pss_fr pcs mcs cesd indtot
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.
NONPAR CORR
  /VARIABLES=homeless age female pss_fr pcs mcs cesd indtot
  /PRINT=SPEARMAN TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* ============================================.
* Given the stronger correlation between indtot
* and homeless, let's run a t-test to see the comparison
* ============================================.

T-TEST GROUPS=homeless(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=indtot
  /CRITERIA=CI(.95).

* ============================================.
* Let's run a logistic regression of indtot to predict
* the probability of being homeless
* we'll also SAVE the predicted probabilities
* and the predicted group membership
*
* NOTE: The current default threshold cutoff is 0.5.
* ============================================.

LOGISTIC REGRESSION VARIABLES homeless
  /METHOD=ENTER indtot 
  /SAVE=PRED PGROUP
  /PRINT=GOODFIT ITER(1) CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

* ============================================.
* plot the predicted probability of homeless
* against indtot to see the effect of indtot scores
* with the predicted probability
* ============================================.

GRAPH
  /SCATTERPLOT(BIVAR)=indtot WITH PRE_1
  /MISSING=LISTWISE.

* ============================================.
* let's look at some other threshold values
* and we'll compare the classification tables.
* ============================================.

LOGISTIC REGRESSION VARIABLES homeless
  /METHOD=ENTER indtot 
  /PRINT=GOODFIT ITER(1) CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.2).

LOGISTIC REGRESSION VARIABLES homeless
  /METHOD=ENTER indtot 
  /PRINT=GOODFIT ITER(1) CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.4).

LOGISTIC REGRESSION VARIABLES homeless
  /METHOD=ENTER indtot 
  /PRINT=GOODFIT ITER(1) CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.6).

LOGISTIC REGRESSION VARIABLES homeless
  /METHOD=ENTER indtot 
  /PRINT=GOODFIT ITER(1) CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.8).

* ============================================.
* another way to look at these tradeoofs is to run
* a ROC (receiver operating characteristic) curve
* let's look at one for indtot for homeless
* ============================================.

* UPDATE
* The code below shows the ROC curve for 1 continuous
* predictor for the outcome homeless (with an "event"
* defined as when homeless=1).

ROC indtot BY homeless (1)
  /PLOT=CURVE(REFERENCE)
  /PRINT=SE COORDINATES
  /CRITERIA=CUTOFF(INCLUDE) TESTPOS(LARGE) DISTRIBUTION(FREE) CI(95)
  /MISSING=EXCLUDE.

* UPDATE
* The code below shows the ROC curve for the
* model results captured by PRE_1
* for the outcome homeless (with an "event"
* defined as when homeless=1).
* This will give you the AUC (area under the curve)
* for the model (albeit with 1 predictor, indtot here).
* The AUC's match since there is only 1 
* continuous predictor for this model.

ROC PRE_1 BY homeless (1)
  /PLOT=CURVE(REFERENCE)
  /PRINT=SE COORDINATES
  /CRITERIA=CUTOFF(INCLUDE) TESTPOS(LARGE) DISTRIBUTION(FREE) CI(95)
  /MISSING=EXCLUDE.

* ============================================.
* sensitivity is the TRUE positive rate - numer of correctly 
* identified positive cases
* selectivity is the TRUE negative rate - numer of correctly
* identified negatives cases
*
* AUC = area under the curve is a measure of how well that
* predictor or model did for classifying the outcome correctly
* This model with just indtot in it only had an AUC = .644 which is poor
* AUC 0.7-0.8 is fair
* AUC 0.8-0.9 is good
* AUC 0.9-1 is very good to excellent
* ============================================.

* ============================================.
* Given the correlation matrix above, it looks like
* gender, pss_fr, pcs, and indtot are all significantly
* associated with being homeless
*
* if we want to put all of these together in a logistic regression
* model we should check the multicollinearity - run linear reg
* and look at multicollinearity stats
* ============================================.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT id
  /METHOD=ENTER female pss_fr pcs indtot.

* ============================================.
* the collinearity stats look good - lets put all of these together
* and run a multivariate logistic regression
* UPDATE add /SAVE=PRED PGROUP to save model fit results
* ============================================.

LOGISTIC REGRESSION VARIABLES homeless
  /METHOD=ENTER female pss_fr pcs indtot 
  /SAVE=PRED PGROUP
  /PRINT=GOODFIT ITER(1) CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

* UPDATE
* The code below shows the ROC curve for the
* model results captured by PRE_2
* for the outcome homeless (with an "event"
* defined as when homeless=1).
* This will give you the AUC (area under the curve)
* for the model (now with 4 predictors).

ROC PRE_2 BY homeless (1)
  /PLOT=CURVE(REFERENCE)
  /PRINT=SE COORDINATES
  /CRITERIA=CUTOFF(INCLUDE) TESTPOS(LARGE) DISTRIBUTION(FREE) CI(95)
  /MISSING=EXCLUDE.

* ============================================.
* not all are significant, let's run again using variable selection
* ============================================.

LOGISTIC REGRESSION VARIABLES homeless
  /METHOD=FSTEP(LR) female pss_fr pcs indtot 
  /PRINT=GOODFIT ITER(1) CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

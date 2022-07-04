Scentre
========================================================
author: Nima Ramezani
date: 6 June 2022
autosize: true

Introduction
========================================================
I just want to mention various methodologies, not to prescribe a specific solution for each question


Product Clustering
========================================================

<!-- For more details on authoring R presentations please visit <https://support.rstudio.com/hc/en-us/articles/200486468>. -->

Segmentation of products can be done based on various features coming from sources like:

- Product name/Description
- Department Hierarchy of Classification
- Location in the store (Like Asile Number)
- Product-Specific features (Like Price or per-unit-price)

- History of customer's behaviour (Amount and Frequency of purchases)

Two questions
========================================================

## How much does this product belong to a specific category (like Health for example?)

- Supervised Learning 
  - Binary Classification
  - Metric Ranking

## Which Category does each product belong to?
- We don't know categories, tell us what categories can be?
  - Non-supervised learning
    - K-Means Clustering
    - Metric-based Clustering

- We know which categories we are looking for
  - Multi-class Classification (labels are required)

Challenges for non-supervised learning
========================================================

## How to quantify goodness of clustering? What is a good groupiong?

Challenges for supervised learning
========================================================
- Label is required


Hybrid Method with manual labelling
========================================================
## Have resources do some manual labelling.

- Do a metric-based clustering first
- Tag each cluster with a name reflecting it's properties by looking at the items closer the center of each cluster which are the most relevant. 

For example: Healthy, No time to cook, or ....

- Build label for supervised-learning:
  - Pick top n items from each cluster with manual verification: Is this really a healthy product
  - Pick some items with a specific term in their name. For example: Are all products with term "Organic" in their name "healthy" products? 

Hybrid Method without label
========================================================
## A Hybrid Method: Have not resources for manual labelling.

Three metric groups:

- NLP Metrics
- Customer Behaviour Metrics (Purchase history)
- Existing Department Hierarchy

1 - Do a metric-learning to obtain weights for the metrics of one metric group trained by metrics of another group
Examples:
  * - For example give weights for each word in the name/description of products to reflect department category hierarchy
  (i.e Terms reflecting the product type like Yogourt, Cheese, sause may get higher weight)
  
  * - Give weight to various customer behavioral features to reflect NLP metrics
  For example, What is the weight of "customer purchase rate similarity" in regressing "NLP binary metric"?

  * - For example give weights for each word in the name/description of products to reflect similarity in customer behaviour
  (i.e Which words reflect co-purchase with another product)




## Introduction

- I just want to mention various methodologies, 
  (not to prescribe a specific solution for each question).

- Best solution can be picked after discussing with other data scientists in the team

- Next steps depends on the outcomes we get from each steps

## Product Clustering

Segmentation of products can be done based on various features coming from sources like:

- Product name/Description
- Department Hierarchy of Classification
- Location in the store (Like Asile Number)
- Product-Specific features (Like Price or per-unit-price)

- History of customer's behaviour (Amount and Frequency of purchases)

## Category Membership Ranking
How much does each product belong to a specific category (like Health for example?)

- Supervised Learning 

  * Binary Classification
  * Metric Ranking
  * Metric Regression (Metric Learning)

- Label is required

  Are there some product groups we are confident they belong to a category?

## Product Grouping  

Which Category does each product belong to?

### We don't know categories, tell us what categories can be?

  - Non-supervised learning
  
    * K-Means Clustering
    * Metric-based Clustering

### We know which categories we are looking for
  
  Multi-class Classification (labels are required)


## Slide with Plot


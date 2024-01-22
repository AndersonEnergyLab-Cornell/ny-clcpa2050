from sklearn.datasets import load_iris
from sklearn.tree import DecisionTreeRegressor,DecisionTreeClassifier, plot_tree
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from sklearn.metrics import r2_score
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import OneHotEncoder
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
import statsmodels.api as sm
import seaborn as sns
# load the iris dataset

feature = pd.read_csv('SolarS0_300_v2/DUfeature_lg.csv')
feature = feature.drop('Unnamed: 0',axis = 1)
# feature = feature.drop('QM',axis = 1)
print(feature)
allobj = np.empty((0,5))
for year in range(1998,2020):
    rdm_factors = np.loadtxt('SolarS0_300_v2/objs_'+str(year)+'.csv', delimiter= ',')
    results = rdm_factors[:,10:]
    allobj = np.vstack([allobj,results])
allobj = pd.DataFrame(allobj,columns=['lsq', 'lsf', 'lsm','rc','en'])
allobj['lsm_c'] = allobj['lsm'] >= 17722*1.2
allobj['lsq_c'] = allobj['lsq'] >= 4.139e+06
allobj['lsf_c'] = allobj['lsf'] >= 1200
ALL = np.vstack((allobj['lsq_c'].values, allobj['lsf_c'].values)).all(axis=0)


# lsm = allobj['lsm_c'].to_numpy()

# lsm = np.reshape(lsm,(22,300))
# fig, ax = plt.subplots()
# im = ax.imshow(lsm, cmap='coolwarm')
# cbar = ax.figure.colorbar(im, ax=ax)

# # Add title and axis labels
# ax.set_title("Heatmap of Load Shedding Frequency")
# ax.set_xlabel("Week of the year")
# ax.set_ylabel("Year")

# # Add legend
# cbar.ax.set_ylabel("Colorbar Label", rotation=-90, va="bottom")

# # Display heatmap
# plt.show()

obj = allobj['lsf_c']
# fit a decision tree classifier

# # create an instance of the one-hot encoder
# ohe = OneHotEncoder()

# # fit and transform the categorical column 'color'
# season_ohe = ohe.fit_transform(feature[['season']])

# # create a new dataframe with the one-hot encoded columns
# season_df = pd.DataFrame(season_ohe.toarray(), columns=ohe.get_feature_names(['season']))

# # concatenate the one-hot encoded dataframe with the original dataframe
# df_encoded = pd.concat([feature.drop('season',axis = 1), season_df], axis=1)

X_train, X_test, y_train, y_test = train_test_split(feature, obj, test_size=0.2, random_state=42)

logreg = LogisticRegression(max_iter=100, fit_intercept=True,solver='newton-cg', penalty='none')
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
corr_matrix = np.corrcoef(X_train_scaled.T)

# print(corr_matrix)
# sns.heatmap(corr_matrix, cmap='coolwarm', annot=True, fmt='.2f')
# plt.title('Correlation matrix')
# plt.show()

# np.savetxt('corelation.csv',corr_matrix,delimiter= ',')


logreg.fit(X_train_scaled, y_train)
importance_scores = np.exp(logreg.coef_[0])
df_coef = pd.DataFrame(columns = feature.columns)

df_coef.loc[len(df_coef)] = importance_scores
print(df_coef)
X_test_scaled = scaler.transform(X_test)
y_pred = logreg.predict(X_test_scaled)
# # calculate the R-squared value
accuracy = accuracy_score(y_test, y_pred)
print('Accuracy:', accuracy)




# print(importance_scores)
# print(feature.columns)
logreg2 = sm.Logit(y_train, sm.add_constant(X_train_scaled),maxiter=100,method="ncg").fit()
pvals = logreg2.pvalues[1:]

odds_ratios = pd.DataFrame(
    {
        "OR": logreg2.params,
        "Lower CI": logreg2.conf_int()[0],
        "Upper CI": logreg2.conf_int()[1],
    }
)
odds_ratios = np.exp(odds_ratios)

print(odds_ratios)
# print significant predictors (assuming alpha = 0.05)
sig_preds = pvals[pvals < 0.005].index.tolist()
df_coef.loc[len(df_coef)] = pvals.values
print(logreg2.summary())
print('Significant predictors:', sig_preds)
print(df_coef)
df_coef.to_csv('SolarS0_300_v2/lg_lsf.csv')
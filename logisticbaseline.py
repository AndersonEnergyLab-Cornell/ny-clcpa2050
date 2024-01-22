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


feature = pd.read_csv('Baselinefeature_lg.csv')
feature = feature.drop('Unnamed: 0',axis = 1)
feature = feature.drop('QM',axis = 1)
# print(feature)
# print(feature.columns)
objs = pd.read_csv('Baseline_v3/objsqm_'+str(6)+'.csv')
objs['lsm_c'] = objs['lsm'] >= 17722
# objs['lsq_c'] = objs['lsq'] >= 80881+172939
objs['lsq_c'] = objs['lsq'] >= 208000
objs['lsf_c'] = objs['lsf'] >= 100
lsm = objs['lsm_c'].to_numpy()

lsm = np.reshape(lsm,(22,48))

# fig, ax = plt.subplots()
# im = ax.imshow(lsm, cmap='coolwarm')
# cbar = ax.figure.colorbar(im, ax=ax)

# # Add title and axis labels
# ax.set_title("Heatmap of Maximum Load Shedding")
# ax.set_xlabel("Week of the year")
# ax.set_ylabel("Year")

# # Add legend
# cbar.ax.set_ylabel("Colorbar Label", rotation=-90, va="bottom")

# # Display heatmap
# plt.show()


ALL = np.vstack((objs['lsq_c'].values, objs['lsf_c'].values)).all(axis=0)
obj = objs['lsm_c']
print(obj.sum())
# fit a decision tree classifier

# create an instance of the one-hot encoder
ohe = OneHotEncoder()

# fit and transform the categorical column 'color'
season_ohe = ohe.fit_transform(feature[['season']])

# create a new dataframe with the one-hot encoded columns
season_df = pd.DataFrame(season_ohe.toarray(), columns=ohe.get_feature_names(['season']))

# concatenate the one-hot encoded dataframe with the original dataframe
df_encoded = pd.concat([feature.drop('season',axis = 1), season_df], axis=1)
df_encoded['obj'] = obj
df_encoded = df_encoded[df_encoded['season_summer']==0]
df_encoded = df_encoded.drop(['season_summer','season_winter'],axis = 1)
# print(df_encoded)
# df_encoded = feature.drop('season',axis = 1)
X_train, X_test, y_train, y_test = train_test_split(df_encoded.drop('obj',axis = 1), df_encoded['obj'], test_size=0.2, random_state=42)
df_encoded = df_encoded.drop('obj',axis = 1)
np.random.seed(42)
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
df_coef = pd.DataFrame(columns = df_encoded.columns)

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
df_coef.loc[len(df_coef)] = odds_ratios['Lower CI'].values[1:]
df_coef.loc[len(df_coef)] = odds_ratios['Upper CI'].values[1:]
print(odds_ratios)
# print significant predictors (assuming alpha = 0.05)
sig_preds = pvals[pvals < 0.05].index.tolist()
df_coef.loc[len(df_coef)] = pvals.values
print(logreg2.summary())
print('Significant predictors:', sig_preds)
print(df_coef)
df_coef.to_csv('Baseline_v4/lg_lsm_winter.csv')
'''
reg = DecisionTreeClassifier(random_state=0,criterion = 'entropy')
reg.fit(X_train, y_train)

y_pred = reg.predict(X_test)

# # calculate the R-squared value
accuracy = accuracy_score(y_test, y_pred)
print('Accuracy:', accuracy)

reg = DecisionTreeClassifier(random_state=0,criterion = 'entropy')
reg.fit(df_encoded, obj)

leaf_node = reg.apply(df_encoded)

# Get the indices of the samples in each leaf
leaf_samples = {}
for i, node in enumerate(leaf_node):
    if node not in leaf_samples:
        leaf_samples[node] = []
    leaf_samples[node].append(i)

# Print the indices of the samples in each leaf
for node, samples in leaf_samples.items():
    print(f"Leaf {node}: {samples}")

# plot the decision tree
plt.figure(figsize=(20, 10))
plot_tree(reg, feature_names=df_encoded.columns, class_names=np.array(['False','True']), filled=True)
plt.show()
# plt.savefig('Baseline_v2/DT_lsq5.png')

# plt.figure(figsize=(20, 10))
# plot_tree(reg, feature_names=feature.columns, filled=True)
# plt.show()

# plt.scatter(feature['Humid_min_D'],feature['Hydro'])
# plt.show()
'''
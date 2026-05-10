from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.feature_extraction.text import TfidfVectorizer


class CombinedExtractor(BaseEstimator, TransformerMixin):

    def __init__(self):
        self.tfidf = TfidfVectorizer(
            ngram_range=(1,3),
            max_features=5000,
            stop_words="english"
        )

        self.hand_cols = [
            "neg_kw","pos_kw","help_kw","negations",
            "intensifiers","first_person","word_count",
            "sent_ratio","neg_pos_diff"
        ]

    def fit(self, X, y=None):
        self.tfidf.fit(X["clean"])
        return self

    def transform(self, X):

        from scipy.sparse import hstack, csr_matrix

        T = self.tfidf.transform(X["clean"])
        E = csr_matrix((X["epds_score"].values / 30.0).reshape(-1,1))
        H = csr_matrix(X[self.hand_cols].values.astype(float))

        return hstack([T, E, H])
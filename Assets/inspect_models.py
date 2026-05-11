import joblib
import os

try:
    extractor = joblib.load('extractor.pkl')
    print(f"Extractor type: {type(extractor)}")
    print(f"Extractor attributes: {dir(extractor)}")
    
    if hasattr(extractor, 'tfidf'):
        print(f"Found tfidf attribute. Vocab size: {len(extractor.tfidf.vocabulary_)}")
    else:
        # Check if extractor itself is the vectorizer
        if hasattr(extractor, 'vocabulary_'):
            print(f"Extractor seems to be the vectorizer. Vocab size: {len(extractor.vocabulary_)}")
        else:
            print("Could not find vocabulary in extractor.")

    model = joblib.load('model.pkl')
    print(f"Model type: {type(model)}")
    if hasattr(model, 'n_features_in_'):
        print(f"Model input features: {model.n_features_in_}")
    
except Exception as e:
    print(f"Error: {e}")

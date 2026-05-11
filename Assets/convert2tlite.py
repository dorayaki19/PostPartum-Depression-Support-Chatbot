import joblib
import json
import onnx
import tensorflow as tf
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType
import os
import shutil
import subprocess

def convert():
    # --- 1. Exporting the Vocabulary (JSON) ---
    print("Step 1: Exporting vocabulary...")
    try:
        extractor = joblib.load('extractor.pkl')
        
        # Handle different possible structures of extractor
        if hasattr(extractor, 'tfidf'):
            tfidf = extractor.tfidf
        else:
            tfidf = extractor
            
        vocab = tfidf.vocabulary_
        
        with open('vocabulary.json', 'w') as f:
            json.dump(vocab, f)
        print(f"✅ Exported {len(vocab)} words to vocabulary.json")
    except Exception as e:
        print(f"❌ Error in Step 1: {e}")
        return

    # --- 2. Converting the Classifier (model.pkl) to ONNX ---
    print("\nStep 2: Converting Scikit-Learn model to ONNX...")
    try:
        model = joblib.load('model.pkl')

        # Determine number of input features
        num_features = 5009
        if hasattr(model, 'n_features_in_'):
            num_features = model.n_features_in_
            print(f"Detected model input features: {num_features}")
        else:
            print(f"Using default feature count: {num_features}")

        initial_type = [('float_input', FloatTensorType([None, num_features]))]
        onnx_model = convert_sklearn(model, initial_types=initial_type)

        with open("model.onnx", "wb") as f:
            f.write(onnx_model.SerializeToString())
        print("✅ Generated model.onnx")
    except Exception as e:
        print(f"❌ Error in Step 2: {e}")
        return

    # --- 3. Converting ONNX to TFLite (using onnx2tf) ---
    print("\nStep 3: Converting ONNX to TFLite...")
    try:
        if os.path.exists("model_tflite"):
            shutil.rmtree("model_tflite")
            
        # Run onnx2tf
        # -nos : skip output shape inference (sometimes helps)
        # -o : output directory
        print("Running onnx2tf... this may take a moment.")
        result = subprocess.run(
            ["onnx2tf", "-i", "model.onnx", "-o", "model_tflite"],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            print(f"❌ onnx2tf failed: {result.stderr}")
            # Try without optimization if it fails
            return
        
        # The generated tflite file is usually named model_float32.tflite inside the output dir
        tflite_source = os.path.join("model_tflite", "model_float32.tflite")
        if os.path.exists(tflite_source):
            shutil.copy(tflite_source, "model.tflite")
            print("✅ model.tflite successfully generated.")
        else:
            # Look for any .tflite file in the directory
            found = False
            for root, dirs, files in os.walk("model_tflite"):
                for file in files:
                    if file.endswith(".tflite"):
                        shutil.copy(os.path.join(root, file), "model.tflite")
                        print(f"✅ model.tflite successfully generated (from {file}).")
                        found = True
                        break
                if found: break
            
            if not found:
                print("❌ Could not find generated .tflite file in model_tflite directory.")
                return

    except Exception as e:
        print(f"❌ Error in Step 3: {e}")
        return

    # Cleanup
    print("\nStep 4: Cleaning up temporary files...")
    try:
        if os.path.exists("model.onnx"):
            os.remove("model.onnx")
        if os.path.exists("model_tflite"):
            shutil.rmtree("model_tflite")
        print("✅ Cleanup complete.")
    except Exception as e:
        print(f"⚠️ Cleanup error: {e}")

if __name__ == "__main__":
    convert()

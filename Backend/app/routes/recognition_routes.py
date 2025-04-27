from fastapi import APIRouter, HTTPException, Request, Depends
from pydantic import BaseModel
import numpy as np
import cv2
import base64
import tensorflow as tf
from pathlib import Path
import os

router = APIRouter()

# Global variable to store the model
model = None

class ImageRequest(BaseModel):
    image: str

@router.on_event("startup")
async def load_model():
    global model
    try:
        model_path = Path("models/model.h5")
        if not model_path.exists():
            raise FileNotFoundError(f"Model file not found at {model_path}")
        
        model = tf.keras.models.load_model(str(model_path))
        print("✅ Model loaded successfully!")
        print(model.summary())
    except Exception as e:
        print(f"❌ Failed to load model: {e}")
        model = None

@router.get("/model-status")
async def model_status():
    global model
    is_loaded = model is not None
    print(f"Model status requested: {'Loaded' if is_loaded else 'Not loaded'}")
    return {"model_loaded": is_loaded}

@router.post("/predict-base64")
async def predict_from_base64(request: ImageRequest):
    global model
    if model is None:
        try:
            model_path = Path("models/model.h5")
            model = tf.keras.models.load_model(str(model_path))
            print("✅ Model loaded successfully!")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Model not loaded: {str(e)}")
    
    try:
        # Decode base64 image
        img_data = base64.b64decode(request.image)
        
        # Convert to numpy array
        nparr = np.frombuffer(img_data, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        # Preprocess the image
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = cv2.resize(img, (224, 224))  # Resize to match model input size
        img = img / 255.0  # Normalize
        
        # Add batch dimension
        img = np.expand_dims(img, axis=0)
        
        # Make prediction
        prediction = model.predict(img)
        
        # Get the highest probability class
        predicted_class_index = np.argmax(prediction[0])
        confidence = float(prediction[0][predicted_class_index])
        
        # Map index to letter (assuming ASL alphabet A-Z)
        letters = "abcdefghijklmnopqrstuvwxyz"
        if 0 <= predicted_class_index < len(letters):
            letter = letters[predicted_class_index]
        else:
            letter = "unknown"
        
        return {"letter": letter, "confidence": confidence}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

@router.post("/predict-file")
async def predict_from_file(request: Request):
    global model
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    try:
        form = await request.form()
        contents = await form["file"].read()
        
        # Convert to numpy array
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        # Preprocess the image
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = cv2.resize(img, (224, 224))
        img = img / 255.0
        
        # Add batch dimension
        img = np.expand_dims(img, axis=0)
        
        # Make prediction
        prediction = model.predict(img)
        
        # Get the highest probability class
        predicted_class_index = np.argmax(prediction[0])
        confidence = float(prediction[0][predicted_class_index])
        
        # Map index to letter (assuming ASL alphabet A-Z)
        letters = "abcdefghijklmnopqrstuvwxyz"
        if 0 <= predicted_class_index < len(letters):
            letter = letters[predicted_class_index]
        else:
            letter = "unknown"
        
        return {"letter": letter, "confidence": confidence}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")
import cv2
import numpy as np
from keras.models import load_model
from PIL import Image
from flask import Flask, request, jsonify
from flask_cors import CORS
import io
import datetime

# Initialize the Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Load the pre-trained model
model = load_model('BrainTumor50EpochsCategorical3.h5')

# Define a helper function to log user information
def log_user_prediction(username, tumor_detected):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open("user_logs.txt", "a") as log_file:
        log_file.write(f"{timestamp}, {username}, Tumor Detected: {tumor_detected}\n")

# Define the prediction route
@app.route('/predict', methods=['POST'])
def predict():
    # Check if an image file was uploaded
    if 'image' not in request.files or 'username' not in request.form:
        return jsonify({"error": "No image file or username provided"}), 400

    # Get the uploaded image file and username
    file = request.files['image']
    username = request.form['username']
    img = Image.open(io.BytesIO(file.read())).convert('RGB')
    img = img.resize((224, 224))

    # Preprocess the image
    img_array = np.array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)  # Add batch dimension

    # Perform prediction
    prediction = model.predict(img_array)
    tumor_detected = bool(prediction[0][1] > prediction[0][0])

    # Log the prediction result with the username
    log_user_prediction(username, tumor_detected)

    # Send response
    return jsonify({
        "prediction": prediction.tolist(),
        "tumor_detected": tumor_detected
    })

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

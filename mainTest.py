import cv2
from keras.models import load_model
from PIL import Image
import numpy as np

# Load the model
model = load_model('BrainTumor50EpochsCategorical.h5')

# Load the image
image_path = "C:\\Users\\koush\\Downloads\\brain_dataset\\Training\\pituitary_tumor\\p (10).jpg"
image = cv2.imread(image_path)

# Check if the image was loaded successfully
if image is None:
    raise ValueError("Could not load the image. Please check the file path.")

# Convert to RGB format and resize to model's expected input size
img = Image.fromarray(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))  # Convert BGR (OpenCV) to RGB
img = img.resize((224, 224))  # Resize to the model's input size

# Convert image to a NumPy array, normalize, and add batch dimension
img_array = np.array(img) / 255.0
img_array = np.expand_dims(img_array, axis=0)  # Add batch dimension

# Predict
prediction = model.predict(img_array)

# Output the result
print("Prediction:", prediction)
print("Tumor detected" if prediction[0][1] > prediction[0][0] else "No tumor detected")

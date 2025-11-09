# Use the official Python image as a base image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# ✅ Install system dependencies for OpenCV and DeepFace
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# ✅ Expose the correct port (5000)
EXPOSE 5000

# ✅ Match the port with docker-compose
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5000"]

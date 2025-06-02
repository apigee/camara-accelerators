# Use an official Python runtime as a parent image
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the local code to the container image
COPY . .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Define environment variable
ENV PORT 8080

# Expose the port
EXPOSE 8080

# Run app.py when the container launches using gunicorn
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 app:app
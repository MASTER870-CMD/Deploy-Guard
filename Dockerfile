# Use official lightweight Python image (3.12 slim)
FROM python:3.12-slim

# Set environment variables for safety and performance
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create a non-root user and group with a fixed UID/GID
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN addgroup --gid $GROUP_ID appuser && \
    adduser --uid $USER_ID --gid $GROUP_ID --disabled-password --gecos "" appuser

# Set working directory
WORKDIR /app

# Install build dependencies (if any) – minimal for this app
# Copy only requirements first to leverage Docker cache
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code and set ownership
COPY . /app
RUN chown -R appuser:appuser /app

# Expose the Flask port
EXPOSE 5000

# Switch to non-root user
USER appuser

# Command to run the app with Gunicorn, binding to 0.0.0.0:5000
# Using 4 workers (adjust as needed) and 2 threads per worker
CMD ["sh", "-c", "gunicorn 'app.main:create_app()' --bind 0.0.0.0:${PORT:-5000} --workers 2 --threads 2"]


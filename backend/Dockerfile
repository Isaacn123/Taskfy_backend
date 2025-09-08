FROM python:3.11

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && apt-get clean

COPY requirements.txt ./

RUN pip install -r requirements.txt

COPY . . 

# For development with auto-reload
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002", "--reload"]

# For production (uncomment the line below and comment the line above)
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
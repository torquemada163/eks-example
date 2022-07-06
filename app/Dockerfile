FROM python:3.6
RUN pip install flask uwsgi
WORKDIR /app
COPY app.py /app/
CMD ["uwsgi", "--http", "0.0.0.0:80", "--wsgi-file", "/app/app.py", "--callable", "app"]


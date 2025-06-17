FROM python:3.9-alpine3.13

LABEL maintainer="vistocos"

ENV PYTHONUNBUFFERED=1

COPY ./requirements.txt  /tmp/requirements.txt
COPY ./requirements.dev.txt  /tmp/requirements.dev.txt
COPY ./scripts /scripts

COPY ./app /app

WORKDIR /app

EXPOSE 8000

#note this is a default value, on the compose file
ARG DEV=false

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \

    # to use postgress database (NOTE: check whether the simpler options provide for IA works)
    # jpeg-dev zlib zlib-dev are for Pillow version used
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev linux-headers  && \

    # END to use postgress database

    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \ 
    # another line added to use prostgress
    apk del .tmp-build-deps && \
    # END another line added to use prostgress
    adduser \ 
    --disabled-password \ 
    --no-create-home \
    django-user && \
    # /vol/web/media is the folder for the media, /vol/web/media is the folder for the static 
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts

# ENV PATH="/py/bin:$PATH"
ENV PATH="/scripts:/py/bin:$PATH"

USER django-user

CMD ["run.sh"]
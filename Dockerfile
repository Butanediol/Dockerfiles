FROM alpine AS cloner

WORKDIR /notionai
RUN apk add git
RUN git clone https://github.com/Vaayne/NotionAI . --depth 1

FROM python:3

COPY --from=cloner /notionai /notionai
WORKDIR /notionai/examples/webui
RUN pip install -r requirements.txt
COPY app.py /notionai/examples/webui/

EXPOSE 7860
ENV NOTION_TOKEN=
ENV NOTION_SPACE_ID=
CMD ["python", "app.py"]
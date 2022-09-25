FROM python:3.7-bullseye

WORKDIR /root

COPY example.mp3 example.py ./

RUN apt-get update && \
	apt-get install -y libsndfile1-dev ffmpeg && \
	pip install piano_transcription_inference torch && \
	python example.py --audio_path='example.mp3' --output_midi_path='example.mid' && \
	rm example.mp3 example.mid

VOLUME [ "/root/resources" ]

CMD [ "sh -c python example.py --audio_path='$AUDIO_NAME' --output_midi_path='$MIDI_NAME'" ]
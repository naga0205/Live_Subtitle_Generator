from moviepy.editor import *
from pydub import AudioSegment
import numpy as np
import librosa
import IPython.display as ipd
import tensorflow as tf
from tensorflow import keras
# specify input and output file paths
model = keras.models.load_model('SpeechRecogModel.h5')
def predict(audio):
    prob=model.predict(audio.reshape(1,8000,1))
    index=np.argmax(prob[0])
    return classes[index]
# input_file = "video.mp4"

# # load MP4 audio using moviepy
# audio = AudioFileClip(input_file)

audio = AudioSegment.from_file("Ps.m4a",format="m4a")
audio.export("output.wav", format="wav")
output_file = "output.wav"
classes=['down', 'go', 'left', 'no', 'off', 'on', 'right', 'stop', 'up', 'yes']
# extract audio and convert to WAV format using pydub
# audio.write_audiofile(output_file)
audio_file=output_file
samples, sample_rate = librosa.load(audio_file,sr=8000)
# target_length = 8000
# samples = samples[:target_length]
print(predict(samples[:8000]))

# print(predict(samples))
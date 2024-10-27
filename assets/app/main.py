import json
import re
from flask import Flask, request, jsonify
from transformers import pipeline, TrOCRProcessor, VisionEncoderDecoderModel
from happytransformer import HappyTextToText, TTSettings
import easyocr
import numpy as np
import cv2

app = Flask(__name__)
port = 5000


def clean_text(text):
    return re.sub(r'[.!?]+$', '', text)


@app.route('/summary', methods=['POST'])
def summary():
    data = request.get_json()
    pipe = pipeline("summarization", model="facebook/bart-large-cnn")

    if 'min' not in data:
        return jsonify({'error': 'Minimum Length not provided'}), 400
    if 'max' not in data:
        return jsonify({'error': 'Maximum Length not provided'}), 400
    if 'text' not in data:
        return jsonify({'error': 'Text not provided'}), 400

    long_text = data['text']
    minlength = data['min']
    maxlength = data['max']

    try:
        summarydata = pipe(long_text, min_length=minlength, max_length=maxlength, do_sample=False)
        return jsonify({'summary': summarydata[0]['summary_text']})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/grammar', methods=['POST'])
def grammar():
    data = request.get_json()
    happy_tt = HappyTextToText("T5", "vennify/t5-base-grammar-correction")
    args = TTSettings(num_beams=5, min_length=1)

    if 'text' not in data:
        return jsonify({'error': 'Text not provided'}), 400

    long_text = data['text']

    try:
        result = happy_tt.generate_text("grammar : " + long_text)
        return jsonify({'text': clean_text(result.text)})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/ocrtyped', methods=['POST'])
def ocrtyped():
    if 'image' not in request.files:
        return {'error': 'No image part in request'}, 400
    if 'languages' not in request.form:
        return {'error': 'No languages part in request'}, 400

    file = request.files['image']
    if file.filename == '':
        return {'error': 'No selected File'}, 400

    str_rs = ""
    languages = json.loads(request.form['languages'])

    try:
        file_bytes = np.frombuffer(file.read(), np.uint8)
        image_rec = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)
        reader = easyocr.Reader(lang_list=languages, gpu=True, model_storage_directory="./.easyocr/model/")
        result = reader.readtext(image=image_rec)
        for i in result:
            str_rs += (i[1] + " ")
        return jsonify({'text': str_rs}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/ocrhand', methods=['POST'])
def ocrhand():
    if 'image' not in request.files:
        return {'error': 'No image part in request'}, 400
    if 'type' not in request.form:
        return {'error': 'NO type part in request'}, 400

    text = ""
    file = request.files['image']
    if file.filename == '':
        return {'error': 'No selected File'}, 400

    typeocr = request.form.get('type')
    if typeocr == "MethodDt.dilated":
        kheight = int(request.form.get('kHeight'))
        kwidth = int(request.form.get('kWidth'))
        overlap = int(request.form.get('overlap'))
        minheight = int(request.form.get('minHeight'))

        try:
            file_bytes = np.frombuffer(file.read(), np.uint8)
            image = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

            _, binary_image = cv2.threshold(gray, 128, 255, cv2.THRESH_BINARY_INV)

            kernel = np.ones((kheight, kwidth), np.uint8)
            dilated = cv2.dilate(binary_image, kernel, iterations=1)

            contours, _ = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

            contours = sorted(contours, key=lambda c: cv2.boundingRect(c)[1])

            processor = TrOCRProcessor.from_pretrained('microsoft/trocr-large-handwritten')
            model = VisionEncoderDecoderModel.from_pretrained('microsoft/trocr-large-handwritten')

            for i, contour in enumerate(contours):
                x, y, w, h = cv2.boundingRect(contour)
                if h >= minheight:
                    y_start = max(0, y - overlap)
                    y_end = min(gray.shape[0], y + h + overlap)

                    cropped_image = image[y_start:y_end, :]

                    if np.mean(cropped_image) < 252.5:
                        pixel_values = processor(images=cropped_image, return_tensors="pt").pixel_values

                        generated_ids = model.generate(pixel_values)
                        generated_text = processor.batch_decode(generated_ids, skip_special_tokens=True)[0]

                        text = text + '\n' + generated_text
            return jsonify({'text': text}), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(port=port)

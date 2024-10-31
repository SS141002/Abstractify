import json
import re
import torch
import easyocr
import numpy as np
import cv2
from flask import Flask, request, jsonify
from transformers import TrOCRProcessor, VisionEncoderDecoderModel
from transformers import BartTokenizer, BartForConditionalGeneration
from happytransformer import HappyTextToText, TTSettings

app = Flask(__name__)
port = 5000


def clean_text(text):
    return re.sub(r'[.!?]+$', '', text)


@app.route('/summary', methods=['POST'])
def summary():
    data = request.get_json()
    if 'min' not in data:
        return jsonify({'error': 'Minimum Length not provided'}), 400
    if 'max' not in data:
        return jsonify({'error': 'Maximum Length not provided'}), 400
    if 'text' not in data:
        return jsonify({'error': 'Text not provided'}), 400

    long_text = data['text']
    minlength = data['min']
    maxlength = data['max']

    save_dir = "./models/bart/"
    tokenizer = BartTokenizer.from_pretrained(save_dir)
    model = BartForConditionalGeneration.from_pretrained(save_dir)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = model.to(device)

    try:
        inputs = tokenizer(long_text, max_length=2048, return_tensors="pt", truncation=True)
        inputs = {key: value.to(device) for key, value in inputs.items()}

        summary_ids = model.generate(inputs["input_ids"], max_length=maxlength, min_length=minlength,
                                     length_penalty=2.0, num_beams=4, early_stopping=True)
        summary_text = tokenizer.decode(summary_ids[0], skip_special_tokens=True)
        return jsonify({'summary': summary_text})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/grammar', methods=['POST'])
def grammar():
    data = request.get_json()
    happy_tt = HappyTextToText("T5", "./models/t5/")
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
        reader = easyocr.Reader(lang_list=languages, gpu=True, model_storage_directory="./models/easyocr/")
        result = reader.readtext(image=image_rec)
        for i in result:
            str_rs += (i[1] + " ")
        return jsonify({'text': str_rs}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/ocrhand', methods=['POST'])
def ocrhand():
    fields = ['type', 'kHeight', 'kWidth', 'overlapUp', 'overlapDn', 'minHeight', 'minWhite', 'maxWhite']
    if 'image' not in request.files:
        return {'error': 'No image part in request'}, 400

    for field in fields:
        if field not in request.form:
            return {'error': f'no {field} part in request'}, 400

    text = ""
    file = request.files['image']

    if file.filename == '':
        return {'error': 'No selected File'}, 400

    typeocr = request.form.get('type')
    overlapup = int(request.form.get('overlapUp'))
    minheight = int(request.form.get('minHeight'))

    save_dir = "./models/trocr/"
    processor = TrOCRProcessor.from_pretrained(save_dir)
    model = VisionEncoderDecoderModel.from_pretrained(save_dir)

    file_bytes = np.frombuffer(file.read(), np.uint8)
    image = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    if typeocr == "MethodDt.dilated":
        kheight = int(request.form.get('kHeight'))
        kwidth = int(request.form.get('kWidth'))

        try:
            _, binary_image = cv2.threshold(gray, 128, 255, cv2.THRESH_BINARY_INV)
            kernel = np.ones((kheight, kwidth), np.uint8)
            dilated = cv2.dilate(binary_image, kernel, iterations=1)
            contours, _ = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            contours = sorted(contours, key=lambda c: cv2.boundingRect(c)[1])

            for i, contour in enumerate(contours):
                x, y, w, h = cv2.boundingRect(contour)

                if h >= minheight:
                    y_start = max(0, y - overlapup)
                    y_end = min(gray.shape[0], y + h + overlapup)
                    cropped_image = image[y_start:y_end, :]

                    if np.mean(cropped_image) < 252.5:
                        pixel_values = processor(images=cropped_image, return_tensors="pt").pixel_values
                        generated_ids = model.generate(pixel_values)
                        generated_text = processor.batch_decode(generated_ids, skip_special_tokens=True)[0]
                        text = text + '\n' + generated_text

            return jsonify({'text': text}), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    else:
        minwhite = int(request.form.get('minWhite'))
        maxwhite = int(request.form.get('maxWhite'))
        overlapdn = int(request.form.get('overlapDn'))

        try:
            binary = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 11, 2)
            horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (image.shape[1] // 20, 1))
            detect_lines = cv2.morphologyEx(binary, cv2.MORPH_OPEN, horizontal_kernel, iterations=2)
            contours, _ = cv2.findContours(detect_lines, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            contours = sorted(contours, key=lambda ctr: cv2.boundingRect(ctr)[1])
            line_boundaries = [cv2.boundingRect(contour)[1] for contour in contours]

            if len(line_boundaries) < 2:
                return jsonify({'error': "Not enough lines detected to split the image"}), 500

            for idx in range(len(line_boundaries) - 1):
                y_top = line_boundaries[idx] - overlapup
                y_bottom = line_boundaries[idx + 1] + overlapdn

                if y_bottom - y_top > minheight:
                    line_image = image[y_top:y_bottom, :]

                    if minwhite < np.mean(line_image) < maxwhite:
                        pixel_values = processor(images=line_image, return_tensors="pt").pixel_values
                        generated_ids = model.generate(pixel_values)
                        generated_text = processor.batch_decode(generated_ids, skip_special_tokens=True)[0]
                        text = text + '\n' + generated_text

            return jsonify({'text': text}), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(port=port)

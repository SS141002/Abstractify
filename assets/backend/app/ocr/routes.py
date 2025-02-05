from flask import Blueprint, jsonify, request, abort
from .models import trocr_processor, trocr_model
from app.utils.image_processing import read_image, return_image
import easyocr
import json
import numpy as np
import cv2

ocr_bp = Blueprint('ocr', __name__)


@ocr_bp.route('/typed', methods=['POST'])
def handle_typed_ocr():
    if 'image' not in request.files:
        abort(400, description='No image part in request')
    if 'languages' not in request.form:
        abort(400, description='No languages part in request')

    file = request.files['image']
    if file.filename == '':
        abort(400, description='No selected File')

    str_rs = ""
    languages = json.loads(request.form['languages'])

    try:
        image_rec = read_image(file)
        reader = easyocr.Reader(lang_list=languages, gpu=True, model_storage_directory="./models/easyocr/")
        result = reader.readtext(image=image_rec)
        for i in result:
            str_rs += (i[1] + " ")
        return jsonify({'text': str_rs}), 200
    except Exception as e:
        abort(500, description=str(e))


@ocr_bp.route('/hand', methods=['POST'])
def handle_hand_cor():
    fields = ['type', 'kHeight', 'kWidth', 'overlapUp', 'overlapDn', 'minHeight', 'minWhite', 'maxWhite']
    if 'image' not in request.files:
        abort(400, description='No image part in request')

    for field in fields:
        if field not in request.form:
            abort(400, description=f'no {field} part in request')

    text = ""
    file = request.files['image']

    if file.filename == '':
        abort(400, description='No selected File')

    typeocr = request.form.get('type')
    overlapup = int(request.form.get('overlapUp'))
    minheight = int(request.form.get('minHeight'))

    image = read_image(file)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    image_stack = []

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

                    if np.mean(cropped_image) < 253.5:
                        image_stack.append(cropped_image)
                        pixel_values = trocr_processor(images=cropped_image, return_tensors="pt").pixel_values
                        generated_ids = trocr_model.generate(pixel_values)
                        generated_text = trocr_processor.batch_decode(generated_ids, skip_special_tokens=True)[0]
                        text = text + '\n' + generated_text

            image1, image2 = return_image(dilated, image_stack)
            return jsonify({'text': text, 'image1': image1, 'image2': image2}), 200
        except Exception as e:
            abort(500, description=str(e))
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
                abort(500, description="Not enough lines detected to split the image")

            for idx in range(len(line_boundaries) - 1):
                y_top = line_boundaries[idx] - overlapup
                y_bottom = line_boundaries[idx + 1] + overlapdn

                if y_bottom - y_top > minheight:
                    line_image = image[y_top:y_bottom, :]

                    if minwhite < np.mean(line_image) < maxwhite:
                        image_stack.append(line_image)
                        pixel_values = trocr_processor(images=line_image, return_tensors="pt").pixel_values
                        generated_ids = trocr_model.generate(pixel_values)
                        generated_text = trocr_processor.batch_decode(generated_ids, skip_special_tokens=True)[0]
                        text = text + '\n' + generated_text

            image1, image2 = return_image(binary, image_stack)
            return jsonify({'text': text, 'image1': image1, 'image2': image2}), 200
        except Exception as e:
            abort(500, description=str(e))

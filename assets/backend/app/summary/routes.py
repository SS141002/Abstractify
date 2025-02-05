from os import abort

from accelerate.commands.config.config import description
from flask import Blueprint, jsonify, request, abort

from .models import *

summary_bp = Blueprint('summary', __name__)


@summary_bp.route('/summary', methods=['POST'])
def handle_summary():
    data = request.get_json()
    if 'min' not in data:
        abort(400, description='Minimum Length not provided')
    if 'max' not in data:
        abort(400, description='Maximum Length not provided')
    if 'text' not in data:
        abort(400, description='Text not provided')

    long_text = data['text']
    minlength = data['min']
    maxlength = data['max']

    try:
        inputs = tokenizer(long_text, max_length=2048, return_tensors="pt", truncation=True)
        inputs = {key: value.to(device) for key, value in inputs.items()}

        summary_ids = model.generate(inputs["input_ids"], max_length=maxlength, min_length=minlength,
                                     length_penalty=2.0, num_beams=4, early_stopping=True)
        summary_text = tokenizer.decode(summary_ids[0], skip_special_tokens=True)
        return jsonify({'summary': summary_text})
    except Exception as e:
        abort(500, description=str(e))

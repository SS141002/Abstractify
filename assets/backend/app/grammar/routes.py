from accelerate.commands.config.config import description
from flask import Blueprint, jsonify, request, abort
from .models import *
from app.utils.text_processing import clean_text

grammar_bp = Blueprint('grammar', __name__)


@grammar_bp.route('/grammar', methods=['POST'])
def handle_grammar():
    data = request.get_json()

    if 'text' not in data:
        abort(400, description='Text not provided')

    long_text = data['text']

    try:
        result = happy_tt.generate_text("grammar : " + long_text, args=args)
        return jsonify({'text': clean_text(result.text)})
    except Exception as e:
        abort(500, description=str(e))

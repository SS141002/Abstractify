import cv2
import numpy as np
import base64

def read_image(file):
    file_bytes = np.frombuffer(file.read(), np.uint8)
    return cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)

def return_image(image1, images2):
    try:
        _, buffer = cv2.imencode('.jpg', image1)
        str1 = base64.b64encode(buffer).decode('utf-8')
        vertical_image = np.vstack(images2)
        _, buffer = cv2.imencode('.jpg', vertical_image)
        str2 = base64.b64encode(buffer).decode('utf-8')
        return str1, str2
    except Exception as e:
        return e, e
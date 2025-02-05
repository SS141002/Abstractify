from happytransformer import HappyTextToText, TTSettings

happy_tt = HappyTextToText("T5", "./models/t5/")
args = TTSettings(num_beams=5, min_length=1)

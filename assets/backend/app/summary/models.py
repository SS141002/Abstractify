from transformers import BartTokenizer, BartForConditionalGeneration
import torch

__save_dir__ = "./models/bart/"

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
tokenizer = BartTokenizer.from_pretrained(__save_dir__)
model = BartForConditionalGeneration.from_pretrained(__save_dir__).to(device)

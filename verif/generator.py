#verif/generator.py
import os
import sys

# Ustalanie folderu wyżej jako ścieżki i zapis do zmiennej 
parent_path = os.path.abspath(os.path.join(os.path.dirname(__file__),".."))
# Sprawdzanie czy ścieżka z folderem wyżej istnieje w ścieżce, jak nie to jest dodawana
if parent_path not in sys.path:
    sys.path.append(parent_path)

import random


class Generator:
  def __init__(self, seed=None):
    self.random = random.Random(seed)

  def generate(self):
    """Generating random data"""
    return self.random.randint(0,255)
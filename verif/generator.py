#verif/generator.py
import random

class Generator:
  def __init__(self, seed=None):
    self.random = random.Random(seed)

  def generate(self):
    """Generating random data"""
    return self.random.randint(0,255)
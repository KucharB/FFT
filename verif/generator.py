#verif/generator.py
import os
import sys

# Ustalanie folderu wyżej jako ścieżki i zapis do zmiennej 
parent_path = os.path.abspath(os.path.join(os.path.dirname(__file__),".."))
# Sprawdzanie czy ścieżka z folderem wyżej istnieje w ścieżce, jak nie to jest dodawana
if parent_path not in sys.path:
    sys.path.append(parent_path)

import random
import numpy


class Generator:
  def __init__(self, seed=None):
    self.random = random.Random(seed)

  def generate(self, samp_num):
    data = []
    for _ in range(samp_num):
      data.append(self.random.uniform(-0.3,0.3)) 
    scale = 2**(16 - 1) - 1
    fixed_point_values = []
    for value in data:
        fixed_point = int(numpy.round(value * scale))
        if fixed_point < 0:
            # cocotb obsługuje signed, nie ma potrzeby robienia takich rzeczy
            fixed_point = (1 << 16) + fixed_point
        fixed_point_values.append(fixed_point)

    return fixed_point_values

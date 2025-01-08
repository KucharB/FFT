#verif/scoreboard.py
import os
import sys

# Ustalanie folderu wyżej jako ścieżki i zapis do zmiennej 
parent_path = os.path.abspath(os.path.join(os.path.dirname(__file__),".."))
# Sprawdzanie czy ścieżka z folderem wyżej istnieje w ścieżce, jak nie to jest dodawana
if parent_path not in sys.path:
    sys.path.append(parent_path)

class Scoreboard:
  def __init__(self):
    self.expected = []
    self.errors = 0

  def add_expected(self, value):
    self.expected.append(value)

  def check(self, observed):
    """Comparing output value with expected value"""
    for exp, obs in zip(self.expected, observed):
      if exp != obs:
        self.errors += 1
        print(f"ERROR: Expected {exp}, got {obs}")

    if self.errors == 0:
      print("All outputs are correct!")
    else:
      print(f"{self.errors} errors detected")
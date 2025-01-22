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

class AxiScoreboard:
  def __init__(self):
    self.expected_writes = []
    self.expected_reads = []
    self.errors = 0
    self.error_log = []

  def add_expected_write(self, addr, data):
    """Add expected write transactions"""
    self.expected_writes.append((addr, data))

  def add_expected_read(self, addr, data):
    """Add expected read transactions"""
    self.expected_reads.append((addr,data))

  def check_write(self, addr, data):
    """Compare real write transacion with expected"""
    if not self.expected_writes:
      self.errors += 1
      self.error_log.append(f"ERROR: Unexpected write to addr {addr} with data {data}")
      print(f"ERROR: Unexpected write to addr {addr} with data {data}")
    else:
      expected_addr, expected_data = self.expected_writes.pop(0)
      if addr != expected_addr or data != expected_data:
        self.errors += 1
        self.error_log.append(
          f"ERROR: Write mismatch. Expected addr {expected_addr}, data {expected_data}, "
          f"got addr {addr}, data {data}"
        )
        print(f"ERROR: Write mismatch. Expected addr {expected_addr}, data {expected_data}, "
              f"got addr {addr}, data {data}")
        
  def check_read(self, addr, data):
    """Compare real read transaction with expected"""
    if not self.expected_reads:
      self.errors += 1
      self.error_log.append(f"ERROR: Unexpected read from addr {addr} with data {data}")
      print(f"ERROR: Unexpected read from addr {addr} with data {data}")
    else:
      expected_addr, expected_data = self.expected_reads.pop(0)
      if addr != expected_addr or data != expected_data:
        self.errors += 1
        self.error_log.append(
          f"ERROR: Read mismatch. Expected addr {expected_addr}, data {expected_data}, "
          f"got addr {addr}, data {data}"
        )
        print(f"ERROR: Read mismatch. Expected addr {expected_addr}, data {expected_data}, "
              f"got addr {addr}, data {data}")
        
  def summary(self):
    """Results summary"""
    if self.errors == 0:
      print("AXI Scoreboard: All transactions are correct!")
    else:
      print(f"AXI Scoreboard: {self.errors} errors detected.")
      for error in self.error_log:
        print(error)
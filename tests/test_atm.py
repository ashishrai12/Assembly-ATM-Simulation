import pytest
from simulator import ATMSimulator

def test_initial_state():
    sim = ATMSimulator()
    assert sim.authenticated == False
    assert sim.balance == 1000

def test_authentication():
    sim = ATMSimulator(pin="1234")
    assert sim.authenticate("1111") == False
    assert sim.authenticate("1234") == True
    assert sim.authenticated == True

def test_transactions_unauthorized():
    sim = ATMSimulator()
    assert sim.withdraw(100) == "Auth Required"
    assert sim.deposit(100) == "Auth Required"
    assert sim.check_balance() == "Auth Required"

def test_withdrawal():
    sim = ATMSimulator()
    sim.authenticate("1234")
    initial_balance = sim.balance
    sim.withdraw(200)
    assert sim.balance == initial_balance - 200

def test_insufficient_funds():
    sim = ATMSimulator()
    sim.authenticate("1234")
    assert sim.withdraw(2000) == "Insufficient Funds"

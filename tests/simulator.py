import random
import time
import matplotlib.pyplot as plt
import os

class ATMSimulator:
    def __init__(self, pin="1234"):
        self.correct_pin = pin
        self.balance = 1000
        self.authenticated = False
        self.transactions = []
        self.failed_attempts = 0

    def authenticate(self, entered_pin):
        if entered_pin == self.correct_pin:
            self.authenticated = True
            print("Access Granted!")
            return True
        else:
            self.failed_attempts += 1
            print(f"Incorrect PIN. Attempt {self.failed_attempts}")
            return False

    def withdraw(self, amount):
        if not self.authenticated:
            return "Auth Required"
        if amount <= self.balance:
            self.balance -= amount
            self.transactions.append(("Withdraw", amount))
            return True
        return "Insufficient Funds"

    def deposit(self, amount):
        if not self.authenticated:
            return "Auth Required"
        self.balance += amount
        self.transactions.append(("Deposit", amount))
        return True

    def check_balance(self):
        if not self.authenticated:
            return "Auth Required"
        self.transactions.append(("Balance Inquiry", 0))
        return self.balance

def run_simulation_batch(num_ops=20):
    sim = ATMSimulator()
    # Simulate login
    sim.authenticate("1234")
    
    types = ["Withdraw", "Deposit", "Balance Inquiry"]
    for _ in range(num_ops):
        op = random.choice(types)
        if op == "Withdraw":
            sim.withdraw(random.randint(10, 100))
        elif op == "Deposit":
            sim.deposit(random.randint(50, 200))
        else:
            sim.check_balance()
    
    return sim

def generate_plots(sim, output_path="assets/stats.png"):
    if not os.path.exists("assets"):
        os.makedirs("assets")
        
    counts = {"Withdraw": 0, "Deposit": 0, "Balance Inquiry": 0}
    for t_type, _ in sim.transactions:
        counts[t_type] += 1
        
    labels = list(counts.keys())
    values = list(counts.values())

    plt.figure(figsize=(10, 6))
    plt.bar(labels, values, color=['#ff9999','#66b3ff','#99ff99'])
    plt.title("ATM Usage Statistics (Simulation)")
    plt.xlabel("Transaction Type")
    plt.ylabel("Frequency")
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    
    plt.savefig(output_path)
    print(f"Plot saved to {output_path}")

if __name__ == "__main__":
    simulation_result = run_simulation_batch(50)
    generate_plots(simulation_result)
    print(f"Final Balance: ${simulation_result.check_balance()}")

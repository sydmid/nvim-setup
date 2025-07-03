#!/usr/bin/env python3
"""
Test file to verify Python development setup in Neovim
"""

def hello_world():
    """Simple function to test debugging and LSP features"""
    name = "Python Developer"
    message = f"Hello, {name}!"
    print(message)
    return message

def calculate_sum(a: int, b: int) -> int:
    """Function with type hints to test Pyright LSP"""
    return a + b

if __name__ == "__main__":
    # Test basic functionality
    hello_world()

    # Test type checking
    result = calculate_sum(5, 3)
    print(f"Sum: {result}")

    # This should trigger a type error with Pyright
    # result = calculate_sum("5", "3")  # Uncomment to test error detection

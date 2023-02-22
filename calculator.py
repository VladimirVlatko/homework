# Defining the operation functions
def add(a, b):
    print(f"{a} + {b} = {a + b}")

def substract(a, b):
    print(f"{a} - {b} = {a - b}")

def multiply(a, b):
    print(f"{a} * {b} = {a * b}")

def divide(a, b):
    try:
        result = a / b
        # Print formated number with three decimal places
        print(f"{result:.3f}")
    # Catching ZeroDivisionError
    except ZeroDivisionError:
        print("You can't divide by 0.")


def main():
    print("Select operation.\n1.Add\n2.Substract\n3.Multiply\n4.Divide")
    while True:
        user_choice = input("Enter choice: (1/2/3/4): ")
        # Check if the user input is valid.
        if user_choice in ["1", "2", "3", "4"]:
            break
        else:
            print("Your choice is invalid. Try again.")

    while True:
        try:
            first_number = float(input("Enter first number: "))
            second_number = float(input("Enter second number: "))
            break
        # Catching error (invalid input)
        except:
            print("Invalid input, only numbers are allowed. Try again.")
    
    # Calling the choiced function.
    if user_choice == "1":
        add(first_number, second_number)
    elif user_choice == "2":
        substract(first_number, second_number)
    elif user_choice == "3":
        multiply(first_number, second_number)
    else:
        divide(first_number, second_number)

# Run the program. 
while True:    
    main()
    # Check if the user want to do a new calculation.
    new_calculation = input("Would you like to do a new calculation? (yes/no): ")
    if new_calculation == "no":
        break
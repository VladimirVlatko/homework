def main():
    text = input("Enter a fraction, formatted as X/Y: ")
    percentage = convert(text)
    fuel = gauge(percentage)
    print(fuel)

def convert(fraction):
    while True:
        try:
            nums = fraction.split('/')
            x = int(nums[0])
            y = int(nums[1])

            percentage = (x / y) * 100

            if x > y:
                fraction = input("Enter a fraction, formatted as X/Y: ")
            return int(percentage)

        except ValueError:
            raise ValueError
        except ZeroDivisionError:
            raise ZeroDivisionError

def gauge(percentage):
    if percentage <= 1:
        return "E"
    if percentage >= 99:
        return "F"
    else:
        return f"{round(percentage)}%"

if __name__ == "__main__":
    main()

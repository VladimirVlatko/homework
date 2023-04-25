Fuel gauges indicate, often with fractions, just how much fuel is in a tank. 
For instance 1/4 indicates that a tank is 25% full, 1/2 indicates that a tank is 50% full, and 3/4 indicates that a tank is 75% full. In the file called fuel.py is implemented a program that prompts the user for a fraction, formatted as X/Y, wherein each of X and Y is an integer, and then outputs, as a percentage rounded to the nearest integer, how much fuel is in the tank.

If 1% or less remains, output E instead to indicate that the tank is essentially empty. 
And if 99% or more remains, output F instead to indicate that the tank is essentially full.

The program contains two functions:
- **convert** expects a str in X/Y format as input, wherein each of X and Y is an integer, and returns that fraction as a percentage rounded to the nearest int between 0 and 100, inclusive. If X and/or Y is not an integer, or if X is greater than Y, then convert should raise a **ValueError**. If Y is 0, then convert should raise a **ZeroDivisionError**.

- **gauge** expects an int and returns a str that is:
  - "E" if that int is less than or equal to 1,
  - "F" if that int is greater than or equal to 99,
  - and "Z%" otherwise, wherein Z is that same int.
  
In the file called test_fuel.py are implemented two functions that collectively test the implementations of convert and gauge thoroughly.

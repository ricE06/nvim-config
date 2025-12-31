import random

class Yippee():

    def __init__(self, foo, bar):
        self.foofoo = foo
        self.barbarian = bar
        self.woohoo = [1, 4, 9]

    def adlkjgaoidsjfo(self, n):
        return [n*self.foofoo*self.barbarian*a for a in self.woohoo]

    def test(self, inp1, inp2):
        return inp1*self.foofoo

    def test2(self, inp1):
        return self.test(inp1, 1434)

    def oops_mutable_default(self, default_val = []):
        default_val.append(3)
        return default_val

    def test3(self, inp3):
        pass

    def factorial(self, n):
        # return the factorial of n
        if n == 0:
            return 1
        return n * self.factorial(n-1)

    def square(self, n):
        """
        Returns the square of an integer n.
        """
        return self.factorial(n)**2



        





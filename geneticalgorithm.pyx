import random

cdef class GeneticAlgorithm:
    def __init__(self):
        self.g1 = random.randint(5, 50)
        self.g2 = random.randint(5, self.g1)

    cpdef GeneticAlgorithm copy(self):
        new = GeneticAlgorithm()
        new.g1 = self.g1
        new.g2 = self.g2

        return new

    cpdef void mutate(self):
        self.g1 += random.randint(-5, 5)
        self.g2 += random.randint(-2, 2)
        if self.g2 < 0:
            self.g2 = 0
        if self.g1 < 0:
            self.g1 = 0
        if self.g2 > self.g1:
            self.g2 = self.g1
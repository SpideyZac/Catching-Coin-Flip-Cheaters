import random

cdef class Player:
    def __init__(self):
        self.is_cheater = random.random() >= 0.5
        if self.is_cheater:
            self.coin_chance = random.randint(51, 100) / 100
        else:
            self.coin_chance = 0.5

    cpdef str flip(self):
        if random.random() <= self.coin_chance:
            return "heads"
        return "tails"
cdef class Player:
    cdef public bint is_cheater
    cdef public float coin_chance

    cpdef str flip(self)

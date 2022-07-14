cdef class GeneticAlgorithm:
    cdef public int g1
    cdef public int g2

    cpdef GeneticAlgorithm copy(self)
    cpdef void mutate(self)
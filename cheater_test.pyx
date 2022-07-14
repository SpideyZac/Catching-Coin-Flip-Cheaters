from player import Player
from player cimport Player
from geneticalgorithm import GeneticAlgorithm
from geneticalgorithm cimport GeneticAlgorithm
import numpy as np
cimport numpy as np
import os
import time

cdef double get_reward(float nc, float tc, float fp, float tp, float trials):
    cdef double wrongly
    cdef double accurate
    cdef float penalty
    cdef double reward

    reward = 0
    wrongly = fp / nc
    accurate = tp / tc
    penalty = trials / 50

    if wrongly <= 0.05:
        reward += 1
    else:
        reward -= 1
    if accurate >= 0.8:
        reward += 1
    else:
        reward -= 1

    reward -= wrongly
    reward += accurate

    return reward - penalty


cdef bint is_cheater(int num_heads, int thresh):
    if num_heads >= thresh:
        return True
    return False

cpdef train():
    cdef list players = []
    cdef int[:] num_heads = np.zeros(1000, dtype=int)
    cdef float nc_total
    cdef float tc_total
    cdef int i
    cdef int j
    cdef list detectors = []
    cdef double obestf
    cdef GeneticAlgorithm obest
    cdef int iteration
    cdef int _
    cdef double[:] rewards
    cdef float fp
    cdef float tp
    cdef int nh
    cdef bint prediction
    cdef int best
    cdef GeneticAlgorithm besto

    nc_total = 0
    tc_total = 0
    
    print("Adding Detectors")
    for i in range(100):
        detectors.append(GeneticAlgorithm())

    obestf = float("-inf")
    obest = GeneticAlgorithm()

    print("Training")
    for iteration in range(10000):
        if iteration % 10 == 0:
            print(f"Iteration: {iteration}")
        rewards = np.zeros(100)

        players = []
        tc_total = 0
        num_heads = np.zeros(1000, dtype=int)
        nc_total = 0
        for i in range(1000):
            players.append(Player())
            num_heads[i] = 0

        for j in range(len(players)):
            if players[j].is_cheater == True:
                tc_total += 1
            else:
                nc_total += 1

        for i in range(len(detectors)):
            fp = 0
            tp = 0
            for j in range(len(players)):
                nh = 0
                for _ in range(detectors[i].g1):
                    if players[j].flip() == "heads":
                        nh += 1

                prediction = is_cheater(nh, detectors[i].g2)
                if prediction == True and not players[j].is_cheater == True:
                    fp += 1
                if prediction == True and players[j].is_cheater == True:
                    tp += 1
            rewards[i] = get_reward(nc_total, tc_total, fp, tp, detectors[i].g1)

        best = np.argmax(rewards)
        if rewards[best] >= obestf:
            print(f"New Best AI! Score: {rewards[best]}")
            obestf = rewards[best]
            obest = detectors[best]

            if not os.path.exists("ai/best/weights"):
                os.mkdir("ai")
                os.mkdir("ai/best")
                os.mkdir("ai/best/weights")
            f = open("ai/best/weights/g1.gene", "w")
            f.write(str(obest.g1))
            f.close()
            f = open("ai/best/weights/g2.gene", "w")
            f.write(str(obest.g2))
            f.close()
            f = open("ai/best/reward.reward", "w")
            f.write(str(obestf))
            f.close()

        besto = detectors[best]
        detectors = []
        for i in range(100):
            detectors.append(besto)
        for i in range(1, 100):
            detectors[i].mutate()
        detectors[-1] = GeneticAlgorithm()

cpdef test():
    players = []
    num_heads = []
    nc_total = 0
    tc_total = 0

    print("Generating Players")
    for _ in range(1000):
        players.append(Player())
        num_heads.append(0)

    print("Finding Cheaters")
    for j in range(len(players)):
            if players[j].is_cheater:
                tc_total += 1
            else:
                nc_total += 1

    with open("ai/best/weights/g1.gene", "r") as f:
        g1 = int(f.read())
    with open("ai/best/weights/g2.gene", "r") as f:
        g2 = int(f.read())

    tp = 0
    fp = 0
    fn = 0
    tn = 0

    print("Flipping Coins")
    for i in range(len(players)):
        for _ in range(g1):
            if players[i].flip() == "heads":
                num_heads[i] += 1

    print("Testing")
    for i in range(len(players)):
        result = is_cheater(num_heads[i], g2)

        if result and players[i].is_cheater:
            tp += 1
        elif not result and players[i].is_cheater:
            fn += 1
        elif not result and not players[i].is_cheater:
            tn += 1
        else:
            fp += 1

    bugged_coins = []
    for i in range(len(players)):
        if players[i].is_cheater:
            bugged_coins.append(players[i].coin_chance * 100)

    print(f"Results: True Positives: {tp} False Positives: {fp} True Negatives: {tn} False Negatives: {fn}")
    print(f"Cheaters Caught Percentage: {tp / tc_total * 100}% Falsely Accused Percentage: {fp / nc_total * 100}%")
    print(f"Cheater Count {tc_total} Fair Player Count: {nc_total}")
    print(f"Average Cheater Coin: {np.average(bugged_coins)}% Chance To Land On Heads")
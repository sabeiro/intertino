import numpy as np
import pandas as pd

def levenshtein(seq1, seq2):
    size_x = len(seq1) + 1
    size_y = len(seq2) + 1
    matrix = np.zeros ((size_x, size_y))
    for x in range(size_x):
        matrix[x, 0] = x
    for y in range(size_y):
        matrix[0, y] = y
    for x in range(1, size_x):
        for y in range(1, size_y):
            if seq1[x-1] == seq2[y-1]:
                matrix [x,y] = min(
                    matrix[x-1, y] + 1,
                    matrix[x-1, y-1],
                    matrix[x, y-1] + 1
                )
            else:
                matrix [x,y] = min(
                    matrix[x-1,y] + 1,
                    matrix[x-1,y-1] + 1,
                    matrix[x,y-1] + 1
                )
    return (matrix[size_x - 1, size_y - 1])

def jaccard(seq1, seq2): 
    a = set(seq1.split()) 
    b = set(seq2.split())
    c = a.intersection(b)
    return 1. - float(len(c)) / (len(a) + len(b) - len(c))

def match(label,sequence):
    seq = list(sequence)
    minS = 1000000000000
    idx = 0
    for i,s in enumerate(seq):
        m = levenshtein(label,s)
        #m = jaccard(label,s)
        if m < minS:
            minS = m
            idx = i
        if m <= 0.0:
            idx = i
            break
    return idx

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import sys

# data = pd.read_csv("no press 1.csv", sep=", ", engine="python").to_numpy().tolist()
data = pd.read_csv(sys.argv[1], sep=", ", engine="python").to_numpy().tolist()

bit_intervals = []
bits = []
current_time = 0.0
current_row = 0

sampling_interval = 0.00000125

for count, row in enumerate(data):
    if count == 0: continue
    bit_intervals.append((data[count - 1][1], data[count][0] - data[count - 1][0]))
    if bit_intervals[-1][1] > 2.5e-6 and bit_intervals[-1][1] < 5e-6:
        bits += [bit_intervals[-1][0]] * 3
    elif bit_intervals[-1][1] < 1.5e-6:
        bits += [bit_intervals[-1][0]]
    else:
        bits += [1] * round(bit_intervals[-1][1] / sampling_interval)


logic_analyzer_bit_array = np.array(bits)
polling_bits = np.array(list("0001011100010001000100010001000100010001000100010001000101110111000100010001000100010001000100010111"), dtype=int)
polling_bits[polling_bits == 0] = -10
polling_bits[polling_bits == 1] = 1

empty_samples = 500
empty_bits = np.array([-10] * empty_samples)

polls = np.correlate(logic_analyzer_bit_array, polling_bits)
polls = np.argwhere(polls >= 30)

empty = np.correlate(logic_analyzer_bit_array, empty_bits)
empty = np.argwhere(empty == -10 * empty_samples)



ranges = []
for i in polls:
    ranges.append((i[0], i[0] + 356))
# print(ranges)

def process_bits(range_tuple):
    processed_bits = []
    i = range_tuple[0] + 100
    # print(bits[i:range_tuple[1]])
    if bits[i:i+4] != [0, 0, 0, 1]:
        i -= 1
    while i < range_tuple[1]:
        if bits[i:i+4] == [0, 0, 0, 1]:
            processed_bits.append(0)
        else:
            processed_bits.append(1)
        i += 4
    return processed_bits

for r in ranges:
    hex_string = hex(int("".join([str(k) for k in process_bits(r)]), 2))[2:]
    if len(hex_string) != 16:
        hex_string = "0x" + "0" * (16 - len(hex_string)) + hex_string
    else:
        hex_string = "0x" + hex_string
    print(hex_string)
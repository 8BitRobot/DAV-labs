import numpy as np

samples = np.array([100, 100, 100, 100, 200, 200, 200, 200, 300, 300, 300, 300, 400, 400, 400, 400])
# samples = np.array([100, 300, 200, 400, 100, 300, 200, 400,])

results = np.fft.fft(samples, 16)
for i in list(results):
    print(i)
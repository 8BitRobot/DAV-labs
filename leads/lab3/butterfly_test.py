print("Enter your numbers in typical complex number format, e.g. 200+0j or 317+13j.")

A = complex(input("A >\t"))
B = complex(input("B >\t"))
W = complex(input("W >\t"))

print(f"A+BW = {A + B*W}")
print(f"A-BW = {A - B*W}")

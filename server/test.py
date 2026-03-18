x = int(input("Enter a number: "))
y = []

for i in range(x):
    if i <= 1:
        y.append(i)
    else:
        y.append(y[i-1] + y[i-2])
print(y)




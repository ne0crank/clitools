hrs = input("Enter Hours:")
h = float(hrs)
rate = input("Enter Rate:")
r = float(rate)
pay = 0

if h > 40:
  oh = h - 40
  or = r * 1.5
  pay = (h * r) + (oh * or)
else
  pay = h * r

print(pay)

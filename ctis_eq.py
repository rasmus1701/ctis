import sys
import sympy
from equations_3_3_3 import *

sympy_version = float(sympy.__version__)

if sympy_version < 1.1:
    print "You'll need sympy version 1.1 or better for this"
    sys.exit(-1)

print "Preparing linear equations..."
for eq in equations:
    print eq

solutions = sympy.linsolve(equations, diff_vars)

print "Solutions: "
for solution in solutions:
    for index,member in enumerate(solution):
        print diff_vars[index], " = ", member



sys.exit(0)





# EXAMPLES:

#x, y, z, t = symbols('x y z t')
#print  linsolve([x + y + z - 1, x + y + 2*z - 3 ], (x, y, z))

diffraction_vars = var('w112, w412, w421, w121')
l1 = var('a12, a21')
l2 = var('b11')

e1 = w112 - a12 - b11
e2 = w412 - a12
e3 = w421 - a21 - b11
e4 = w121 - a21

solutions = solve([e1,e2,e3,e4])
print solutions

w112, w412, w421, w121 = symbols('w112, w412, w421, w121')
a12, a21 = symbols('a12, a21')
b11 = symbols('b11')

a = linsolve([e1,e2,e3,e4], (a12, a21, b11, w112, w412, w421, w121))
print a

w112, w412, w421, w121 = var('w112, w412, w421, w121')
a12, a21 = var('a12, a21')
b11 = var('b11')

a = linsolve([e1,e2,e3,e4], (a12, a21, b11, w112, w412, w421, w121))
print a

w = var('w112, w412, w421, w121')
a = var('a12, a21')
b = var('b11')

print solve([e1,e2,e3,e4], b11)

#c = w+a+b
#print c
#a = linsolve([e1,e2,e3,e4], (w,a,b))
#print a

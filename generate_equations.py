import sys
import sympy

if len(sys.argv) != 3:
    print "Please supply wanted system dimensions NxNxM (NxN: matrix dim, M: number of layers)"
    print "Usage: %s N M" % (sys.argv[0])
    sys.exit(-1)

try:
    N = int(sys.argv[1])
    M = int(sys.argv[2])
except Exception as e:
    print "Could not parse parameters: %s" % e
    sys.exit(-1)

# declare all diffraction variables (l1_11, l1_12, ..., w1_11, w1_12, ...):
layers = ['l' + str(i) + '_' for i in xrange(1, M+1)] # ['l1_', 'l2_', ..., 'lM_']

datacube_vars = sympy.var(
    [l + str(i) + str(j) for l in layers for i in xrange(1, N+1) for j in xrange(1, N+1)])
w1_vars = sympy.var(
    ['w1_' + str(i) + str(j) for i in xrange(1, N+1) for j in xrange(1, N+M)])
w3_vars = sympy.var(
    ['w3_' + str(i) + str(j) for i in xrange(1, N+1) for j in xrange(1, N+M)])
w2_vars = sympy.var(
    ['w2_' + str(j) + str(i) for i in xrange(1, N+1) for j in xrange(1, N+M)])
w4_vars = sympy.var(
    ['w4_' + str(j) + str(i) for i in xrange(1, N+1) for j in xrange(1, N+M)])
diff_vars = datacube_vars + w1_vars + w2_vars + w3_vars + w4_vars
<<<<<<< 613b8a5ef7ad719adba3586d1e213e4f16997d33

#print diff_vars
print "datacube vars: ", datacube_vars
print "w1 vars: ", w1_vars

# generate all equations using diffraction variables:

# generate equations from w1:

#e1 = w1_vars[0] - datacube_vars[0]
#e2 = w1_vars[1] + w1_vars[1+0]
#e3 = w1_vars[2]
#e3 = w1_vars[2] 

#for i in xrange(1, N+1):
#for j in xrange(1, N+M):
  #      #        print i,j
   #     pass
#eq1_1 =

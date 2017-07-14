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

datacube_vars = [l + str(i) + str(j) for l in layers for i in xrange(1, N+1) for j in xrange(1, N+1)]
w1_vars = ['w1_' + str(i) + str(j) for i in xrange(1, N+1) for j in xrange(1, M+1)]
w3_vars = ['w3_' + str(i) + str(j) for i in xrange(1, N+1) for j in xrange(1, M+1)]
w2_vars = ['w2_' + str(j) + str(i) for i in xrange(1, N+1) for j in xrange(1, M+1)]
w4_vars = ['w4_' + str(j) + str(i) for i in xrange(1, N+1) for j in xrange(1, M+1)]
diff_vars = sympy.var(datacube_vars + w1_vars + w2_vars + w3_vars + w4_vars)

print diff_vars

# generate all equations using diffraction variables:

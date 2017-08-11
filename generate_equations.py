import sys
import sympy
import numpy

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
layers = ['l' + str(i) + '_' for i in xrange(1, M+1)]
# layers = ['l1_', 'l2_', ..., 'lM_']

layer_vars = {i: sympy.var(
    [layers[i] + str(j) + "_" + str(k) for j in xrange(1, N+1) for k in xrange(1, N+1)]
    ) for i in xrange(M)}
# layer_vars = {0: [l1_11, l1_12, ..., l1_55],
#               1: [l2_11, l2_12, ..., l2_55],
#               ...,
#               M-1: [l{M-1}_11, l{M-1}_12, ..., l{M-1}_55]
#              }

diff_vars = []
for i in xrange(M):
    diff_vars += layer_vars[i]

w1_vars = sympy.var(
    ['w1_' + str(i) + "_" + str(j) for i in xrange(1, N+1) for j in xrange(1, N+M)])
w3_vars = sympy.var(
    ['w3_' + str(i) + "_" + str(j) for i in xrange(1, N+1) for j in xrange(1, N+M)])
w2_vars = sympy.var(
    ['w2_' + str(j) + "_" + str(i) for i in xrange(1, N+1) for j in xrange(1, N+M)])
w4_vars = sympy.var(
    ['w4_' + str(j) + "_" + str(i) for i in xrange(1, N+1) for j in xrange(1, N+M)])
diff_vars += w1_vars + w2_vars + w3_vars + w4_vars

w_stride = N+M-1
datacube_stride = N
eq_w1 = []
eq_w2 = []
eq_w3 = []
eq_w4 = []

# generate equations from w1:
row = 0
for i in xrange(N):
    start_layer = 0
    end_layer = 1
    num_eq = 0
    col = 0
    for j in xrange(N+M-1):
        # find correct vars from arrays for equation
        eq = w1_vars[i * w_stride + j]
        for k in xrange(start_layer, end_layer):
            layer = k
            eq = eq - layer_vars[layer][row * N + col - k]
        col += 1
        eq_w1.append(eq)
        # adjust start and end layer
        num_eq += 1
        if num_eq >= N:
            start_layer += 1
        if end_layer < M:
            end_layer += 1
    row += 1

# generate equations from w3:
row = 0
for i in xrange(N):
    start_layer = 0
    end_layer = 1
    num_eq = 0
    col = 0
    for j in xrange(N+M-1):
        # find correct vars from arrays for equation
        eq = w3_vars[i * w_stride + j]
        for k in xrange(start_layer, end_layer):
            # layers are inverted in W3 compared to W1
            layer = abs(k - (M - 1))
            eq = eq - layer_vars[layer][row * N + col - k]
        col += 1
        eq_w3.append(eq)
        # adjust start and end layer
        num_eq += 1
        if num_eq >= N:
            start_layer += 1
        if end_layer < M:
            end_layer += 1
    row += 1

# generate equations from w4:
col = 0
for i in xrange(N):
    start_layer = 0
    end_layer = 1
    num_eq = 0
    row = 0
    for j in xrange(N+M-1):
        # find correct vars from arrays for equation
        eq = w4_vars[i * w_stride + j]
        for k in xrange(start_layer, end_layer):
            layer = k
            eq = eq - layer_vars[layer][(row - k) * N + col]
        row += 1
        eq_w4.append(eq)
        # adjust start and end layer
        num_eq += 1
        if num_eq >= N:
            start_layer += 1
        if end_layer < M:
            end_layer += 1
    col += 1

# generate equations from w2:
col = 0
for i in xrange(N):
    start_layer = 0
    end_layer = 1
    num_eq = 0
    row = 0
    for j in xrange(N+M-1):
        # find correct vars from arrays for equation
        eq = w2_vars[i * w_stride + j]
        for k in xrange(start_layer, end_layer):
            # layers are inverted in W2 compared to W4
            layer = abs(k - (M - 1))
            eq = eq - layer_vars[layer][(row - k) * N + col]
        row += 1
        eq_w2.append(eq)
        # adjust start and end layer
        num_eq += 1
        if num_eq >= N:
            start_layer += 1
        if end_layer < M:
            end_layer += 1
    col += 1

equations = {"W1": eq_w1, "W2": eq_w2, "W3": eq_w3, "W4": eq_w4}

#for key,equation in equations.iteritems():
#    print "\nEquations for %s:" % key
#    for index,eq in enumerate(equation):
#        print index, eq


print "Preparing linear equations..."
lin_equations = numpy.array([eq_w1, eq_w2, eq_w3, eq_w4]).flatten().tolist()
#for eq in lin_equations:
#    print eq

print "Solving linear equation system..."
solutions = sympy.linsolve(lin_equations, diff_vars)

print "Solutions: "
for solution in solutions:
    for index,member in enumerate(solution):
        print diff_vars[index], " = ", member

print "All done"

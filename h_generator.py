import sys
import numpy as np
np.set_printoptions(threshold=np.nan)

def h_generator(d, l):
    g_dim = (3*d + 2*l)
    h = np.zeros((g_dim**2, d**2 * l), dtype=np.int)
    h_iter = 0
    print "MBytes: ", 4 * g_dim**2 * d**2 * l / 10**6

    for i in xrange(d):
        for j in xrange(d):
            for k in xrange(l):
                # create empty diffraction image, g
                g = np.zeros((g_dim, g_dim), dtype=np.int)

                # populate 0th order diffraction image
                row_offset = (l - 1) + d + 1
                col_offset = (l - 1) + d + 1
                g[row_offset + i, col_offset + j] = 1

                # populate 1st order diffractions
                # left:
                row_offset = (l - 1) + d + 1
                col_offset = (l - 1) - k
                g[row_offset + i, col_offset + j] = 1

                # right:
                row_offset = (l - 1) + d + 1
                col_offset = (l - 1) + d + 1 + d + 1 + k
                g[row_offset + i, col_offset + j] = 1

                # bottom:
                row_offset = (l - 1) + d + 1 + d + 1 + k
                col_offset = (l - 1) + d + 1
                g[row_offset + i, col_offset + j] = 1

                # top:
                row_offset = (l - 1) - k
                col_offset = (l - 1) + d + 1
                g[row_offset + i, col_offset + j] = 1

                # top left
                row_offset = (l - 1) - k
                col_offset = (l - 1) - k
                g[row_offset + i, col_offset + j] = 1

                # top right
                row_offset = (l - 1) - k
                col_offset = (l - 1) + d + 1 + d + 1 + k
                g[row_offset + i, col_offset + j] = 1

                # bottom left
                row_offset = (l - 1) + d + 1 + d + 1 + k
                col_offset = (l - 1) - k
                g[row_offset + i, col_offset + j] = 1

                # bottom right
                row_offset = (l - 1) + d + 1 + d + 1 + k
                col_offset = (l - 1) + d + 1 + d + 1 + k
                g[row_offset + i, col_offset + j] = 1

                # use g as column in h
                h[:, h_iter] = g.reshape(g_dim * g_dim)
                h_iter += 1
        print i # show progress...
    return h

def image_generator(d, l):
    g_dim = (3*d + 2*l)

    # create empty diffraction image (ctis sensor image, g)
    g = np.zeros((g_dim, g_dim), dtype=np.int)

    # generate random object cube from which we build ctis image
    f_obj = np.random.randint(256, size=(l, d, d))
    #print f_obj

    # compute vertical sums for 0th order of ctis image
    vertical_sums = np.sum(f_obj, axis=0)

    # populate 0th order of ctis image
    row_offset = (l - 1) + d + 1
    col_offset = (l - 1) + d + 1
    for i in xrange(d):
        for j in xrange(d):
            # consider doing this as replacing submatrix rather than in loops
            g[row_offset + i, col_offset + j] = vertical_sums[i,j]

    # populate 1st order of ctis image
    for i in xrange(d):
        for j in xrange(d):
            for k in xrange(l):
                # right
                row_offset = (l - 1) + d + 1
                col_offset = (l - 1) + d + 1 + d + 1 + k
                g[row_offset + i, col_offset + j] += f_obj[k,i,j]

                # left
                row_offset = (l - 1) + d + 1
                col_offset = (l - 1) - k
                g[row_offset + i, col_offset + j] += f_obj[k,i,j]

                # bottom
                row_offset = (l - 1) + d + 1 + d + 1 + k
                col_offset = (l - 1) + d + 1
                g[row_offset + i, col_offset + j] += f_obj[k,i,j]

                # top
                row_offset = (l - 1) - k
                col_offset = (l - 1) + d + 1
                g[row_offset + i, col_offset + j] += f_obj[k,i,j]

                # top right
                row_offset = (l - 1) - k
                col_offset = (l - 1) + d + 1 + d + 1 + k
                g[row_offset + i, col_offset + j] += f_obj[k,i,j]

                # top left
                row_offset = (l - 1) - k
                col_offset = (l - 1) - k
                g[row_offset + i, col_offset + j] += f_obj[k,i,j]

                # bottom right
                row_offset = (l - 1) + d + 1 + d + 1 + k
                col_offset = (l - 1) + d + 1 + d + 1 + k
                g[row_offset + i, col_offset + j] += f_obj[k,i,j]

                # bottom left
                row_offset = (l - 1) + d + 1 + d + 1 + k
                col_offset = (l - 1) - k
                g[row_offset + i, col_offset + j] += f_obj[k,i,j]
    return g

if __name__ == "__main__":
    usage = "Usage: python %s <dim> <lambda>" % str(sys.argv[0])
    dim = 3
    l = 3
    if len(sys.argv) != 1:
        try:
            dim = int(sys.argv[1])
            l = int(sys.argv[2])
            print "Computing H with dimension and lambda: ", dim, l
        except Exception as e:
            print "Error: %s" % e
            print usage
            sys.exit(-1)
    else:
        print usage
        print "Computing H with default dimension and lambda: ", dim, l
    h = h_generator(dim, l)
    g = image_generator(dim, l)
    print g
    #print h[0]

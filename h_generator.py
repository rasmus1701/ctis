import sys
import numpy as np
np.set_printoptions(threshold=np.nan)

def h_generator(d, l):
    g_dim = (3*d + 2*l)
    h = np.zeros((g_dim**2, d**2 * l), dtype=np.int)
    h_iter = 0

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
    print h[0]

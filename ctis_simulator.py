import sys
import numpy as np
np.set_printoptions(threshold=np.nan)

def ctis_sim(d, l):
    g_dim = (3*d + 2*l)

    # generate empty H-matrix
    h = np.zeros((g_dim**2, d**2 * l), dtype=np.int)

    # generate random object cube from which we build synthetic ctis image, g
    f_obj = np.random.randint(256, size=(l, d, d))

    # create empty ctis image (ctis sensor image, g)
    g = np.zeros((g_dim, g_dim), dtype=np.int)

    print "MBytes of H-matrix: ", 4 * g_dim**2 * d**2 * l / 10**6

    # compute vertical sums for 0th order of ctis image
    vertical_sums = np.sum(f_obj, axis=0)

    # populate 0th order of ctis image
    row_offset = (l - 1) + d + 1
    col_offset = (l - 1) + d + 1
    for i in xrange(d):
        for j in xrange(d):
            # consider doing this as replacing submatrix rather than in loops
            g[row_offset + i, col_offset + j] = vertical_sums[i,j]


    """ loop through data cube, populating both diff_image for constructing H,
    and g, the synthetic diffraction image.
    """
    h_iter = 0
    for i in xrange(d):
        for j in xrange(d):
            for k in xrange(l):
                """ create empty diffraction image, diff_image (similar to g)
                - these end up as columns in H
                """
                diff_image = np.zeros((g_dim, g_dim), dtype=np.int)

                # make dictionary of row_offsets and col_offsets for each diffraction
                diff_offsets = {
                    "top-left": ((l - 1) - k, (l - 1) - k),
                    "top": ((l - 1) - k, (l - 1) + d + 1),
                    "top-right": ((l - 1) - k, (l - 1) + d + 1 + d + 1 + k),
                    "left": ((l - 1) + d + 1, (l - 1) - k),
                    "middle": ((l - 1) + d + 1, (l - 1) + d + 1),
                    "right": ((l - 1) + d + 1, (l - 1) + d + 1 + d + 1 + k),
                    "bottom-left": ((l - 1) + d + 1 + d + 1 + k, (l - 1) - k),
                    "bottom": ((l - 1) + d + 1 + d + 1 + k, (l - 1) + d + 1),
                    "bottom-right": ((l - 1) + d + 1 + d + 1 + k, (l - 1) + d + 1 + d + 1 + k)
                    }

                # populate g and image for H
                for key, offsets in diff_offsets.iteritems():
                    row_offset = offsets[0] + i
                    col_offset = offsets[1] + j
                    diff_image[row_offset, col_offset] = 1
                    if key != "middle":
                        # 0th order populated above
                        g[row_offset, col_offset] += f_obj[k,i,j]

                # use diff_image as column in h
                h[:, h_iter] = diff_image.reshape(g_dim * g_dim)
                h_iter += 1
        # print i # show progress...
    return f_obj, g, h

def mert(g, h, d, l, iterations=100):
    g_dim = (3*d + 2*l)
    g = g.reshape(g_dim*g_dim, 1)

    f_iter = np.matmul(np.transpose(h), g)
    h_sum = sum(h, 0)

    np.seterr(divide='ignore', invalid='ignore')
    f_next = np.zeros((d**3, 1), dtype=np.int)

    for i in xrange(iterations):
        g_iter = np.matmul(h, f_iter)
        g_div = np.nan_to_num(np.true_divide(g, g_iter))

        for j in xrange(len(f_iter)):
            f_next[j] = np.multiply(np.transpose((np.true_divide(np.transpose(f_iter[j]), h_sum[j]))),
                                        sum(np.dot(h[:,j], g_div)))
        f_iter = f_next
    f_iter = np.reshape(f_next,[dim,dim,l])
    f_iter = np.transpose(f_iter)
    f_out = np.zeros((d,d,l), dtype=np.int)
    for k in xrange(l):
        f_out[k,:] = np.transpose(f_iter[k,:])
    return f_out


if __name__ == "__main__":
    usage = "Usage: python %s <dim> <lambda> <iterations>" % str(sys.argv[0])
    dim = 3
    l = 3
    iterations = 10
    if len(sys.argv) != 1:
        try:
            dim = int(sys.argv[1])
            l = int(sys.argv[2])
            iterations = int(sys.argv[3])
            print "Computing CTIS simulation with dimension %d, lambda %d, " \
              "and reconstruction iterations %d\n " % (dim, l, iterations)
        except Exception as e:
            print "Error: %s" % e
            print usage
            sys.exit(-1)
    else:
        print usage
        print "Computing CTIS simulation with default dimension, lambda, " \
          "and iterations: ", dim, l, iterations
    f_obj, g,h = ctis_sim(dim, l)

    f = mert(g, h, dim, l, iterations)
    print "\nf_obj: \n", f_obj
    print "\nf_calc: \n", f

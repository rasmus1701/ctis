import sys
import getopt
import numpy as np
from scipy.misc import imread,imsave
np.set_printoptions(threshold=np.nan)
import matplotlib.pyplot as plt
import cv2

USE_RGB_IMAGE = False

def ctis_sim(d, l, image):
    g_dim = (3*d + 2*l)

    # generate empty H-matrix
    h = np.zeros((g_dim**2, d**2 * l), dtype=np.int)

    # generate random object cube from which we build synthetic ctis image, g
    #f_obj = np.random.randint(256, size=(l, d, d))
    f_obj = np.random.randint(118, high=138, size=(l, d, d))
    if USE_RGB_IMAGE:
        # when running in image mode, put R,G,B channels in first layers of f
        image = np.moveaxis(image, 2, 0)
        f_obj[0] = image[0]
        f_obj[1] = image[1]
        f_obj[2] = image[2]

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
        print i # show progress...
    return f_obj, g, h

def mert(g, h, d, l, iterations=100):
    g_dim = (3*d + 2*l)
    g = g.reshape(g_dim*g_dim, 1)

    f_iter = np.matmul(np.transpose(h), g)
    h_sum = sum(h, 0)

    np.seterr(divide='ignore', invalid='ignore')
    f_next = np.zeros((d**2 * l, 1), dtype=np.int)

    for i in xrange(iterations):
        print "iteration %d of %d" % (i, iterations)
        g_iter = np.matmul(h, f_iter)
        g_div = np.nan_to_num(np.true_divide(g, g_iter))

        for j in xrange(len(f_iter)):
            f_next[j] = np.multiply((np.true_divide(f_iter[j], h_sum[j])),
                                        sum(np.dot(h[:,j], g_div)))
        f_iter = f_next
    f_iter = np.reshape(f_next, [dim, dim, l])
    f_iter = np.transpose(f_iter)
    f_out = np.zeros((l, d, d), dtype=np.int)
    for k in xrange(l):
        f_out[k,:] = np.transpose(f_iter[k,:])
    return f_out


if __name__ == "__main__":
    usage = "Usage: python %s -d <dim> -l <lambda> -l <iterations> " \
      "-f <input_image>" % str(sys.argv[0])

    # default simulation parameters
    dim = 3
    l = 3
    iterations = 10
    input_image = ''
    image = np.array([])

    # parse command line options
    options, remainder = getopt.getopt(sys.argv[1:], 'd:l:i:f:')
    try:
        for opt, arg in options:
            if opt == '-d':
                dim = int(arg)
            if opt == '-l':
                l = int(arg)
            if opt == '-i':
                iterations= int(arg)
            if opt == '-f':
                input_image = arg
                image = cv2.imread(arg)
                if image is None:
                    raise IOError("No such file %s" % input_image)
                USE_RGB_IMAGE = True
    except Exception as e:
        print "Error: %s" % e
        print usage
        sys.exit(-1)


    if USE_RGB_IMAGE:
        # resize image to given dimension
        image = cv2.resize(image, (dim, dim))

        # force using only 3 spectral layers in file mode
        if  l != 3:
            print "Warning: When running in file mode, we'll use only 3 spectral " \
            "layers, not %d as requested" % l
            l = 3

    string = "Computing CTIS simulation with dimension %d, lambda %d, " \
      "and reconstruction iterations %d" % (dim, l, iterations)
    if input_image != '':
        string += " on input image %s" % input_image
    print string + "\n"

    # start simulation; compute random f_obj, g, and h
    f_obj, g,h = ctis_sim(dim, l, image)

    # perform reconstruction using MERT algorithm
    f_calc = mert(g, h, dim, l, iterations)

    print "Average error: ", np.mean(abs(f_obj-f_calc))

    if USE_RGB_IMAGE:
        f_obj = np.moveaxis(f_obj, 0, 2)
        #f_obj = np.clip(f_obj, 0, 255)
        f_calc = np.moveaxis(f_calc, 0, 2)
        f_calc = np.clip(f_calc, 0, 255)
        try:
            output_file = '%s_reconstructed.jpg' % input_image.split('.')[0]
        except Exception as e:
            output_file = "reconstructed.jpg"
        print "Writing to output file %s\n" % output_file
        cv2.imwrite(output_file, f_calc)


        #cv2.waitKey(0)
#        plot_image = np.concatenate((f_obj, f_calc), axis=1)



        #print f_calc
        #print f_calc.shape
#    for i in xrange(3):
        #plt.imshow(f[i])
        #plt.show()
  #      print "layer: ", i
   #     print f[i]
    #    cv2.imwrite('layer_%d.jpg' % i, f[i])
        #imsave('layer_%d.jpg' % i, f[i])

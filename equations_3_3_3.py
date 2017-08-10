from sympy import var

diff_vars = var('\
L1_11, L1_12, L1_13, L1_21, L1_22, L1_23,  L1_31, L1_32, L1_33,\
L2_11, L2_12, L2_13, L2_21, L2_22, L2_23,  L2_31, L2_32, L2_33,\
L3_11, L3_12, L3_13, L3_21, L3_22, L3_23,  L3_31, L3_32, L3_33,\
W1_11, W1_12, W1_13, W1_14, W1_15, W1_21, W1_22, W1_23, W1_24, W1_25, W1_31, W1_32, W1_33, W1_34, W1_35,\
W2_11, W2_12, W2_13, W2_21, W2_22, W2_23, W2_31, W2_32, W2_33, W2_41, W2_42, W2_43, W2_51, W2_52, W2_53,\
W3_11, W3_12, W3_13, W3_14, W3_15, W3_21, W3_22, W3_23, W3_24, W3_25, W3_31, W3_32, W3_33, W3_34, W3_35,\
W4_11, W4_12, W4_13, W4_21, W4_22, W4_23, W4_31, W4_32, W4_33, W4_41, W4_42, W4_43, W4_51, W4_52, W4_53'\
                    )

eq1 = W1_11 - L1_11
eq2 = W1_12 - L1_12 - L2_11
eq3 = W1_13 - L1_13 - L2_12 - L3_11
eq4 = W1_14 - L2_13 - L3_12
eq5 = W1_15 - L3_13
eq6 = W1_21 - L1_21
eq7 = W1_22 - L1_22 - L2_21
eq8 = W1_23 - L1_23 - L2_22 - L3_21
eq9 = W1_24 - L2_23 - L3_22
eq10 = W1_25 - L3_23
eq11 = W1_31 - L1_31
eq12 = W1_32 - L1_32 - L2_31
eq13 = W1_33 - L1_33 - L2_32 - L3_31
eq14 = W1_34 - L2_33 - L3_32
eq15 = W1_35 - L3_33
eq16 = W2_11 - L3_11
eq17 = W2_12 - L3_12
eq18 = W2_13 - L3_13
eq19 = W2_21 - L3_21 - L2_11
eq20 = W2_22 - L3_22 - L2_12
eq21 = W2_23 - L3_23 - L2_13
eq22 = W2_31 - L3_31 - L2_21 - L1_11
eq23 = W2_32 - L3_32 - L2_22 - L1_12
eq24 = W2_33 - L3_33 - L2_23 - L1_13
eq25 = W2_41 - L2_31 - L1_21
eq26 = W2_42 - L2_32 - L1_22
eq27 = W2_43 - L2_33 - L1_23
eq28 = W2_51 - L1_31
eq29 = W2_52 - L1_32
eq30 = W2_53 - L1_33
eq31 = W3_11 - L3_11
eq32 = W3_12 - L3_12 - L2_11
eq33 = W3_13 - L3_13 - L2_12 - L1_11
eq34 = W3_14 - L2_13 - L1_12
eq35 = W3_15 - L1_13
eq36 = W3_21 - L3_21
eq37 = W3_22 - L3_22 - L2_21
eq38 = W3_23 - L3_23 - L2_22 - L1_21
eq39 = W3_24 - L2_23 - L1_22
eq40 = W3_25 - L1_23
eq41 = W3_31 - L3_31
eq42 = W3_32 - L3_32 - L2_31
eq43 = W3_33 - L3_33 - L2_32 - L1_31
eq44 = W3_34 - L2_33 - L1_32
eq45 = W3_35 - L1_33
eq46 = W4_11 - L1_11
eq47 = W4_12 - L1_12
eq48 = W4_13 - L1_13
eq49 = W4_21 - L1_21 - L2_11
eq50 = W4_22 - L1_22 - L2_12
eq51 = W4_23 - L1_23 - L2_13
eq52 = W4_31 - L1_31 - L2_21 - L3_11
eq53 = W4_32 - L1_32 - L2_22 - L3_12
eq54 = W4_33 - L1_33 - L2_23 - L3_13
eq55 = W4_41 - L2_31 - L3_21
eq56 = W4_42 - L2_32 - L3_22
eq57 = W4_43 - L2_33 - L3_23
eq58 = W4_51 - L3_31
eq59 = W4_52 - L3_32
eq60 = W4_53 - L3_33

equations = [eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8, eq9, eq10, eq11, eq12, eq13, eq14, eq15, eq16, eq17, eq18, eq19, eq20, eq21, eq22, eq23, eq24, eq25, eq26, eq27, eq28, eq29, eq30, eq31, eq32, eq33, eq34, eq35, eq36, eq37, eq38, eq39, eq40, eq41, eq42, eq43, eq44, eq45, eq46, eq47, eq48, eq49, eq50, eq51, eq52, eq53, eq54, eq55, eq56, eq57, eq58, eq59, eq60]

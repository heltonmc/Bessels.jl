#    Bessel functions of the first kind of order zero and one
#                       besselj0, besselj1
#
#    Calculation of besselj0 is done in three branches using polynomial approximations
#
#    Branch 1: x <= 5.0
#              besselj0 = (x^2 - r1^2)*(x^2 - r2^2)*P3(x^2) / Q8(x^2)
#    where r1 and r2 are zeros of J0
#    and P3 and Q8 are a 3 and 8 degree polynomial respectively
#    Polynomial coefficients are from [1] which is based on [2]
#    For tiny arugments the power series expansion is used.
#
#    Branch 2: 5.0 < x < 75.0
#              besselj0 = sqrt(2/(pi*x))*(cos(x - pi/4)*R7(x) - sin(x - pi/4)*R8(x))
#    Hankel's asymptotic expansion is used
#    where R7 and R8 are rational functions (Pn(x)/Qn(x)) of degree 7 and 8 respectively
#    See section 4 of [3] for more details and [1] for coefficients of polynomials
# 
#   Branch 3: x >= 75.0
#              besselj0 = sqrt(2/(pi*x))*beta(x)*(cos(x - pi/4 - alpha(x))
#   See modified expansions given in [3]. Exact coefficients are used
#
#   Calculation of besselj1 is done in a similar way as besselj0.
#   See [3] for details on similarities.
# 
# [1] https://github.com/deepmind/torch-cephes
# [2] Cephes Math Library Release 2.8:  June, 2000 by Stephen L. Moshier
# [3] Harrison, John. "Fast and accurate Bessel function computation." 
#     2009 19th IEEE Symposium on Computer Arithmetic. IEEE, 2009.
#
function besselj0(x::Float64)
    T = Float64
    x = abs(x)
    isinf(x) && return zero(x)

    if x <= 5
        z = x * x
        if x < 1.0e-5
            return 1.0 - z / 4.0
        end
        DR1 = 5.78318596294678452118e0
        DR2 = 3.04712623436620863991e1
        p = (z - DR1) * (z - DR2)
        p = p * evalpoly(z, RP_j0(T)) / evalpoly(z, RQ_j0(T))
        return p
    elseif x < 25.0
        w = 5.0 / x
        q = 25.0 / (x * x)

        p = evalpoly(q, PP_j0(T)) / evalpoly(q, PQ_j0(T))
        q = evalpoly(q, QP_j0(T)) / evalpoly(q, QQ_j0(T))
        xn = x - PIO4(T)
        sc = sincos(xn)
        p = p * sc[2] - w * q * sc[1]
        return p * SQ2OPI(T) / sqrt(x)
    elseif x < 75.0
        xinv = inv(x)
        x2 = xinv * xinv
        p = (one(T), -9/128, 3675/32768, - 2401245/4194304, 13043905875/2147483648, - 30241281245175/274877906944, 213786613951685775/70368744177664, -1070401384414690453125/9007199254740992, 57673297952355815927071875/9223372036854775808)
        q = (-1/8, 75/1024, - 59535/262144, 57972915/33554432, - 418854310875/17179869184, 1212400457192925/2199023255552, - 10278202593831046875/562949953421312, 60013837619516978071875/72057594037927936, - 3694483615889146090857721875/73786976294838206464)
        p = evalpoly(x2, p)
        q = evalpoly(x2, q) * xinv
        alpha = atan(-q/p)

        pq = (one(T), -1/16, 53/512, -4447/8192, 3066403/524288, -896631415/8388608, 796754802993/268435456, -500528959023471/4294967296)
        beta = evalpoly(x2, pq)
        return SQ2OPI(T) * sqrt(xinv) * beta * cos_sum(x, - T(pi)/4 - alpha)
    else
        xinv = inv(x)
        x2 = xinv*xinv

        p = (one(T), -1/16, 53/512, -4447/8192, 3066403/524288)
        p = evalpoly(x2, p)
        a = SQ2OPI(T) * sqrt(xinv) * p

        q = (-1/8, 25/384, -1073/5120, 375733/229376, -55384775/2359296)
        xn = muladd(xinv, evalpoly(x2, q), - PIO4(T))

        # the following computes b = cos(x + xn) more accurately
        # see src/misc.jl
        b = cos_sum(x, xn)
        return a * b
    end
end
function besselj0(x::Float32)
    T = Float32
    x = abs(x)
    isinf(x) && return zero(x)

    if x <= 2.0f0
        z = x * x
        if x < 1.0f-3
            return 1.0f0 - 0.25f0 * z
        end
        DR1 = 5.78318596294678452118f0
        p = (z - DR1) * evalpoly(z, JP_j0(T))
        return p
    else
        q = inv(x)
        w = sqrt(q)
        p = w * evalpoly(q, MO_j0(T))
        w = q * q
        xn = q * evalpoly(w, PH_j0(T)) - PIO4(Float32)
        p = p * cos(xn + x)
        return p
    end
end

function besselj1(x::Float64)
    T = Float64
    x = abs(x)
    isinf(x) && return zero(x)

    if x <= 5.0
        z = x * x
        w = evalpoly(z, RP_j1(T)) / evalpoly(z, RQ_j1(T))
        w = w * x * (z - 1.46819706421238932572e1) * (z - 4.92184563216946036703e1)
        return w
    elseif x < 25.0
        w = 5.0 / x
        z = w * w
        p = evalpoly(z, PP_j1(T)) / evalpoly(z, PQ_j1(T))
        q = evalpoly(z, QP_j1(T)) / evalpoly(z, QQ_j1(T))
        xn = x - THPIO4(T)
        sc = sincos(xn)
        p = p * sc[2] - w * q * sc[1]
        return p * SQ2OPI(T) / sqrt(x)
    elseif x < 75.0
        xinv = inv(x)
        x2 = xinv * xinv
        p = (one(T), 15/128, -4725/32768, 2837835/4194304, -14783093325/2147483648, 33424574007825/274877906944, -232376754295310625/70368744177664, 1149690375852815671875/9007199254740992)
        q = (3/8, -105/1024, 72765/262144, -66891825/33554432, 468131288625/17179869184, -1327867167401775/2199023255552, 11100458801337530625/562949953421312, -64152722972587114490625/72057594037927936)
        p = evalpoly(x2, p)
        q = evalpoly(x2, q) * xinv
        alpha = atan(-q/p)

        pq = (one(T), 3/16, -99/512, 6597/8192, -4057965/524288, 1113686901/8388608, -951148335159/268435456, 581513783771781/4294967296, -3198424285940846836612419/9223372036854775808)
        beta = evalpoly(x2, pq)
        return SQ2OPI(T) * sqrt(xinv) * beta * cos_sum(x, - 3*T(pi)/4 - alpha)
    else
        xinv = inv(x)
        x2 = xinv*xinv

        p = (one(T), 3/16, -99/512, 6597/8192, -4057965/524288)
        p = evalpoly(x2, p)
        a = SQ2OPI(T) * sqrt(xinv) * p

        q = (3/8, -21/128, 1899/5120, -543483/229376, 8027901/262144)
        xn = muladd(xinv, evalpoly(x2, q), - 3 * PIO4(T))

        # the following computes b = cos(x + xn) more accurately
        # see src/misc.jl
        b = cos_sum(x, xn)
        return a * b
    end
end

function besselj1(x::Float32)
    x = abs(x)
    isinf(x) && return zero(x)

    if x <= 2.0f0
        z = x * x
        Z1 = 1.46819706421238932572f1
        p = (z - Z1) * x * evalpoly(z, JP32)
        return p
    else
        q = inv(x)
        w = sqrt(q)
        p = w * evalpoly(q, MO132)
        w = q * q
        xn = q * evalpoly(w, PH132) - THPIO4(Float32)
        p = p * cos(xn + x)
        return p
    end
end

package com.roveroniandrea.pes;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class Poisson extends Distribution{
    private final float lambda;

    /**
     * Poisson's distribution of certain lambda
     * @param lambda lambda of Poisson's distribution. Must be greater than zero
     */
    public Poisson(float lambda) {
        this.lambda = Math.max(0, lambda);
    }


    /**
     * Returns the probability of a given event
     *
     * @param x        the value of the event
     * @param operator the operator of the event
     * @return P[X {operator} x]
     */
    public float getProb(int x, EventOperator operator) throws Exception {
        return handleGetProb(x, operator, Integer.MAX_VALUE, k_local -> true, k_local -> {
            BigDecimal power = BigDecimal.valueOf(Math.pow(lambda, k_local));
            BigDecimal division = power.divide(new BigDecimal(PesUtility.factorial(k_local)), RoundingMode.DOWN);
            return division.floatValue() * (float)Math.exp(-lambda);
        });
    }

    /**
     * Returns the media of the distribution
     *
     * @return E[X]
     */
    public float getMedia() {
        return lambda;
    }

    /**
     * Return the variance of the distribution
     *
     * @return Var[X]
     */
    public float getVariance() {
        return lambda;
    }
}

package com.roveroniandrea.pes;

public class Binomial extends Distribution {
    private final int n_proves;
    private final float p_success;

    /**
     * Sequence of n independents Bernoulli's distributions, each one with p probability of success
     * @param n_proves number of Bernoulli's proves
     * @param p_success probability of success
     */
    public Binomial(int n_proves, float p_success) {
        this.n_proves = n_proves;
        this.p_success = p_success;
    }

    /**
     * Returns the probability of a given event
     *
     * @param x        the value of the event
     * @param operator the operator of the event
     * @return P[X {operator} x]
     */
    public float getProb(int x, EventOperator operator) throws Exception {
        return handleGetProb(x, operator, n_proves, x_local -> n_proves / 2 > x_local, x_local -> (float) (PesUtility.newtonBinomial(n_proves, x_local) * Math.pow(p_success, x_local) * Math.pow(1 - p_success, n_proves - x_local)));
    }

    /**
     * Returns the media of the distribution
     *
     * @return E[X]
     */
    public float getMedia() {
        return n_proves * p_success;
    }

    /**
     * Return the variance of the distribution
     *
     * @return Var[X]
     */
    public float getVariance() {
        return getMedia() * (1 - p_success);
    }
}

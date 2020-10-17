package com.roveroniandrea.pes;

public class Bernoulli extends Distribution{

    private final float p_success;

    /**
     * Single experiment with certain probability of success.
     * Note that the only event values are 0 if failed, 1 if succeeded
     * @param p_success probability of success
     */
    public Bernoulli(float p_success) {
        this.p_success = p_success;
    }

    /**
     * Returns the probability of a given event
     *
     * @param x        the value of the event. Can be either 0 if failed or 1 if succeeded
     * @param operator the operator of the event
     * @return P[X {operator} x]
     */
    public float getProb(int x, EventOperator operator) throws Exception {
        return handleGetProb(x, operator, 1, a -> true, value -> (float)Math.pow(p_success, value) * (float)Math.pow(1 - p_success, 1 - value));
    }

    /**
     * Returns the media of the distribution
     *
     * @return E[X]
     */
    public float getMedia() {
        return p_success;
    }

    /**
     * Return the variance of the distribution
     *
     * @return Var[X]
     */
    public float getVariance() {
        return p_success * (1 - p_success);
    }
}

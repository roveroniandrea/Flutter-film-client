package com.roveroniandrea.pes;

public class Hypergeometric extends Distribution {

    private final int N_population;
    private final int K_success;
    private final int n_extractions;

    /**
     * The Hypergeometric distribution
     * <p>
     * Considering n extractions without reinsertion from N elements, which K of them
     * are considered successes
     *
     * @param N_population  Population size
     * @param K_success     Number of successes in the population
     * @param n_extractions Number of extractions
     */
    public Hypergeometric(int N_population, int K_success, int n_extractions) {
        this.N_population = N_population;
        this.K_success = K_success;
        this.n_extractions = n_extractions;
    }

    /**
     * Returns the probability of a given event
     *
     * @param k        the value of the event
     * @param operator the operator of the event
     * @return P[X {operator} k]
     */
    public float getProb(int k, EventOperator operator) throws Exception {
        return handleGetProb(k, operator, n_extractions, k_local -> n_extractions / 2 > k_local, k_local -> {
            float numerator = PesUtility.newtonBinomial(K_success, k_local) * PesUtility.newtonBinomial(N_population - K_success, n_extractions - k_local);
            return numerator / PesUtility.newtonBinomial(N_population, n_extractions);
        });
    }

    /**
     * Returns the media of the distribution
     *
     * @return E[X]
     */
    public float getMedia() {
        return n_extractions * K_success / (float) N_population;
    }

    /**
     * Return the variance of the distribution
     *
     * @return Var[X]
     */
    public float getVariance() {
        return getMedia() * ((N_population - K_success) / (float) N_population) * (N_population - n_extractions) / (float) (N_population - 1);
    }
}

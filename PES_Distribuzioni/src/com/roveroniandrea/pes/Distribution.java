package com.roveroniandrea.pes;

import java.util.function.Function;

public abstract class Distribution {
    /**
     * The operator specifying a given event
     */
    public enum EventOperator {Less, LessEqual, Equal, GreaterEqual, Greater}

    /**
     * Returns the probability of a given event
     * @param x the value of the event
     * @param operator the operator of the event
     * @return P[X {operator} x]
     */
    abstract public float getProb(int x, EventOperator operator) throws Exception;

    /**
     * Returns the media of the distribution
     * @return E[X]
     */
    abstract public float getMedia();

    /**
     * Return the variance of the distribution
     * @return Var[X]
     */
    abstract public float getVariance();

    /**
     * Handles the different combination of event operators
     * Calls the evaluateEqual to evaluate all cases
     * @param k starting event value
     * @param operator starting operator
     * @param maxLimit max k limit (inclusive)
     * @param betterToStart function that evaluates if it's better to proceed to k = 0 or k = maxLimit
     * @param evaluateEqual function that evaluates a single P[X = k] event
     * @return P[X {operator} k]
     * @throws Exception if unknown operator
     */
    protected float handleGetProb(int k, EventOperator operator, int maxLimit, Function<Integer, Boolean> betterToStart, Function<Integer, Float> evaluateEqual) throws Exception{
        if(k < 0 || k > maxLimit) return 0;
        switch (operator){
            // P[X < k]
            case Less -> {
                // P[X <= k - 1] o 1 - P[X >= k]
                return betterToStart.apply(k)? getProb(k - 1, EventOperator.LessEqual): 1 - getProb(k, EventOperator.GreaterEqual);
            }
            // P[X <= k]
            case LessEqual -> {
                // P[X = k] + P[X <= k - 1] o 1 - P[X >= k + 1]
                return betterToStart.apply(k)? getProb(k, EventOperator.Equal) + getProb(k - 1, EventOperator.LessEqual) : 1 - getProb(k +1, EventOperator.GreaterEqual);
            }
            // P[X = k]
            case Equal -> {
                return evaluateEqual.apply(k);
            }
            // P[X >= k]
            case GreaterEqual -> {
                // 1 - P[X <= k - 1] o P[X = k] + P[X >= k + 1]
                return betterToStart.apply(k)? 1 - getProb(k- 1, EventOperator.LessEqual) : getProb(k, EventOperator.Equal) + getProb(k + 1, EventOperator.GreaterEqual);
            }
            // P[X > k]
            case Greater -> {
                // 1 - P[X <= k] o P[X >= k + 1]
                return  betterToStart.apply(k)? 1- getProb(k, EventOperator.LessEqual) : getProb(k + 1, EventOperator.GreaterEqual);
            }
            default -> throw new Exception("Error");
        }
    }
}

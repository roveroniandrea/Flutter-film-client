package com.roveroniandrea.pes;

import java.math.BigInteger;

public class PesUtility {

    /**
     * Return the newton binomial of n and k
     * @return (n k)
     */
    public static int newtonBinomial(int n, int k){
        return PesUtility.factorial(n).divide((PesUtility.factorial(k).multiply(PesUtility.factorial(n - k)))).intValueExact();
    }

    /**
     * Returns the factorial of n
     * @param n input number
     * @return n!
     */
    public static BigInteger factorial(int n){
        BigInteger result = BigInteger.ONE;
        for(int i = n; i > 1; i--){
            result = result.multiply(BigInteger.valueOf(i));
        }
        return result;
    }
}

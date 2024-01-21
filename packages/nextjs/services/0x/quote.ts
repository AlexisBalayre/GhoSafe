import { NETWORKS_EXTRA_DATA } from "../../utils/0x";

import axios from 'axios';

export async function getSwapQuote(chainId: string, sellToken: string, buyToken: string, sellAmount: string) {
    try {
        // Make a GET request to the 0x API
        const response = await axios.get(String(NETWORKS_EXTRA_DATA[chainId]), {
            params: {
                sellToken,
                buyToken,
                sellAmount
            }
        });

        // Log the response
        console.log(response.data);
    } catch (error) {
        // Handle errors
        console.error('Error fetching swap quote:', error);
    }
}


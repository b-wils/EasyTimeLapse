//
//  crc.h
//  etl_iphone_v1
//
//  Created by Inspired Eye on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef etl_iphone_v1_crc_h
#define etl_iphone_v1_crc_h
#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdlib.h>
    
    /**
     * The definition of the used algorithm.
     *****************************************************************************/
#define CRC_ALGO_BIT_BY_BIT_FAST 1
    
    // TODO: We can use a table generated algorithm to be a bit faster with processing
    
    /**
     * The type of the CRC values.
     *
     * This type must be big enough to contain at least 16 bits.
     *****************************************************************************/
    typedef uint16_t crc_t;
    
    
    /**
     * Reflect all bits of a \a data word of \a data_len bytes.
     *
     * \param data         The data word to be reflected.
     * \param data_len     The width of \a data expressed in number of bits.
     * \return             The reflected data.
     *****************************************************************************/
    crc_t crc_reflect(crc_t data, size_t data_len);
    
    
    /**
     * Calculate the initial crc value.
     *
     * \return     The initial crc value.
     *****************************************************************************/
    static inline crc_t crc_init(void)
    {
        return 0x0000;
    }
    
    
    /**
     * Update the crc value with new data.
     *
     * \param crc      The current crc value.
     * \param data     Pointer to a buffer of \a data_len bytes.
     * \param data_len Number of bytes in the \a data buffer.
     * \return         The updated crc value.
     *****************************************************************************/
    crc_t crc_update(crc_t crc, const unsigned char *data, size_t data_len);
    
    
    /**
     * Calculate the final crc value.
     *
     * \param crc  The current crc value.
     * \return     The final crc value.
     *****************************************************************************/
    static inline crc_t crc_finalize(crc_t crc)
    {
        return crc_reflect(crc, 16) ^ 0x0000;
    }
    
    
#ifdef __cplusplus
}           /* closing brace for extern "C" */
#endif

#endif

/*
 *  etl_typedefs.c
 *  etl_iphone_v1
 *
 *  Created by Ben Hoffman on 6/2/12.
 *  Copyright 2012 Microsoft. All rights reserved.
 *
 */

#include "etl_typedefs.h"
#include <memory.h>

void initEtlConfig(SectionConfig* config) {
    memset(config, 0, sizeof(SectionConfig));
}
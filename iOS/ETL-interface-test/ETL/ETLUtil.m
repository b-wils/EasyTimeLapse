//
//  ETLUtil.c
//  ETL
//
//  Created by Carll Hoffman on 8/22/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#include "ETLUtil.h"

NSString* formatSeconds(float_t totalSeconds, NSString *formatString)
{
    NSUInteger hours = floor(totalSeconds / 3600);
    NSUInteger minutes = floor((totalSeconds - hours * 3600) / 60);
    float_t seconds = totalSeconds - (hours * 3600.0) - (minutes * 60.0);
    
    return [NSString stringWithFormat:formatString, hours, minutes, seconds];
}

NSString* msToEnglish(NSUInteger ms) {
    if (ms == FOREVER) return @"∞";
    
    if (ms >= HOURS) {
        if (ms == 1*HOURS) return @"1 hour";
        if (ms % (int)HOURS == 0) return nsprintf(@"%d hours", ms / (int)HOURS);
        if (ms > 1*HOURS) return formatSeconds(ms/SECONDS, @"%dh %dm");
    }
    
    else if (ms >= MINUTES) {
        if (ms == 1*MINUTES) return @"1 min";
        if (ms % (int)MINUTES == 0) return nsprintf(@"%d mins", ms / (int)MINUTES);
        if (ms > 1*MINUTES) return formatSeconds(ms/SECONDS, @"%d:%d:%.1f");
    }
    
    else {
        if (ms == 1*SECONDS) return @"1 sec";
        if (ms % (int)SECONDS == 0) return nsprintf(@"%d secs", ms / (int)SECONDS);
        if (ms > 1*SECONDS) return nsprintf(@"%.1f secs", ms / SECONDS);
    }
    
    return nsprintf(@"%d ms", ms);
}

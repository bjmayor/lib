//
//  HaloDefine.h
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#ifndef HaloDefine_h
#define HaloDefine_h

#define KGap 10
#define KNilString @""

//could define it in your project
#define HaloDebugEnable 

#define RADIANS(degrees)((degrees  *M_PI)/ 180.0)

struct WordLimit {
    NSInteger minLength;
    NSInteger maxLength;
};
typedef struct WordLimit WordLimit;

CG_INLINE WordLimit
WordLimitMake(NSInteger minLength,NSInteger maxLength)
{
    WordLimit limit;
    limit.minLength = minLength;
    limit.maxLength = maxLength;
    return limit;
}

#endif

//
//  ETLThumb.h
//  ETL
//
//  Created by Carll Hoffman on 8/28/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETLThumb : NSObject

- (id)initWithSize:(CGFloat)size;

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) bool highlighted;
@property (nonatomic, strong) CALayer *layer;

@end

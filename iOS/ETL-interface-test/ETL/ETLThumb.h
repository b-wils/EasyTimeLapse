//
//  ETLThumb.h
//  ETL
//
//  Created by Carll Hoffman on 8/28/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETLThumb : UIView

- (id)initWithSize:(CGFloat)size;
- (void)render;

@property (nonatomic, assign) CGPoint position;

@end

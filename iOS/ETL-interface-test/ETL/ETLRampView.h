//
//  ETLRampView.h
//  ETL
//
//  Created by Carll Hoffman on 8/26/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface ETLRampView : UIView

@property (nonatomic, assign) NSUInteger easeIn;
@property (nonatomic, assign) NSUInteger easeOut;
@property (nonatomic, assign) NSUInteger initial;
@property (nonatomic, assign) NSUInteger final;

@end

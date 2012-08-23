//
//  ADVPercentProgressBar.h
//  prolific
//
//  Created by Tope on 05/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ADVPercentProgressBar : UIView {
@private
    
    UIView* percentView;    
    
    UIImageView *bgImageView;
    
    UIImageView *progressImageView;
    
    UIImage *progressFillImage;
}

@property (nonatomic, readwrite, assign) CGFloat progress;

@end

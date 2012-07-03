//
//  ADVPercentProgressBar.m
//  prolific
//
//  Created by Tope on 05/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define LEFT_PADDING 5.0f
#define RIGHT_PADDING 3.0f

#import "ADVPercentProgressBar.h"
#import "ETLAppDelegate.h"

@implementation ADVPercentProgressBar

@synthesize progress;


- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        ColorSwitcher* switcher = [[ETLAppDelegate instance] colorSwitcher];
        progressFillImage = [switcher getImageWithName:@"progress-fill"];
                             
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        [bgImageView setImage:[UIImage imageNamed:@"progress_track.png"]];
        
        [self addSubview:bgImageView];
        
        progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 0, 0, frame.size.height)];
        
        [self addSubview:progressImageView];
        
        percentView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING, 6, 32, 17)];
        
        UIImageView* percentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 17)];
        
        [percentImageView setImage:[UIImage imageNamed:@"progress_count.png"]];
        
        UILabel* percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 17)];
        
        [percentLabel setTag:1];
        [percentLabel setText:@"0%"];
        [percentLabel setBackgroundColor:[UIColor clearColor]];
        [percentLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [percentLabel setTextAlignment:UITextAlignmentCenter];
        [percentLabel setAdjustsFontSizeToFitWidth:YES];
        
        [percentView addSubview:percentImageView];
        [percentView addSubview:percentLabel];
        
        [self addSubview:percentView];
        
        self.progress = 0.0f;
    }
    
    return self;
}


- (void)setProgress:(CGFloat)theProgress {
    
    if (self.progress != theProgress) {
        
        if (theProgress >= 0 && theProgress <= 1) {
            
            progress = theProgress;
            
            progressImageView.image = progressFillImage;
            
            CGRect frame = progressImageView.frame;
            
            frame.origin.x = 2;
            frame.origin.y = 2;
            frame.size.height = bgImageView.frame.size.height - 4;
            
            frame.size.width = (bgImageView.frame.size.width - 4) * progress;
            
            progressImageView.frame = frame;
            
            CGRect percentFrame = percentView.frame;
            
            float percentViewWidth = percentView.frame.size.width;
            float leftEdge = (progressImageView.frame.size.width - percentViewWidth) - RIGHT_PADDING;
            
            percentFrame.origin.x = (leftEdge < LEFT_PADDING) ? LEFT_PADDING : leftEdge;
            percentView.frame = percentFrame;
            
            UILabel* percentLabel = (UILabel*)[percentView viewWithTag:1];
            [percentLabel setText:[NSString  stringWithFormat:@"%d%%", (int)(progress*100)]];
            
        }
    }
}





@end

//
//  ADVPopoverProgressBar.m
//  ADVPopoverProgressBar
//
//
/*
 The MIT License
 
 Copyright (c) 2011 Tope Abayomi
 http://www.appdesignvault.com/
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#define LEFT_PADDING 5.0f
#define RIGHT_PADDING 3.0f
#define PERCENT_VIEW_WIDTH 32.0f
#define MIN_WIDTH 46.0f

#import "ADVPopoverProgressBar.h"
#import "ETLAppDelegate.h"

@implementation ADVPopoverProgressBar

@synthesize progress;


- (id)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame]) 
    {
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 32)];
        
        [bgImageView setImage:[UIImage imageNamed:@"progress_track.png"]];
        [self addSubview:bgImageView];
        
        ColorSwitcher* switcher = [[ETLAppDelegate instance] colorSwitcher];
        UIImage *imageFill = [switcher getImageWithName:@"progress-fill"];
        progressFillImage = [imageFill resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 35)];
        progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 0, 0, 19)];        
        [self addSubview:progressImageView];
        
        percentView = [[UIView alloc] initWithFrame:CGRectMake(2, 8, 
                                                               PERCENT_VIEW_WIDTH, 17)];
        percentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"progress_count.png"]];
        percentView.hidden = YES;
        
        UILabel* percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PERCENT_VIEW_WIDTH, 17)];        
        [percentLabel setTag:1];
        [percentLabel setText:@"0%"];
        [percentLabel setBackgroundColor:[UIColor clearColor]];
        [percentLabel setTextColor:[UIColor blackColor]];
        [percentLabel setFont:[UIFont boldSystemFontOfSize:11]];
        [percentLabel setTextAlignment:UITextAlignmentCenter];
        [percentLabel setAdjustsFontSizeToFitWidth:YES];        
        [percentView addSubview:percentLabel];
        
        [self addSubview:percentView];
        
        //self.progress = 0.0f;
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
            frame.size.height = bgImageView.frame.size.height - 5;
            CGFloat width = (bgImageView.frame.size.width - 4 - MIN_WIDTH) * progress;
            width += MIN_WIDTH;
            
            float percentage = progress*100;
            BOOL display = percentage == 0;
            
            frame.size.width = width;
            
            progressImageView.frame = CGRectIntegral(frame);
            progressImageView.hidden = display;
            
            float leftEdge = width - PERCENT_VIEW_WIDTH - 4;
            percentView.frame = CGRectIntegral(CGRectMake(leftEdge, percentView.frame.origin.y, PERCENT_VIEW_WIDTH, percentView.frame.size.height));
            
            UILabel* percentLabel = (UILabel*)[percentView viewWithTag:1];
            [percentLabel setText:[NSString  stringWithFormat:@"%d%%", (int)percentage]];
            percentView.hidden = display;
        }
    }
}


@end

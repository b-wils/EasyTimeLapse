//
//  ColourSwitcher.m
//  prolific
//
//  Created by Tope on 21/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColorSwitcher.h"

@implementation ColorSwitcher

@synthesize processedImages, modifiedImages, hue, saturation;

-(id)initWithScheme:(NSString*)scheme
{
    self = [super init];
    
    if(self)
    {
        hue = 0;
        saturation = 1;
        
        self.processedImages = [NSMutableDictionary dictionary];
        /*if([scheme isEqualToString:@"red"])
        {   
            [processedImages setObject:[UIImage imageNamed:@"menubar-red.png"] forKey:@"menubar"];
            [processedImages setObject:[UIImage imageNamed:@"menubar-button-red.png"] forKey:@"menubar-button"];            
            [processedImages setObject:[UIImage imageNamed:@"back-red.png"] forKey:@"back"];            
            [processedImages setObject:[UIImage imageNamed:@"slider-fill-red.png"] forKey:@"slider-fill"];
            [processedImages setObject:[UIImage imageNamed:@"tabbar-button-red.png"] forKey:@"tabbar-button"];
            [processedImages setObject:[UIImage imageNamed:@"progress-fill-red.png"] forKey:@"progress-fill"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-red-left.png"] forKey:@"segmented-control-left"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-red-middle.png"] forKey:@"segmented-control-middle"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-red-right.png"] forKey:@"segmented-control-right"];
            
            [processedImages setObject:[UIImage imageNamed:@"switch-on-red.png"] forKey:@"switch-on"];
            
        }
        else if([scheme isEqualToString:@"blue"])
        {
            / *[processedImages setObject:[UIImage imageNamed:@"menubar-blue.png"] forKey:@"menubar"];
            [processedImages setObject:[UIImage imageNamed:@"menubar-button-blue.png"] forKey:@"menubar-button"];            
            [processedImages setObject:[UIImage imageNamed:@"back-blue.png"] forKey:@"back"];            
            [processedImages setObject:[UIImage imageNamed:@"slider-fill-blue.png"] forKey:@"slider-fill"];
            [processedImages setObject:[UIImage imageNamed:@"tabbar-button-blue.png"] forKey:@"tabbar-button"];*/
            [processedImages setObject:[UIImage imageNamed:@"progress_fill.png"] forKey:@"progress-fill"];
            /*[processedImages setObject:[UIImage imageNamed:@"segmented-control-blue-left.png"] forKey:@"segmented-control-left"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-blue-middle.png"] forKey:@"segmented-control-middle"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-blue-right.png"] forKey:@"segmented-control-right"];
            [processedImages setObject:[UIImage imageNamed:@"switch-on-blue.png"] forKey:@"switch-on"];* /
        }
        else if([scheme isEqualToString:@"brown"])
        {
            [processedImages setObject:[UIImage imageNamed:@"menubar-brown.png"] forKey:@"menubar"];
            [processedImages setObject:[UIImage imageNamed:@"menubar-button-brown.png"] forKey:@"menubar-button"];            
            [processedImages setObject:[UIImage imageNamed:@"back-brown.png"] forKey:@"back"];            
            [processedImages setObject:[UIImage imageNamed:@"slider-fill-brown.png"] forKey:@"slider-fill"];
            [processedImages setObject:[UIImage imageNamed:@"tabbar-button-brown.png"] forKey:@"tabbar-button"];
            [processedImages setObject:[UIImage imageNamed:@"progress-fill-brown.png"] forKey:@"progress-fill"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-brown-left.png"] forKey:@"segmented-control-left"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-brown-middle.png"] forKey:@"segmented-control-middle"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-brown-right.png"] forKey:@"segmented-control-right"];
            [processedImages setObject:[UIImage imageNamed:@"switch-on-brown.png"] forKey:@"switch-on"];
        }
        else if([scheme isEqualToString:@"green"])
        {   
            [processedImages setObject:[UIImage imageNamed:@"menubar-green.png"] forKey:@"menubar"];
            [processedImages setObject:[UIImage imageNamed:@"menubar-button-green.png"] forKey:@"menubar-button"];            
            [processedImages setObject:[UIImage imageNamed:@"back-green.png"] forKey:@"back"];            
            [processedImages setObject:[UIImage imageNamed:@"slider-fill-green.png"] forKey:@"slider-fill"];
            [processedImages setObject:[UIImage imageNamed:@"tabbar-button-green.png"] forKey:@"tabbar-button"];
            [processedImages setObject:[UIImage imageNamed:@"progress-fill-green.png"] forKey:@"progress-fill"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-green-left.png"] forKey:@"segmented-control-left"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-green-middle.png"] forKey:@"segmented-control-middle"];
            [processedImages setObject:[UIImage imageNamed:@"segmented-control-green-right.png"] forKey:@"segmented-control-right"];
            [processedImages setObject:[UIImage imageNamed:@"switch-on-green.png"] forKey:@"switch-on"];
        
        }*/
        
    }
    
    return self;
}


-(UIImage*)processImage:(UIImage*)originalImage withKey:(NSString*)key
{

    UIImage* existingImage = [modifiedImages objectForKey:key];
    
    if(existingImage)
    {
        return existingImage;
    }
    else if (hue == 0 && saturation == 1)
    {
        return originalImage;
    }
    
    
    CIImage *beginImage = [CIImage imageWithData:UIImagePNGRepresentation(originalImage)];
    
    CIContext* context = [CIContext contextWithOptions:nil];
    
    CIFilter* hueFilter = [CIFilter filterWithName:@"CIHueAdjust" keysAndValues:kCIInputImageKey, beginImage, @"inputAngle", [NSNumber numberWithFloat:hue], nil];
    
    CIImage *outputImage = [hueFilter outputImage];
    
    CIFilter* saturationFilter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, outputImage, @"inputSaturation", [NSNumber numberWithFloat:saturation], nil];
    
    outputImage = [saturationFilter outputImage];
    
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    
    UIImage *processed;
    if ( [[[UIDevice currentDevice] systemVersion] intValue] >= 4 && [[UIScreen mainScreen] scale] == 2.0 )
    {
        processed = [UIImage imageWithCGImage:cgimg scale:2.0 orientation:UIImageOrientationUp]; 
    }
    else
    {
        processed = [UIImage imageWithCGImage:cgimg]; 
    }
    
    CGImageRelease(cgimg);
    
    [modifiedImages setObject:processed forKey:key];
    
    return processed;

}



-(UIImage*)getImageWithName:(NSString*)imageName
{
    UIImage* image = [processedImages objectForKey:imageName];
    
    return [self processImage:image withKey:imageName];
}



@end

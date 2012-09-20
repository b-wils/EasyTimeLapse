//
//  ETLValueSelector.m
//  ETL
//
//  Created by Carll Hoffman on 9/16/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLValueSelector.h"
#import "ETLUtil.h"

@interface ETLValueSelector ()
{
    UIButton *button;
    UILabel *titleLabel;
    UILabel *valueLabel;
}

@end

@implementation ETLValueSelector

@synthesize title, value, color, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.frame;
    button.bounds = self.bounds;
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 3, 110, 27)];
    titleLabel.textAlignment = UITextAlignmentLeft;
    titleLabel.font = [UIFont fontWithName:@"Futura" size:22];
    titleLabel.opaque = false;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 23, 110, 27)];
    valueLabel.textAlignment = UITextAlignmentLeft;
    valueLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:22];
    valueLabel.opaque = false;
    valueLabel.backgroundColor = [UIColor clearColor];
    
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [self addSubview:titleLabel];
    [self addSubview:valueLabel];
}

- (void)setTitle:(NSString *)val
{
    title = val;
    titleLabel.text = val;
}

- (void)setValue:(id)val
{
    value = val;
    valueLabel.text = nsprintf(@"%@", val);
    
    [value addObserver:self 
            forKeyPath:@"rawValue" 
               options:NSKeyValueObservingOptionNew
               context:nil];
    [value addObserver:self
            forKeyPath:@"unit"
               options:NSKeyValueObservingOptionNew
               context:nil];
}

- (void)setColor:(UIColor *)val
{
    color = val;
    titleLabel.textColor = val;
}

- (void)didTapButton:(id)sender
{
    [delegate didSelectValue:self];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    valueLabel.text = nsprintf(@"%@", object);
}
@end

@implementation ETLBounds
@synthesize lower, upper;
@end

@implementation ETLUnitScaleValue
@synthesize rawValue, bounds, unit, unitList, scaledValue;
@end

@implementation ETLShortTimeValue
- (NSInteger)millis 
{
    return [self.rawValue unsignedIntegerValue];
}

- (void)setMillis:(NSInteger)val
{
    self.rawValue = nint(val);
}

//- (NSNumber *)scaledValue
//{
////    NSUInteger ms = self.rawValue.unsignedIntegerValue;
////    if ([self.unit isEqualToString:@"seconds"]) {
////        ms /= SECONDS;
////    }
////    if ([self.unit isEqualToString:@"minutes"]) {
////        ms /= MINUTES;
////    }
////    if ([self.unit isEqualToString:@"hours"]) {
////        ms /= HOURS;
////    }
////    if ([self.unit isEqualToString:@"days"]) {
////        ms /= 24*HOURS;
////    }
////    
////    return nint(ms);
//    return scaledValue;
//}

- (void)setScaledValue:(NSNumber *)val
{
    NSUInteger ms = val.unsignedIntegerValue;
    if ([self.unit isEqualToString:@"seconds"]) {
        ms *= SECONDS;
    }
    if ([self.unit isEqualToString:@"minutes"]) {
        ms *= MINUTES;
    }
    if ([self.unit isEqualToString:@"hours"]) {
        ms *= HOURS;
    }
    if ([self.unit isEqualToString:@"days"]) {
        ms *= 24*HOURS;
    }
    [super setScaledValue:val];
    self.millis = ms;
}

- (NSString *)description
{
//    return msToEnglish(self.millis);
    return nsprintf(@"%.0f %@", self.scaledValue.floatValue, self.unit);
}


@end

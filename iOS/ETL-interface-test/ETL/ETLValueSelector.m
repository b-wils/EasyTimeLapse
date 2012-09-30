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
            forKeyPath:@"scaledValue"
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
    self.rawValue = nbig(val);
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

- (void)setRawValue:(NSNumber *)val
{
    [super setRawValue:val];
    
    double t = val.doubleValue;
    if ([self.unit isEqualToString:@"seconds"]) {
        t /= SECONDS;
    }
    if ([self.unit isEqualToString:@"minutes"]) {
        t /= MINUTES;
    }
    if ([self.unit isEqualToString:@"hours"]) {
        t /= HOURS;
    }
    if ([self.unit isEqualToString:@"days"]) {
        t /= 24*HOURS;
    }

    [super setScaledValue:ndouble(t)];
}

- (void)setScaledValue:(NSNumber *)val
{
    double ms = val.doubleValue;
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
    self.millis = ms + 0.5;
}

- (NSString *)description
{
    NSNumber *test = ndouble(15.111);
    double testV = test.doubleValue;
    
    printf("%f\n", testV);
    
    double val = self.scaledValue.doubleValue;
    if (val == INFINITY || [self.unit isEqualToString:@"forever"]) {
        return self.unit;
    }
    else {
//        int precision = 2;
//        
//        if ([self.unit isEqualToString:@"ms"]) precision = 0;
//        else if ([self.unit isEqualToString:@"seconds"]) precision = 3;
//        
//        double val = self.scaledValue.doubleValue;
//        for(; precision > 0; precision--)
//        {
//            double v = val * pow(10, precision - 1);
//            double x = fmod(v, 1);
//            if (x < 0.999 && x > EPSILON) break;
//        }
        int precision = 0;
        
        return nsprintf(@"%.*f %@", precision, self.scaledValue.doubleValue, self.unit);
    }
}

- (void)consolidateValue
{
    NSUInteger ms = self.millis;
    NSString *u;
    double t = ms;

    if (ms > 24*HOURS) {
        u = @"days";
        t /= 24*HOURS;
    }
    else if (ms > HOURS) {
        u = @"hours";
        t /= HOURS;
    }
    else if (ms > MINUTES) {
        u = @"minutes";
        t /= MINUTES;
    }
    else if (ms > SECONDS) {
        u = @"seconds";
        t /= SECONDS;
    }
    else {
        u = @"ms";
    }
    
//    self.scaledValue = ndouble(t);
    [super setScaledValue:ndouble(t)];
    self.unit = u;
}

@end

@implementation ETLSimpleValue

- (void)setScaledValue:(NSNumber *)val
{
    [super setScaledValue:val];
//    [self setValue:val forKey:@"rawValue"];
//    self.rawValue = val;
    [super setRawValue:val];
}

- (void)setRawValue:(NSNumber *)val
{
    [super setRawValue:val];
//    [self setValue:val forKey:@"scaledValue"];
    [super setScaledValue:val];
}

- (NSString *)description
{
    return nsprintf(@"%ld", self.rawValue.unsignedIntValue);
}

@end

//
//  ETLUnitKeypad.m
//  ETL
//
//  Created by Carll Hoffman on 9/17/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLUnitKeypad.h"
#import "ETLUtil.h"

@interface ETLUnitKeypad ()
{
    UIButton *valueLabel;
    struct {
        int intPart;
        int fractionalPart;
        int numFractionalDigits;
        int maxFractionalDigits;
        bool trailingDecimal;
        int trailingZeros;
    } state;
}
@end

@implementation ETLUnitKeypad

@synthesize value;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

const int bWidth = 74;
const int bHeight = 45;
const CGPoint numpadOffset = (CGPoint){68, 68};

- (UIButton *)createButtonAt:(int)row :(int)col
{
    UIImage *downBackground = [UIImage imageNamed:@"pressed.png"]; 
    UIFont *buttonFont = [UIFont fontWithName:@"Futura" size:22];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(numpadOffset.x + bWidth * col, numpadOffset.y + bHeight * row, 74, 45);
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    button.titleLabel.font = buttonFont;
    [button setTitleColor:[UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:1] forState:UIControlStateNormal];
    [button setBackgroundImage:downBackground forState:UIControlStateHighlighted];
//    button.backgroundColor = [UIColor clearColor];
//    [button setImage:downBackground forState:UIControlStateNormal];
    
    [self addSubview:button];
    
    return button;
}

- (void)setupNumpad
{
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keypad.png"]];
    background.frame = (CGRect){numpadOffset, {bWidth*3, bHeight*4}};
    [self addSubview:background];
    
    UIButton *button;
    int row, col;
    for (int i = 1; i <= 9; i++) {
        row = (i - 1)/3;
        col = (i - 1)%3;
        button = [self createButtonAt :row :col];
        button.allTitles = [NSString stringWithFormat:@"%d", i];
        [button addTarget:self action:@selector(didPressNumber:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
    }
    
    button = [self createButtonAt :3 :0];
    button.allTitles = @".";
    [button addTarget:self action:@selector(didPressDecimal:) forControlEvents:UIControlEventTouchUpInside];
    
    button = [self createButtonAt :3 :1];
    button.allTitles = @"0";
    [button addTarget:self action:@selector(didPressNumber:) forControlEvents:UIControlEventTouchUpInside];
    
    button = [self createButtonAt :3 :2];
    [button setImage:[UIImage imageNamed:@"keypad_del.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didPressBackspace:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupView 
{
    [self setupNumpad];
//    valueLabel = [[UIButton alloc] initWithFrame:CGRectMake(numpadOffset.x, numpadOffset.y - 40, bWidth * 3, 40)];
    valueLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    valueLabel.frame = CGRectMake(numpadOffset.x, numpadOffset.y - 40, bWidth * 3, 40);
    valueLabel.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:40];
    [valueLabel setTitleColor:[UIColor colorWithRed:47.0/255 green:47.0/255 blue:47.0/255 alpha:1] forState:UIControlStateNormal];
    valueLabel.backgroundColor = [UIColor clearColor];
//    valueLabel.titleLabel.textAlignment = UITextAlignmentRight;
    [valueLabel.titleLabel setAdjustsFontSizeToFitWidth:true];
    [valueLabel addTarget:self.superview action:@selector(showUnitMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:valueLabel];
}

- (void)setUnit:(NSString *)val 
{
    if ([val isEqualToString:@"ms"]) state.maxFractionalDigits = 0;
    else if ([val isEqualToString:@"seconds"]) state.maxFractionalDigits = 3;
    else state.maxFractionalDigits = 2;
}

- (void)displayValue
{
    double whole;
    double fraction = modf(value.scaledValue.doubleValue, &whole);
    
    state.intPart = (int)whole;
    state.fractionalPart = (fraction * pow(10, state.maxFractionalDigits) + 0.5);
    int multiple = pow(10.0, state.maxFractionalDigits);
    if (state.maxFractionalDigits > 0 && fraction >= 1.0/multiple) {
        double f = fraction;
        int numZeros = 0, numTrailingZeros = 0;
        while (f*10 < (1 - EPSILON)) {
            numZeros++;
            f *= 10;
            multiple /= 10;
        }
        int frac = (int)(f * multiple + 0.5);
        while (frac % 10 == 0) { 
            numTrailingZeros++;
            frac /= 10;
        }
        
        state.fractionalPart /= pow(10, numTrailingZeros);
        state.numFractionalDigits = MIN(state.maxFractionalDigits, state.maxFractionalDigits - numTrailingZeros);
        
        NSString *fill = [@"" stringByPaddingToLength:state.trailingZeros withString:@"0" startingAtIndex:0];
        valueLabel.allTitles = nsprintf(@"%.*f%@ %@", state.numFractionalDigits, value.scaledValue.doubleValue, fill, value.unit);
    }
    else {
        state.numFractionalDigits = 0;
        if (state.trailingDecimal || state.trailingZeros > 0) {
            NSString *fill = [@"" stringByPaddingToLength:state.trailingZeros withString:@"0" startingAtIndex:0];
            valueLabel.allTitles = nsprintf(@"%d.%@ %@", state.intPart, fill, value.unit);
        }
        else {
            valueLabel.allTitles = nsprintf(@"%d %@", state.intPart, value.unit);
        }
    }
}

- (void)setValue:(ETLUnitScaleValue *)val
{
    [value removeObserver:self forKeyPath:@"scaledValue"];
    [value removeObserver:self forKeyPath:@"unit"];
    value = val;
    [value addObserver:self forKeyPath:@"scaledValue" options:NSKeyValueObservingOptionNew context:nil];
    [value addObserver:self forKeyPath:@"unit" options:NSKeyValueObservingOptionNew context:nil];
    
    state.trailingDecimal = false;
    
    [self setUnit:value.unit];
    [self displayValue];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == value) {
        if([keyPath isEqualToString:@"unit"]) [self setUnit:value.unit];
        [self displayValue];
    }
}

- (void)didPressNumber:(id)sender
{
    double d = [[sender titleLabel].text intValue];
    int idx = state.numFractionalDigits + state.trailingZeros;
    bool padded = state.trailingDecimal || state.trailingZeros > 0;
    bool inLengthRange = idx > 0 && idx < state.maxFractionalDigits;
    
    if ((padded || inLengthRange) && idx < state.maxFractionalDigits) {
        if (d == 0) {
            state.trailingZeros += 1;
            [self displayValue];
            return;
        }
        
        double fraction = d / pow(10, 1 + idx); //state.numFractionalDigits);
        fraction += value.scaledValue.doubleValue;
        state.trailingDecimal = false;
        state.trailingZeros = 0;
        
        value.scaledValue = ndouble(fraction);
    }
    else if (state.numFractionalDigits == 0) {
        value.scaledValue = nint(state.intPart * 10 + (int)d); 
    }
}

- (void)didPressDecimal:(id)sender
{
    state.trailingDecimal = true;
    [self displayValue];
}

- (void)didPressBackspace:(id)sender
{
    if (state.trailingZeros > 0) {
        state.trailingZeros--;
        [self displayValue];
    }
    else if (!state.trailingDecimal) {
        if (state.fractionalPart > 0) { state.fractionalPart /= 10; }
        else { state.intPart /= 10; }
        
        double val = state.intPart;
        if (state.fractionalPart > 0) { val += state.fractionalPart/pow(10, state.numFractionalDigits - 1); }
        else { state.trailingZeros = MAX(0, state.numFractionalDigits - 1); }
        value.scaledValue = ndouble(val);
    }
    else {
        state.trailingDecimal = false;
        [self displayValue];
    }
}

@end

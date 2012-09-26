//
//  ETLValueSelector.h
//  ETL
//
//  Created by Carll Hoffman on 9/16/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ETLValueSelector;
@class ETLUnitScaleValue;

@protocol ETLValueSelectorDelegate <NSObject>
- (void)didSelectValue:(ETLValueSelector *)value;
@end

@interface ETLValueSelector : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) ETLUnitScaleValue *value;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) id <ETLValueSelectorDelegate> delegate;

@end

@interface ETLBounds : NSValue
@property (nonatomic, strong) NSNumber *lower;
@property (nonatomic, strong) NSNumber *upper;
@end

@interface ETLUnitScaleValue : NSObject

@property (nonatomic, strong) NSNumber *rawValue;
@property (nonatomic, strong) NSNumber *scaledValue;
@property (nonatomic, strong) NSString *unit;
//@property (nonatomic, assign) bool bounded;
@property (nonatomic, readonly) NSArray *unitList;
@property (nonatomic, strong) ETLBounds *bounds;

//- (NSNumber *)scaledValue;
//- (void)setScaledValue:(NSNumber *)val;
@end

@interface ETLShortTimeValue : ETLUnitScaleValue
//@property (nonatomic, strong) NSNumber *scaledValue;
@property (nonatomic) NSInteger millis;
- (void)consolidateValue;
@end

@interface ETLSimpleValue : ETLUnitScaleValue
@end
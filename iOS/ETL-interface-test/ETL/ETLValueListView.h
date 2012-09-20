//
//  ETLValueListView.h
//  ETL
//
//  Created by Carll Hoffman on 9/17/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETLValueSelector.h"

@protocol ETLValueListDelegate <NSObject>
- (void)didSelectValue:(ETLValueSelector *)val;
@end

@interface ETLValueListView : UIView <ETLValueSelectorDelegate>

- (ETLValueSelector *)addItemNamed:(NSString *)name withValue:(ETLUnitScaleValue *)value;

@property (nonatomic, strong) id<ETLValueListDelegate> delegate;

@end

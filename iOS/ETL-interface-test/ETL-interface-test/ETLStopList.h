//
//  ETLStopList.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLModel.h"

@protocol ETLStopListDelegate <NSObject>
-(void)didSelectStop:(NSString *)name ofMs:(NSUInteger)millis;
@end

@interface ETLStopList : ETLModel <UIPickerViewDataSource, UIPickerViewDelegate>
-(NSString *)getStopForMs:(NSUInteger)ms;
-(NSUInteger)getStopNumberFor:(NSString *)name;
-(NSUInteger)count;
-(NSString *)getStopNumber:(NSUInteger)index;
-(NSUInteger)getMsForStop:(NSString *)name;
-(NSString *)getClosestStopToMs:(NSUInteger)ms;

@property (nonatomic, strong) id <ETLStopListDelegate> delegate;
@end

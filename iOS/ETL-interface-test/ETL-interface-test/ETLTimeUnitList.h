//
//  ETLTimeUnitList.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLPickerList.h"

@protocol ETLTimeUnitListDelegate <NSObject>
-(void)didSelectUnit:(NSString *)name ofMs:(NSUInteger)millis;
@end

@interface ETLTimeUnitList : ETLPickerList
-(NSString*)getUnitByNumber:(NSUInteger)index;
-(NSUInteger)getNumberOfUnit:(NSString*)name;
-(NSUInteger)msInUnit:(NSString *)name;

@property (nonatomic, strong) id <ETLTimeUnitListDelegate> delegate;
@end

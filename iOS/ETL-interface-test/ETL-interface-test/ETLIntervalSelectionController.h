//
//  ETLIntervalSelectionController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETLViewController.h"
#import "ETLTimeUnitList.h"

@protocol ETLIntervalSelectionDelegate <NSObject>
- (void)didUpdateInterval:(NSUInteger)ms forSelection:(id)sender;
@end

#define InitIntervalSelection(name) {__macroFlag = true; name = [[ETLIntervalSelectionController alloc] initWithInputField:name##Field unitButton:name##Button andParent:self];}

@interface ETLIntervalSelectionController : ETLModel <ETLTimeUnitListDelegate>
- (id)initWithInputField:(UITextField *)field unitButton:(UIButton *)units andParent:(ETLViewController *)controller;

@property (nonatomic, strong) ETLViewController <ETLIntervalSelectionDelegate> *parent;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, assign) NSUInteger interval;
@end

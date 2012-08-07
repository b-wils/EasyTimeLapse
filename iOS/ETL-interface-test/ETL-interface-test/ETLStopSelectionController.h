//
//  ETLStopSelectionController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/6/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLModel.h"
#import "ETLViewController.h"
#import "ETLStopList.h"

@protocol ETLStopSelectionDelegate <NSObject>
- (void)didUpdateStop:(NSUInteger)ms forSelection:(id)sender;
@end

@interface ETLStopSelectionController : ETLModel <ETLStopListDelegate>
- (id)initWithInputField:(UITextField *)field stopButton:(UIButton *)stops andParent:(ETLViewController <ETLStopSelectionDelegate> *)controller;

@property (nonatomic, strong) ETLViewController <ETLStopSelectionDelegate> *parent;
@property (nonatomic, assign) NSUInteger duration;
@property (nonatomic, assign) bool msMode;
@end

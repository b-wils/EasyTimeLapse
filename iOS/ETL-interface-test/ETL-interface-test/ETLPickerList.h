//
//  ETLPickerList.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLModel.h"

@interface ETLPickerList : ETLModel <UIPickerViewDataSource, UIPickerViewDelegate>
- (void)didSelectItem:(id)item;

@property (nonatomic, strong) NSArray *listItems;
@end

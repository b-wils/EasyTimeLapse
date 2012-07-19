//
//  ETLShot.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 7/19/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLModel.h"
#import "ETLProgrammer.h"

@interface ETLShot : ETLModel <PacketProvider>

-(void)add:(id <PacketProvider>)component;

@end

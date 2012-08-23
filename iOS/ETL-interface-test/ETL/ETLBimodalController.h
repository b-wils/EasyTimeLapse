//
//  ETLBimodalController.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 8/1/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import "ETLShotViewController.h"
#import "ETLIntervalSelectionController.h"

@interface ETLBimodalController : ETLShotViewController <UITextFieldDelegate, ETLIntervalSelectionDelegate, PacketProvider>
{
    IBOutlet UITextField *intervalAField;
    IBOutlet UITextField *intervalBField;
    IBOutlet UIButton *intervalAButton;
    IBOutlet UIButton *intervalBButton;
}
@end

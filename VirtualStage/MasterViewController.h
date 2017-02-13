//
//  MasterViewController.h
//  VirtualStage
//
//  Created by Yunhao Wan on 2/20/16.
//  Copyright © 2016 Yunhao Wan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StageView.h"

@interface MasterViewController : NSViewController<StageViewDelegate>

/**
 * @bfief let the player holded resource being released
 */
-(void)cleanUp;

@end

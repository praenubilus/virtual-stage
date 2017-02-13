//
//  AppDelegate.m
//  VirtualStage
//
//  Created by Yunhao Wan on 2/20/16.
//  Copyright © 2016 Yunhao Wan. All rights reserved.
//


#import "AppDelegate.h"
#include "MasterViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    
    self.masterViewController = [[MasterViewController alloc]
                                 initWithNibName:@"MasterViewController"
                                 bundle:nil];
    
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView*)self.window.contentView).bounds;
    
    //added for key cap
    [self.window makeFirstResponder:self.masterViewController.view];
}

/**
 * @brief   Before the application terminate, masterview will do cleanup works
 */
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.masterViewController cleanUp];
}

/**
 * @brief   implement this function and return YES will force the app to terminate as long as
 *          the window has been closed
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

@end

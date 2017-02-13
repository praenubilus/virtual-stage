//
//  StageView.h
//  VirtualStage
//
//  Created by Yunhao Wan on 4/5/16.
//  Copyright © 2016 Yunhao Wan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StageObjectType.h"

#define kTouchDistanceThreshhold 45.


@protocol StageViewDelegate <NSObject>
@required
-(void) repositionObject:(StageObject)stageObj to:(CGPoint)position;
@end

@interface StageView : NSView

{
    // Various layers we use to represent things in the sound stage
    CALayer						*_draggingLayer;
    CALayer						*_listenerLayer;
    CALayer                     *_guitarOneLayer;
    CALayer                     *_guitarTwoLayer;
    CALayer                     *_bassLayer;
    CALayer                     *_drumLayer;
    CALayer                     *_vocalLayer;
    
}

@property (nonatomic, weak) id <StageViewDelegate> delegate;

@property (nonatomic, assign)	CGPoint		guitarOnePos;			// The coordinates of the sound source
@property (nonatomic, assign)	CGPoint		guitarTwoPos;			// The coordinates of the sound source
@property (nonatomic, assign)	CGPoint		bassPos;			// The coordinates of the sound source
@property (nonatomic, assign)	CGPoint		drumPos;			// The coordinates of the sound source
@property (nonatomic, assign)	CGPoint		vocalPos;			// The coordinates of the sound source
@property (nonatomic, assign)	CGPoint		listenerPos;		// The coordinates of the listener

/**
 * @discussion initialization of the stage view
 */
- (void)initializeContents;

-(double)getDistanceFromListener:(StageObject)soundSourceObject;

-(void)expModeOn;

-(void)expObjectOnOffSwitch:(StageObject)stageObject;
@end

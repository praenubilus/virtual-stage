//
//  StageView.m
//  VirtualStage
//
//  Created by Yunhao Wan on 4/5/16.
//  Copyright © 2016 Yunhao Wan. All rights reserved.
//

#import "StageView.h"
#import <QuartzCore/QuartzCore.h>

// A function to bring an outlying point into the bounds of a rectangle,
// so that it is as close as possible to its original outlying position.
static inline CGPoint CGPointWithinBounds(CGPoint point, CGRect bounds)
{
    CGPoint ret = point;
    if (ret.x < CGRectGetMinX(bounds)) ret.x = CGRectGetMinX(bounds);
    else if (ret.x > CGRectGetMaxX(bounds)) ret.x = CGRectGetMaxX(bounds);
    if (ret.y < CGRectGetMinY(bounds)) ret.y = CGRectGetMinY(bounds);
    else if (ret.y > CGRectGetMaxY(bounds)) ret.y = CGRectGetMaxY(bounds);
    return ret;
}

@implementation StageView
CGFloat iconSize = 64;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)awakeFromNib{
    // entrance point of NSView
}


#pragma mark View contents

- (void)initializeContents
{
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"listener" ofType:@"png"]];
    CGImageRef listenerImg = [[NSBitmapImageRep imageRepWithData:data] CGImage];
    
    data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guitar1" ofType:@"png"]];
    CGImageRef guitarOneImg = [[NSBitmapImageRep imageRepWithData:data] CGImage];

    data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guitar2" ofType:@"png"]];
    CGImageRef guitarTwoImg = [[NSBitmapImageRep imageRepWithData:data] CGImage];
    
    data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bass" ofType:@"png"]];
    CGImageRef bassImg = [[NSBitmapImageRep imageRepWithData:data] CGImage];
    
    data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vocal" ofType:@"png"]];
    CGImageRef vocalImg = [[NSBitmapImageRep imageRepWithData:data] CGImage];
    
    data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"drum" ofType:@"png"]];
    CGImageRef drumImg = [[NSBitmapImageRep imageRepWithData:data] CGImage];
    
    
    // Set up the CALayer which shows the guitar one
    _guitarOneLayer = [CALayer layer];
    _guitarOneLayer.frame = CGRectMake(0., 0., iconSize, iconSize);
    _guitarOneLayer.contents = (__bridge id)guitarOneImg;
    
    // Set up the CALayer which shows the
    _guitarTwoLayer = [CALayer layer];
    _guitarTwoLayer.frame = CGRectMake(0., 0., iconSize, iconSize);
    _guitarTwoLayer.contents = (__bridge id)guitarTwoImg;
    
    // Set up the CALayer which shows the
    _bassLayer = [CALayer layer];
    _bassLayer.frame = CGRectMake(0., 0., iconSize, iconSize);
    _bassLayer.contents = (__bridge id)bassImg;
    
    // Set up the CALayer which shows the
    _drumLayer = [CALayer layer];
    _drumLayer.frame = CGRectMake(0., 0., iconSize, iconSize);
    _drumLayer.contents = (__bridge id)drumImg;
    
    // Set up the CALayer which shows the
    _vocalLayer = [CALayer layer];
    _vocalLayer.frame = CGRectMake(0., 0., iconSize, iconSize);
    _vocalLayer.contents = (__bridge id)vocalImg;
    
    // Set up the CALayer which shows the listener
    _listenerLayer = [CALayer layer];
    _listenerLayer.frame = CGRectMake(0., 0., CGImageGetWidth(listenerImg), CGImageGetHeight(listenerImg));
    _listenerLayer.contents = (__bridge id)listenerImg;
    _listenerLayer.anchorPoint = CGPointMake(0.5, 0.57);
    
    
    // Set the background image for the sound stage, main layer
    data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stagebg" ofType:@"png"]];
    CGImageRef bgImg = [[NSBitmapImageRep imageRepWithData:data] CGImage];

    self.layer = [CALayer layer];
    self.wantsLayer = YES;
    
    self.layer.contents = (__bridge id)bgImg;
    
    // Set a sublayerTransform on our view's layer. This causes (0,0) to be in the center of the view. This transform
    // is useful because now our view's coordinates map precisely to our oalPlayback sound environment's coordinates.
    CATransform3D trans = CATransform3DMakeTranslation([self frame].size.width / 2., [self frame].size.height / 2., 0.);
    self.layer.sublayerTransform = trans;
    
    // Add our sublayers
    [self.layer insertSublayer:_guitarOneLayer above:self.layer];
    [self.layer insertSublayer:_guitarTwoLayer above:self.layer];
    [self.layer insertSublayer:_bassLayer above:self.layer];
    [self.layer insertSublayer:_drumLayer above:self.layer];
    [self.layer insertSublayer:_vocalLayer above:self.layer];
    [self.layer insertSublayer:_listenerLayer above:self.layer];
    
    // Prevent things from drawing outside our layer bounds
    self.layer.masksToBounds = YES;
    
    self.guitarOnePos = CGPointMake(-200., -200.);
    self.drumPos = CGPointMake(-100., -200.);
    self.vocalPos = CGPointMake(0., -200.);
    self.guitarTwoPos = CGPointMake(100., -200);
    self.bassPos = CGPointMake(200., -200);
    
    [self layoutContents];
}

/**
 * @discussion Read the position value of all objects on the stage, and position them to appropriate point in the UI
 */
- (void)layoutContents{
    // layoutContents gets called via KVO whenever properties within our oalPlayback object change
    
    // Wrap these layer changes in a transaction and set the animation duration to 0 so we don't get implicit animation
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithDouble:0.] forKey:kCATransactionAnimationDuration];
    
    // Position the listener
    _listenerLayer.position = self.listenerPos;
    
    // Position the
    _guitarOneLayer.position = self.guitarOnePos;
    // Position the
    _guitarTwoLayer.position = self.guitarTwoPos;
    // Position the
    _vocalLayer.position = self.vocalPos;
    // Position the
    _drumLayer.position = self.drumPos;
    // Position the
    _bassLayer.position = self.bassPos;
    
    [CATransaction commit];
}


#pragma property getters and setters

/**
 * @discussion      setter for the guitar one position
 *
 * @param newPos    the target position
 */
-(void)setGuitarOnePos:(CGPoint)newPos{
    _guitarOnePos = newPos;
    [self.delegate repositionObject:GuitarOneObject to:newPos];
}

/**
 * @discussion      setter for the guitar two position
 *
 * @param newPos    the target position
 */
-(void)setGuitarTwoPos:(CGPoint)newPos{
    _guitarTwoPos = newPos;
    [self.delegate repositionObject:GuitarTwoObject to:newPos];
}

/**
 * @discussion      setter for the bass position
 *
 * @param newPos    the target position
 */
-(void)setBassPos:(CGPoint)newPos{
    _bassPos = newPos;
    [self.delegate repositionObject:BassObject to:newPos];
}

/**
 * @discussion      setter for the drum position
 *
 * @param newPos    the target position
 */
-(void)setDrumPos:(CGPoint)newPos{
    _drumPos = newPos;
    [self.delegate repositionObject:DrumObject to:newPos];
}

/**
 * @discussion      setter for the vocal position
 *
 * @param newPos    the target position
 */
-(void)setVocalPos:(CGPoint)newPos{
    _vocalPos = newPos;
    [self.delegate repositionObject:VocalObject to:newPos];
}

/**
 * @discussion      setter for the listener position
 *
 * @param newPos    the target position
 */
-(void)setListenerPos:(CGPoint)newPos{
    _listenerPos = newPos;
    [self.delegate repositionObject:ListenerObject to:newPos];
}


#pragma mark Events

/**
 * @discussion  The NSView coodinates in cocoa is different from the UIView in iOS. In 
 *              NSView, the (0, 0) point is at the left bottom of the view. However, in 
 *              UIView(iOS), the (0,0) point is at the left top of the view. Overwrite this
 *              method and return YES can make the NSView use the same coordinate system as 
 *              UIView being used in iOS.
 */
-(BOOL)isFlipped{
    return YES;
}

/**
 * @discussion      When an object in the Stage view has been clicked(Step 1) or dragged(Step 2) the actual location
 *                  will be set to the relative property variable.
 *
 * @param position  The target position to be set.
 */
- (void)touchPoint:(CGPoint)position
{
    if (_draggingLayer == _listenerLayer)
        self.listenerPos = position;
    else if (_draggingLayer == _guitarOneLayer)
        self.guitarOnePos = position;
    else if (_draggingLayer == _guitarTwoLayer)
        self.guitarTwoPos = position;
    else if (_draggingLayer == _vocalLayer)
        self.vocalPos = position;
    else if (_draggingLayer == _drumLayer)
        self.drumPos = position;
    else if (_draggingLayer == _bassLayer)
        self.bassPos = position;
    
    [self layoutContents];
    
}


/**
 * @discussion  First step of the UI interaction. which object and it's backend layer has been selected for mouse click/dragging
 *              will be decided.
 */
-(void)mouseDown:(NSEvent *)event{
    
    CGPoint pointInView = [self convertPoint:[event locationInWindow] fromView:nil];
    
    // Clip our pointInView to within 5 pixels of any edge, so we can't position objects near or beyond
    // the edge of the sound stage
    pointInView = CGPointWithinBounds(pointInView, CGRectInset([self bounds], 5., 5.));
    
    // Convert the view point to our layer / sound stage coordinate system, which is centered at (0,0)
    CGPoint pointInLayer = CGPointMake(pointInView.x - [self frame].size.width / 2., pointInView.y - [self frame].size.height / 2.);
    
    // Find out if the distance between the touch is within the tolerance threshhold for moving
    // the source object or the listener object
    if (hypot(self.guitarOnePos.x - pointInLayer.x, self.guitarOnePos.y - pointInLayer.y) < kTouchDistanceThreshhold && !_guitarOneLayer.isHidden){
        _draggingLayer = _guitarOneLayer;
    }else if (hypot(self.guitarTwoPos.x - pointInLayer.x, self.guitarTwoPos.y - pointInLayer.y) < kTouchDistanceThreshhold && !_guitarTwoLayer.isHidden){
        _draggingLayer = _guitarTwoLayer;
    }else if (hypot(self.bassPos.x - pointInLayer.x, self.bassPos.y - pointInLayer.y) < kTouchDistanceThreshhold && !_bassLayer.isHidden){
        _draggingLayer = _bassLayer;
    }else if (hypot(self.drumPos.x - pointInLayer.x, self.drumPos.y - pointInLayer.y) < kTouchDistanceThreshhold && !_drumLayer.isHidden){
        _draggingLayer = _drumLayer;
    }else if (hypot(self.vocalPos.x - pointInLayer.x, self.vocalPos.y - pointInLayer.y) < kTouchDistanceThreshhold && !_vocalLayer.isHidden){
        _draggingLayer = _vocalLayer;
    }else if (hypot(self.listenerPos.x - pointInLayer.x, self.listenerPos.y - pointInLayer.y) < kTouchDistanceThreshhold){
        _draggingLayer = _listenerLayer;
    }else{
        _draggingLayer = nil;
    }
    
    // Handle the touch
    [self touchPoint:pointInLayer];
}

/**
 * @discussion  Second step of the UI interaction. in this step, the coordinate location in the main window will be converted to
 *              the local view(stage view) coordination.
 */
-(void)mouseDragged:(NSEvent *)event{
    // Called repeatedly as the touch moves
    CGPoint pointInView = [self convertPoint:[event locationInWindow] fromView:nil];

    pointInView = CGPointWithinBounds(pointInView, CGRectInset([self bounds], 5., 5.));
    CGPoint pointInLayer = CGPointMake(pointInView.x - [self frame].size.width / 2., pointInView.y - [self frame].size.height / 2.);
    [self touchPoint:pointInLayer];
}

/**
 * @discussion  Third step of the UI interaction. after the dragging finished(mouse click released), the dragging layer will be
 *              set to nil for next operation.
 */
-(void)mouseUp:(NSEvent *)event{
    
    _draggingLayer = nil;
}


-(double)getDistanceFromListener:(StageObject)soundSourceObject{
    
    double distance = 1000;
    
    switch (soundSourceObject) {
        case GuitarOneObject:
            distance = [self getEuclideanDistBetween:self.listenerPos and:self.guitarOnePos];
            break;
        case GuitarTwoObject:
            distance = [self getEuclideanDistBetween:self.listenerPos and:self.guitarTwoPos];
            break;
        case DrumObject:
            distance = [self getEuclideanDistBetween:self.listenerPos and:self.drumPos];
            break;
        case VocalObject:
            distance = [self getEuclideanDistBetween:self.listenerPos and:self.vocalPos];
            break;
        case BassObject:
            distance = [self getEuclideanDistBetween:self.listenerPos and:self.bassPos];
            break;
        default:
            NSLog(@"Error! Unkown Object!");
            break;
    }
    
    return distance;
}

-(double)getEuclideanDistBetween:(CGPoint)positionOne and:(CGPoint)positionTwo{
    double nearestVal = 1000;
    
    nearestVal = sqrt(pow((positionOne.x-positionTwo.x),2.0)+pow((positionOne.y-positionTwo.y),2.0));
    
    return nearestVal;
}

-(void)expOnOffSwitch{
    [_guitarOneLayer setHidden:YES];
    
}

-(void)expObjectOnOffSwitch:(StageObject)stageObject{
    CALayer *retrievedLayer = [self retrieveLayerFrom:stageObject];
    if (retrievedLayer.isHidden == YES) {
        [retrievedLayer setHidden:NO];
    }else{
        [retrievedLayer setHidden:YES];
    }
    
}

-(id)retrieveLayerFrom:(StageObject)stageObject{
    CALayer *retrievedLayer;
    
    switch (stageObject) {
        case GuitarOneObject:
            retrievedLayer = _guitarOneLayer;
            break;
        case GuitarTwoObject:
            retrievedLayer = _guitarTwoLayer;
            break;
        case DrumObject:
            retrievedLayer = _drumLayer;
            break;
        case VocalObject:
            retrievedLayer = _vocalLayer;
            break;
        case BassObject:
            retrievedLayer = _bassLayer;
            break;
        default:
            NSLog(@"Error! Unkown Object!");
            break;
    }
    
    return retrievedLayer;
}

-(void)expModeOn{
    [_guitarOneLayer setHidden:YES];
    [_guitarTwoLayer setHidden:YES];
    [_drumLayer setHidden:YES];
    [_vocalLayer setHidden:YES];
    [_bassLayer setHidden:YES];

}

@end

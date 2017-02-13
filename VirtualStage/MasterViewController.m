//
//  MasterViewController.m
//  VirtualStage
//
//  Created by Yunhao Wan on 2/20/16.
//  Copyright © 2016 Yunhao Wan. All rights reserved.
//

#import "MasterViewController.h"
#import "OALSoftCPPWrapper.h"

#define kDefaultDistance 25.0

@interface MasterViewController ()
@property (nonatomic,strong) OALSoftCPPWrapper *player;
@property (weak) IBOutlet StageView *stageView;
@property (weak) IBOutlet NSSlider *guitarOneGain;
@property (weak) IBOutlet NSSlider *guitarTwoGain;
@property (weak) IBOutlet NSSlider *vocalGain;
@property (weak) IBOutlet NSSlider *drumGain;
@property (weak) IBOutlet NSSlider *bassGain;
@property (weak) IBOutlet NSSlider *masterPitchValue;
@property (weak) IBOutlet NSTextField *guitarOnePositionDisplay;
@property (weak) IBOutlet NSTextField *guitarTwoPositionDisplay;
@property (weak) IBOutlet NSTextField *vocalPositionDisplay;
@property (weak) IBOutlet NSTextField *drumPositionDisplay;
@property (weak) IBOutlet NSTextField *bassPositionDisplay;
@property (weak) IBOutlet NSTextField *listenerPositionDisplay;

@end

@implementation MasterViewController
CGPoint bassPos;
CGPoint drumPos;
CGPoint guitarOnePos;
CGPoint guitarTwoPos;
CGPoint vocalPos;
CGPoint listenerPos;
int counter;
double accumuDist = 0;
NSDate *startTime, *endTime;

/**
 * @brief   In this method, the player and the stage view will be initialized.
 *          And the stage view delegate will be set. The playback will also be 
 *          started from here.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.player = [[OALSoftCPPWrapper alloc] init];

    self.stageView.delegate = self;
    
    [self performSelectorInBackground:@selector(startPlayback) withObject:nil];
    
    [self.stageView initializeContents];
//    [self.stageView expModeOn];
    
}


-(void)cleanUp{
    [self setPlayer:nil];
}

/**
 * @discussion start the playback
 */
-(void)startPlayback{
    [_player startPlayback];
    
}

/**
 * @discussion          reposition a specific object on the stage to a given position
 * @param stageObject   The specific enumeration object on the stage
 * @param position      target CGPoint position to move to
 */
-(void)repositionObject:(StageObject)stageObject to:(CGPoint)position{
    NSInteger idx = [self getSourceIdxFromStageObject:stageObject];
    
    if (idx < 0) {
        [self.player repositionListenerWithX:position.x withY:0. withZ:position.y];
    } else {
        [self.player repositionSoundSourceAtIndex:idx withX:position.x withY:0. withZ:position.y];
    }
    
    NSString *positionStr = [NSString stringWithFormat:@"x:%.02f y:%.02f",position.x, position.y];
    
    switch (stageObject) {
        case BassObject:
            bassPos = position;
            self.bassPositionDisplay.stringValue = positionStr;
            break;
        case DrumObject:
            drumPos = position;
            self.drumPositionDisplay.stringValue = positionStr;
            break;
        case GuitarOneObject:
            guitarOnePos = position;
            self.guitarOnePositionDisplay.stringValue = positionStr;
            break;
        case GuitarTwoObject:
            guitarTwoPos = position;
            self.guitarTwoPositionDisplay.stringValue = positionStr;
            break;
        case VocalObject:
            vocalPos = position;
            self.vocalPositionDisplay.stringValue = positionStr;
            break;
        case ListenerObject:
            listenerPos = position;
            self.listenerPositionDisplay.stringValue = positionStr;
            break;
        default:
            NSLog(@"Error! Unkown ojbect moved.");
            break;
    }
}

/**
 * @discussion          return the index of a given stage object
 * @param stageObject   the specific stage object enumeration for lookup
 * @return              the looked up index of the specific stage object
 */
-(NSInteger)getSourceIdxFromStageObject:(StageObject)stageObject{
    NSUInteger idx = -1;
    
    switch (stageObject) {
        case BassObject:
            idx = 0;
            break;
        case DrumObject:
            idx = 1;
            break;
        case GuitarOneObject:
            idx = 2;
            break;
        case GuitarTwoObject:
            idx = 3;
            break;
        case VocalObject:
            idx = 4;
            break;
        case ListenerObject:
            idx = -1;
            break;
        default:
            NSLog(@"Error! Unkown ojbect moved.");
            break;
    }
    
    return idx;
}

/**
 * @discussion When the playback is playing, it will be paused(play->pause). Vice versa(pause->play)
 */
- (IBAction)playPausePlayback:(id)sender {
    if ([self.player isPlaying]) {
        [self.player pausePlayback];
    }else{
        [self performSelectorInBackground:@selector(startPlayback) withObject:nil];

        // When sound source paused, then resumed, all location info in openAL will lost. So we have to
        // restore all positions from last pause.
        [self repositionObject:BassObject to:bassPos];
        [self repositionObject:DrumObject to:drumPos];
        [self repositionObject:GuitarOneObject to:guitarOnePos];
        [self repositionObject:GuitarTwoObject to:guitarTwoPos];
        [self repositionObject:VocalObject to:vocalPos];
        [self repositionObject:ListenerObject to:listenerPos];
    }
}

/**
 * @discussion the action when the guitar one gain slider value has been changed
 */
- (IBAction)guitarOneGainValueChanged:(id)sender {
    
    float gain = [self.guitarOneGain floatValue];
    [self.player changeSourceGainAtIndex:[self getSourceIdxFromStageObject:GuitarOneObject] withValue:gain];
}

/**
 * @discussion the action when the guitar two gain slider value has been changed
 */
- (IBAction)guitarTwoGainChanged:(id)sender {
    float gain = [self.guitarTwoGain floatValue];
    [self.player changeSourceGainAtIndex:[self getSourceIdxFromStageObject:GuitarTwoObject] withValue:gain];
}

/**
 * @discussion the action when the vocal gain slider value has been changed
 */
- (IBAction)vocalGainChanged:(id)sender {
    float gain = [self.vocalGain floatValue];
    [self.player changeSourceGainAtIndex:[self getSourceIdxFromStageObject:VocalObject] withValue:gain];
}

/**
 * @discussion the action when the drum gain slider value has been changed
 */
- (IBAction)drumGainChanged:(id)sender {
    float gain = [self.drumGain floatValue];
    [self.player changeSourceGainAtIndex:[self getSourceIdxFromStageObject:DrumObject] withValue:gain];
}

/**
 * @discussion the action when the bass gain slider value has been changed
 */
- (IBAction)bassGainChanged:(id)sender {
    float gain = [self.bassGain floatValue];
    [self.player changeSourceGainAtIndex:[self getSourceIdxFromStageObject:BassObject] withValue:gain];
}

/**
 * @discussion the action when the master spitch slider value has been changed
 */
- (IBAction)masterPitchChanged:(id)sender {
    float pitchValue = [self.masterPitchValue floatValue];
    [self.player changeMasterPitchWithValue:pitchValue];
}


-(void)keyDown:(NSEvent *)theEvent{
//    double nearestDist = 1000;
    
//    if ([theEvent keyCode] == 49) {
    if ([theEvent keyCode] == 65535) {
        if (counter == 0){
            accumuDist += [self.stageView getDistanceFromListener:GuitarOneObject];
            startTime = [NSDate date];
            [self.stageView expObjectOnOffSwitch:GuitarOneObject];
        }else if(counter == 1){
            accumuDist += [self.stageView getDistanceFromListener:GuitarTwoObject];
            [self.stageView expObjectOnOffSwitch:GuitarTwoObject];
        }else if(counter == 2){
            accumuDist += [self.stageView getDistanceFromListener:DrumObject];
            [self.stageView expObjectOnOffSwitch:DrumObject];
        }else if(counter == 3){
            accumuDist += [self.stageView getDistanceFromListener:BassObject];
            [self.stageView expObjectOnOffSwitch:BassObject];
        }else if(counter == 4){
            accumuDist += [self.stageView getDistanceFromListener:VocalObject];
            [self.stageView expObjectOnOffSwitch:VocalObject];
        }else{
            //
        }
        counter++;
        
        if (counter > 4) {
            endTime = [NSDate date];
            NSTimeInterval totalTime = [endTime timeIntervalSinceDate:startTime];
            NSLog(@"executionTime: %f",totalTime);
        }
    }
    
    NSLog(@"Total dist:%f", accumuDist);
        
}




@end

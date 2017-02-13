//
//  OALSoftCPPWrapper.m
//  VirtualStage
//
//  Created by Yunhao Wan on 2/20/16.
//  Copyright © 2016 Yunhao Wan. All rights reserved.
//

#import "OALSoftCPPWrapper.h"
#import "OALSoftPlayer.hpp"

@interface OALSoftCPPWrapper ()
@property (nonatomic, readwrite, assign) OALSoft::Player *player;
@end

@implementation OALSoftCPPWrapper


-(id)init{
    self = [super init];
    if (self) {
        NSBundle* myBundle = [NSBundle mainBundle];
        NSArray* mySoundFiles = [myBundle pathsForResourcesOfType:@"wav"
                                                  inDirectory:nil];
        
        /*
         * The sequence of the sources based on the file name, currently it's
         * 1.bass, 2.drum 3.guitar 4.guitar2 5.vocal. Actually there is no guarantee
         * of the sequence. So in the future it's better to use another mechanism 
         * to load the wav file. Such as load each by exact name
         */
        
        std::string *sources = new std::string[5];
        
        NSUInteger count = [mySoundFiles count];
        
        for(int idx=0; idx<count; idx++) {
            sources[idx] = [[mySoundFiles objectAtIndex:idx] UTF8String];
        }
        
        _player = new OALSoft::Player((int)count,sources);
    }
    return self;
    
}

-(void)dealloc{
    delete _player;
}

-(void)startPlayback{
    _player->start();
}


-(void)pausePlayback{
    _player->pause();
}


-(bool)isPlaying{
    return _player->isPlaying();
}


-(void)repositionSoundSourceAtIndex:(NSInteger)index
                              withX:(float)xValue
                              withY:(float)yValue
                              withZ:(float)zValue{
    
    _player->repositionSoundSource((u_int32_t)index, xValue, yValue, zValue);    
}

-(void)repositionListenerWithX:(float)xValue withY:(float)yValue withZ:(float)zValue{
    
    _player->repositionListener(xValue, yValue, zValue);
}

-(void)changeSourceGainAtIndex:(NSInteger)index withValue:(float)value{
    
    _player->changeSourceGain((u_int32_t)index, value);
}

-(void)changeMasterPitchWithValue:(float)value{
    
    for (int idx = 0; idx < 5; idx++) {
        _player->changeSourcePitch(idx, value);
    }
}
@end

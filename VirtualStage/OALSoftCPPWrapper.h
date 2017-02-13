//
//  OALSoftCPPWrapper.h
//  VirtualStage
//
//  Created by Yunhao Wan on 2/20/16.
//  Copyright © 2016 Yunhao Wan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief OpenAL wrapper class for Objective-C to interoperate with C++ implementation
 */
@interface OALSoftCPPWrapper : NSObject

/**
 * @brief start the OpenAL Playback
 */
-(void)startPlayback;

/**
 * @brief Pause the OpenAL Playback
 */
-(void)pausePlayback;

/**
 * @brief check wether the playback is playing
 *
 * @return A bool value to tell whether the playback is playing
 */
-(bool)isPlaying;

/**
 * @brief reposition a specific sound source with given position values (x, y, z) in RHS Cartisen system
 *
 * @param index     The index of specific sound source. In current implementation, it's hard coded as:
 *                  0->bass, 1->drum 3->guitar 4->guitar2 5->vocal.
 * @param xValue    the value for x in coordinate system
 * @param yValue    the value for y in coordinate system
 * @param zValue    the value for z in coordinate system
 */
-(void)repositionSoundSourceAtIndex:(NSInteger)index withX:(float)xValue withY:(float)yValue withZ:(float)zValue;

/**
 * @brief   reposition the listener with given position values (x, y, z) in RHS Cartisen system
 *
 * @param xValue    the value for x in coordinate system
 * @param yValue    the value for y in coordinate system
 * @param zValue    the value for z in coordinate system
 */
-(void)repositionListenerWithX:(float)xValue withY:(float)yValue withZ:(float)zValue;

/**
 * @brief   Change the pitch value for the entire playback. i.e. all sound sources at one time
 *
 * @param   The pitch value to change
 */
-(void)changeMasterPitchWithValue:(float)pitchValue;

/**
 * @brief           Change the gain for a specific sound source
 *
 * @param gainValue the gain value to change
 */
-(void)changeSourceGainAtIndex:(NSInteger)index withValue:(float)gainValue;

@end

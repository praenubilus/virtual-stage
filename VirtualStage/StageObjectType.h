//
//  StageObjectType.h
//  VirtualStage
//
//  Created by Yunhao Wan on 4/7/16.
//  Copyright © 2016 Yunhao Wan. All rights reserved.
//

#ifndef StageObjectType_h
#define StageObjectType_h


#endif /* StageObjectType_h */

/**
 * @brief   define the Stage Object enumeration in a separate file. This
 *          will solving the compiling problem for the protocol definination
 *          in StageView class
 */
typedef NS_ENUM(NSUInteger, StageObject){
    GuitarOneObject,
    GuitarTwoObject,
    BassObject,
    DrumObject,
    VocalObject,
    ListenerObject
};
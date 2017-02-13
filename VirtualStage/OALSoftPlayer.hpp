//
//  OALSoftPlayer.hpp
//  VirtualStage
//
//  Created by Yunhao Wan on 2/20/16.
//  Copyright © 2016 Yunhao Wan. All rights reserved.
//

#ifndef OALSoftPlayer_hpp
#define OALSoftPlayer_hpp

#include <stdio.h>
#include <vector>
#include <string>

#include "AL/al.h"

#endif /* OALSoftPlayer_hpp */


namespace OALSoft {
    
    
    class SoundSource {
    public:
        /**
         * @brief   Construtor of SourndSource class. Will initialize and load a sound
         *          source through given path
         */
        SoundSource(std::string);
        
        ~SoundSource();
        
        uint32_t size;                  //not used
        uint32_t chunkSize;             //data chunk size, wave using byte
        short formatType;               //not used actually
        short channels;                 //num of channels
        uint32_t sampleRate;            //sampleRate, usually in the headers
        uint32_t avgBytesPerSec;        //not used
        short bytesPerSample;
        short bitsPerSample;
        uint32_t dataSize;
        ALvoid *data;
        ALenum ALformatType;
        ALuint source;
        ALuint buffer;
        ALuint frequency;
        std::string sourceName;
        
        /**
         * @brief   Load and decoding a wave file to raw format for OpenAL.
         */
        void loadWave(std::string);
        
        /**
         * @brief   A higher level wrapper class to wrap up the load wave file procedure.
         *          It will also do some initialization settings for OpenAL sound sources.
         */
        void loadALSource(void);
    private:
        u_int32_t debug = 0;
        
        /**
         * @brief   Reporting error information when an error happens.
         */
        void endWithError(std::string);
    };
    
    
    class Player{
        
    public:
        /**
         * @brief           The constructor of the Player class. It will initialize the 
         *                  OpenAL at backend, Then check the HRTF configuration: 1. whether 
         *                  it's on or not. 2. Which HRTF it's using.
         *
         * @param int       The number of total sound sources
         * @param string*   The array of all sound source paths(absolute path)
         */
        Player(int, std::string*);
       
        /**
         * @brief Deconstructor of Player class. Will so a series of cleanup works
         */
        ~Player();
        
        /**
         * @brief reposition the sound source
         */
        void repositionSoundSource(u_int32_t, float, float, float);
        /**
         * @brief reposition the listener
         */
        void repositionListener(float, float, float);
        /**
         * @brief change the gain for a specific sound source
         */
        void changeSourceGain(u_int32_t, float);
        /**
         * @brief change the pitch for a specific sound source
         */
        void changeSourcePitch(u_int32_t, float);
        /**
         * @brief start the playback after all resources has been initialized
         */
        void start();
        /**
         * @brief pause the playback during playback
         */
        void pause();
        /**
         * @brief   check whether the playback is on
         *
         * @return  bool value, which tell the playback is on/off
         */
        bool isPlaying();
    private:
        std::vector<SoundSource *> soundSourcesVec;
        ALuint *sources;
        int numSources;
        
        /**
         * @brief Internal methods. Initialize the OpenAL context and resources
         */
        void initAL();
        
        /**
         * @brief Check whether the HRTFs settings in OpenAL works
         */
        void checkNSetHRTF();
        
        /**
         * @brief Report an internal error when doing OpenAL manipulation
         */
        void endWithError(std::string);
        
        /**
         * @brief cleanup All OpenAL resources
         */
        void cleanUpAL();
        
        /**
         * @brief Overload methods to cleanup all OpenAL resrouces
         */
        void cleanUpAL(std::vector<SoundSource *>, ALuint *);
        
    };
    
    
}
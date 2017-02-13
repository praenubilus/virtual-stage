//
//  OALSoftPlayer.cpp
//  VirtualStage
//
//  Created by Yunhao Wan on 2/20/16.
//  Copyright © 2016 Yunhao Wan. All rights reserved.
//

#include <cstdio>
#include <iostream>
#include <math.h>
#include <thread>
#include <array>

#include "OALSoftPlayer.hpp"
#include "AL/alc.h"
#include "AL/alext.h"

#ifndef M_PI
#define M_PI                         (3.14159265358979323846)
#endif

#define SCENE_REFERENCE_DISTANCE    70.0

using namespace OALSoft;

SoundSource::SoundSource(std::string path) {
    sourceName = path;
    ALformatType = 0;
    loadWave(path);
    loadALSource();
}

SoundSource::~SoundSource() {
    free(data);
    data = NULL;
    alDeleteSources(1, &source);                      //Delete the OpenAL Source
    alDeleteBuffers(1, &buffer);                      //Delete the OpenAL Buffer
}

void SoundSource::endWithError(std::string msg) {
    //Display error message in console
    std::cout << msg << std::endl;
    printf("Error! %s\n", strerror(errno));
    exit(1);
}

void SoundSource::loadWave(std::string path) {
    FILE *file = fopen(path.c_str(), "rb");
    if (!file) endWithError("Failed to open file");                     //Could not open file
    /*********************************
     ** processing WAV headers
     **********************************/
    char xbuffer[5];
    xbuffer[4] = '\0';
    if (fread(xbuffer, sizeof(char), 4, file) != 4 || strcmp(xbuffer, "RIFF") != 0)
        endWithError("Not a WAV file, Invalid wave header part 1");
    
    //all intel cpu and arm(iOS) are little endian, seems no need to swap
    //skip 32bits to next flag
    fread(xbuffer, 4, 1, file);
    
    if (fread(xbuffer, sizeof(char), 4, file) != 4 || strcmp(xbuffer, "WAVE") != 0)
        endWithError("Not a WAV file, Invalid wave header part 2");
    
    if (fread(xbuffer, sizeof(char), 4, file) != 4 || strcmp(xbuffer, "fmt ") != 0)
        endWithError("Invalid WAV file, Invalid wave header part 3");
    
    fread(&chunkSize, sizeof(uint32_t), 1, file);
    fread(&formatType, sizeof(short), 1, file);
    fread(&channels, sizeof(short), 1, file);
    fread(&sampleRate, sizeof(uint32_t), 1, file);
    fread(&avgBytesPerSec, sizeof(uint32_t), 1, file);
    fread(&bytesPerSample, sizeof(short), 1, file);
    fread(&bitsPerSample, sizeof(short), 1, file);
    
    if (fread(xbuffer, sizeof(char), 4, file) != 4 || strcmp(xbuffer, "data") != 0)
        endWithError("Missing DATA chunks, invalid WAV file");                                //not data
    
    fread(&dataSize, sizeof(uint32_t), 1, file);
    
    //determine the wave file format
    if (bitsPerSample == 8) {
        if (channels == 1)
            ALformatType = AL_FORMAT_MONO8;
        else if (channels == 2)
            ALformatType = AL_FORMAT_STEREO8;
    }
    else if (bitsPerSample == 16) {
        if (channels == 1)
            ALformatType = AL_FORMAT_MONO16;
        else if (channels == 2)
            ALformatType = AL_FORMAT_STEREO16;
    }
    if (!ALformatType) endWithError("Wrong BitPerSample");         //Not valid format
    
    data = malloc(dataSize);                   //Allocate memory for the sound data
    std::cout << fread(data, 1, dataSize, file) << " bytes loaded\n";     //Read the sound data and display the num of bytes
    fclose(file);
    
    frequency = sampleRate;                                       //Close the WAVE file
    
    if (debug) {
        std::cout << "chunkSize:" << chunkSize << std::endl;
        std::cout << "formatType:" << formatType << std::endl;
        std::cout << "channels:" << channels << std::endl;
        std::cout << "sampleRate:" << sampleRate << std::endl;
        std::cout << "avgBytesPerSec:" << avgBytesPerSec << std::endl;
        std::cout << "bytesPerSample:" << bytesPerSample << std::endl;
        std::cout << "bitsPerSample:" << bitsPerSample << std::endl;
        std::cout << "Data Size: " << dataSize << std::endl;
        std::cout << "ALformatType" << ALformatType << std::endl;
    }
    /*********************************
     ** WAV headers being processed
     **********************************/
}

void SoundSource::loadALSource(void) {
    /*********************************
     ** OpenAL initialization
     **********************************/
    alGenBuffers(1, &buffer);
    alGenSources(1, &source);
    if (alGetError() != AL_NO_ERROR) endWithError("Error GenSource");     //Error during buffer/source generation
    
    alBufferData(buffer, ALformatType, data, dataSize, frequency);    //Store the sound data in the OpenAL Buffer
    if (alGetError() != AL_NO_ERROR)
        endWithError("Error loading ALBuffer");                          //Error during buffer loading
    alSourcei(source, AL_BUFFER, buffer);
    
    ALfloat SourcePos[] = {0.0, 0.0, 0.0};                            //Position of the source sound
    ALfloat SourceVel[] = {0.0, 0.0, 0.0};                            //Velocity of the source sound
    
    //Source
    alSourcei(source, AL_BUFFER, buffer);                            //Link the buffer to the source
    alSourcef(source, AL_PITCH, 1.0f);                         //Set the pitch of the source
    alSourcef(source, AL_GAIN, 1.0f);                         //Set the gain of the source
    alSourcefv(source, AL_POSITION, SourcePos);                         //Set the position of the source
    alSourcefv(source, AL_VELOCITY, SourceVel);                         //Set the velocity of the source
    alSourcei(source, AL_LOOPING, AL_FALSE);                         //Set if source is looping sound
    alSourcef(source, AL_REFERENCE_DISTANCE, SCENE_REFERENCE_DISTANCE); // Set the reference distance

}


/****************************************************************************
 Player Class
 ***************************************************************************/


Player::Player(int countSources, std::string * paths){

    numSources = countSources;
    
    initAL();
    checkNSetHRTF();
    
    //1.bass, 2.battery 3.guitar 4.guitar2 5.vocal
    
    sources = new ALuint[countSources];
    for (int idx = 0; idx < countSources; ++idx) {
        SoundSource *sc = new SoundSource(paths[idx]);
        soundSourcesVec.push_back(sc);
        sources[idx] = sc->source;
    }
}

Player::~Player(){
    cleanUpAL(soundSourcesVec, sources);
}


void Player::start(){
//    ALenum state;
    
    //PLAY
    std::cout << "start to play!" << std::endl;
    
    alSourcePlayv(numSources, sources);                         //Play the sound buffer linked to the source
    
    // OpenAL use cartesian coordinates(RHS)
    //localization. Position different sound source to different positions.
    //The initial value will all be right in front of the listener
    alSource3f(sources[0], AL_POSITION, 0, 0, -2); //bass
    alSource3f(sources[1], AL_POSITION, 0, 0, -2);//battery
    alSource3f(sources[2], AL_POSITION, 0, 0, -2); //guitar 1
    alSource3f(sources[3], AL_POSITION, 0, 0, -2); //guitar 2
    alSource3f(sources[4], AL_POSITION, 0, 0, -2);// vocal
    
    do {
        //sleep() in MacOS C alias use seconds as unit. But this will cause problem. Maybe because of
        // the OS BLOCK threads implementation. The original example use al_nssleep, which is a thread based
        //implementation. std::this_thread::sleep_for() on GUN/Linux system just uses native nanosleep implementation
        std::this_thread::sleep_for(std::chrono::milliseconds(3000));
        
    } while (alGetError() == AL_NO_ERROR && isPlaying());
    
    if (alGetError() != AL_NO_ERROR) endWithError("Error playing sound");//Error when playing sound
}


void Player::pause(){
    std::cout << "playback paused!" << std::endl;
    
    alSourcePausev(numSources, sources);
}


bool Player::isPlaying(){
    ALenum state;
    
    alGetSourcei(sources[0], AL_SOURCE_STATE, &state);
    if (state == AL_PLAYING)
        return true;
    else
        return false;
}


void Player::endWithError(std::string msg) {
    //Display error message in console
    std::cout << msg << std::endl;
    printf("Error! %s\n", strerror(errno));
    exit(1);
}

void Player::initAL() {
    // Initialize OpenAL device and context
    
    ALCdevice *device;
    ALCcontext *context;
    
    device = alcOpenDevice(NULL);
    if (!device) endWithError("no sound device");                         //Error during device oening
    context = alcCreateContext(device, NULL);                                   //Give the device a context
    if (context == NULL || alcMakeContextCurrent(context) == ALC_FALSE) {
        if (context != NULL)
            alcDestroyContext(context);
        alcCloseDevice(device);
        endWithError("Could not set a context!\n");
    }
    
    alcMakeContextCurrent(context);                                             //Make the context the current
    if (!context) endWithError("no sound context");                       //Error during context handeling
    
    //Initialize listener
    
    ALfloat ListenerPos[] = {0.0, 0.0, 0.0};                          //Position of the listener
    ALfloat ListenerVel[] = {0.0, 0.0, 0.0};                          //Velocity of the listener
    ALfloat ListenerOri[] = {0.0, 0.0, -1.0, 0.0, 1.0, 0.0};         //Orientation of the listener
    //First direction vector, then vector pointing up)
    alListenerfv(AL_POSITION, ListenerPos);                          //Set position of the listener
    alListenerfv(AL_VELOCITY, ListenerVel);                          //Set velocity of the listener
    alListenerfv(AL_ORIENTATION, ListenerOri);                          //Set orientation of the listener
}

void Player::cleanUpAL() {
    ALCdevice *device;
    ALCcontext *context;
    
    context = alcGetCurrentContext();
    if (context == NULL)
        return;
    
    device = alcGetContextsDevice(context);
    
    alcMakeContextCurrent(NULL);                                        //Make no context current
    alcDestroyContext(context);                                         //Destroy the OpenAL Context
    alcCloseDevice(device);                                             //Close the OpenAL Device
    
    std::cout << "Clean up finished!" << std::endl;
}

void Player::cleanUpAL(std::vector<SoundSource *> soundSourcesVec, ALuint *sources) {
    delete[]sources;
    soundSourcesVec.clear();
    
    cleanUpAL();
}

void Player::checkNSetHRTF(){
    ALCdevice *device;
    ALCint num_hrtfs;
    ALCint hrtf_state;
    
    //Check whether HRTF is on, which DB is used
    device = alcGetContextsDevice(alcGetCurrentContext());
    if (!alcIsExtensionPresent(device, "ALC_SOFT_HRTF")) {
        fprintf(stderr, "Error: ALC_SOFT_HRTF not supported\n");
        cleanUpAL();
        exit(1);
    }
    
    LPALCGETSTRINGISOFT alcGetStringiSOFT;
    
    //This casting is necessary in CPP, but not necessary in C
    alcGetStringiSOFT = (LPALCGETSTRINGISOFT)alcGetProcAddress(device, "alcGetStringiSOFT");
    
    alcGetIntegerv(device, ALC_NUM_HRTF_SPECIFIERS_SOFT, 1, &num_hrtfs);
    if (!num_hrtfs)
        printf("No HRTFs found\n");
    else
    {
        ALCint attr[5];
        ALCint index = 0;
        ALCint i;
        printf("Available HRTFs:\n");
        for(i = 0;i < num_hrtfs;++i)
        {
            const ALCchar *name = alcGetStringiSOFT(device, ALC_HRTF_SPECIFIER_SOFT, i);
            printf("    %s\n", name);
        }
        
        //an array of attributes to set HRTF. Currently we only use HRTF index 0, which is default-44100.mhr here
        //aka Kemar 44,100 Hz
        attr[0] = ALC_HRTF_SOFT;
        attr[1] = ALC_TRUE;//turn HRTF on
        //        attr[1] = ALC_FALSE; //turn HRTF off
        attr[2] = ALC_HRTF_ID_SOFT;
        attr[3] = index;
        //        attr[4] = 0;
        
        LPALCRESETDEVICESOFT alcResetDeviceSOFT;
        alcResetDeviceSOFT = (LPALCRESETDEVICESOFT)alcGetProcAddress(device, "alcResetDeviceSOFT");
        
        if(!alcResetDeviceSOFT(device, attr))
            printf("Failed to reset device: %s\n", alcGetString(device, alcGetError(device)));
    }
    
    /* Check if HRTF is enabled, and show which is being used. */
    alcGetIntegerv(device, ALC_HRTF_SOFT, 1, &hrtf_state);
    if(!hrtf_state)
        printf("HRTF not enabled!\n");
    else
    {
        const ALchar *name = alcGetString(device, ALC_HRTF_SPECIFIER_SOFT);
        printf("HRTF enabled, using %s\n", name);
    }
    
    fflush(stderr); // in case OpenAL reported an error earlier
}


void Player::changeSourceGain(u_int32_t sourceIdx, float gainVal){
    
    alSourcef(sources[sourceIdx], AL_GAIN, gainVal);
}


void Player::changeSourcePitch(u_int32_t sourceIdx, float pitchVal){
    
    alSourcef(sources[sourceIdx], AL_PITCH, pitchVal);
}




void Player::repositionSoundSource(u_int32_t sourceIdx, float xPosi, float yPosi, float zPosi){
    
    // OpenAL use cartesian coordinates(RHS)
    alSource3f(sources[sourceIdx], AL_POSITION, xPosi, yPosi, zPosi);
    
}


void Player::repositionListener(float xPosi, float yPosi, float zPosi){
    
    alListener3f(AL_POSITION, xPosi, yPosi, zPosi);
}


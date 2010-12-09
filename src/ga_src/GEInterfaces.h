/**
 *
 * GE::GA General interfaces
 * tuomo.hirvonen@digia.com
 *
 */

#ifndef __GE_IGA_INTERFACES__
#define __GE_IGA_INTERFACES__

#include <QObject>

namespace GE {

#define AUDIO_FREQUENCY 22050
#define AUDIO_SAMPLE_TYPE short
#define AUDIO_SAMPLE_BITS 16

    class IAudioSource : public QObject {
    public:
        IAudioSource();
        virtual ~IAudioSource();

        virtual int pullAudio( AUDIO_SAMPLE_TYPE *target, int bufferLength ) = 0;
        virtual bool canBeDestroyed() { return false; }

        IAudioSource *m_next;				// for listing, do not touch if you dont know what you are doing.
    };


    class CAudioMixer : public IAudioSource {
    public:
        CAudioMixer();
        virtual ~CAudioMixer();
        void destroyList();							// destroy all the sources in the list


        IAudioSource* addAudioSource( IAudioSource *s );		// add new audio source to the list
        int getAudioSourceCount();
        bool removeAudioSource( IAudioSource *s );	// remove an audio source from the list
        int pullAudio( AUDIO_SAMPLE_TYPE *target, int bufferLength );

        void setAbsoluteVolume( float vol );
        float getAbsoluteVolume() { return (float)m_fixedGeneralVolume/4096.0f; };

        void setGeneralVolume( float vol );         // relative to the channelcount (audiosourcecount)
        float getGeneralVolume();




    protected:
        int m_fixedGeneralVolume;
        AUDIO_SAMPLE_TYPE *m_mixingBuffer;
        int m_mixingBufferLength;
        IAudioSource *m_sourceList;
    };

};


#endif

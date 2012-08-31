// Copyright (c) 2012, Daniel Andersen (dani_ande@yahoo.dk)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products derived
//    from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <AudioToolbox/AudioToolbox.h>

#import "FloorPlan.h"

#define APPEAR_SPEED 0.025f
#define SCREENSHOT_SPEED 0.1f
#define PHOTO_APPEAR_SPEED 0.05f

#define EXHIBITION_MODE_NORMAL 0
#define EXHIBITION_MODE_VIEWING_PHOTO 1
#define EXHIBITION_MODE_VIEWING_TEXT 2

@interface Exhibition : NSObject {

@private

    FloorPlan *floorPlan;

    Quads *nextButton;
    Quads *prevButton;
    Quads *startTourButton;
    Quads *stopTourButton;
    Quads *turnAroundPhotoButton;

    Quads *screenOverlay;
    Quads *photoOverlay;

    SystemSoundID clickSoundId;
    
    float overlayAnimation;

    int mode;
    float photoAnimation;
    
    PhotoInfo *userPhoto;
    Texture photoTexture;
    Texture textTexture;
}

- (id) init;

- (void) createExhibition;

- (void) tap:(GLKVector2)p;

- (void) update;
- (void) render;

@end

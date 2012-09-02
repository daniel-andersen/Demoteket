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

#import "Exhibition.h"
#import "Globals.h"

#define NAVIGATION_BUTTON_BORDER 0.05f
#define NAVIGATION_BUTTON_SIZE 0.1f

@implementation Exhibition

- (id) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void) initialize {
    CFURLRef soundUrl = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("tap"), CFSTR("aif"), NULL);
    
    AudioServicesCreateSystemSoundID(soundUrl, &clickSoundId);

    textures = [[Textures alloc] init];
    [textures load];
    
    floorPlan = [[FloorPlan alloc] init];
    
    nextButton = [[Quads alloc] init];
    [nextButton beginWithTexture:nextButtonTexture];
    [nextButton setIsOrthoProjection:true];
    [nextButton addQuadX1:1.0f - NAVIGATION_BUTTON_BORDER y1:NAVIGATION_BUTTON_BORDER z1:0.0f
                       x2:1.0f - NAVIGATION_BUTTON_BORDER y2:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z2:0.0f
                       x3:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_SIZE y3:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z3:0.0f
                       x4:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_SIZE y4:NAVIGATION_BUTTON_BORDER z4:0.0f];
    [nextButton end];

    prevButton = [[Quads alloc] init];
    [prevButton beginWithTexture:prevButtonTexture];
    [prevButton setIsOrthoProjection:true];
    [prevButton addQuadX1:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE y1:NAVIGATION_BUTTON_BORDER z1:0.0f
                       x2:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE y2:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z2:0.0f
                       x3:NAVIGATION_BUTTON_BORDER y3:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z3:0.0f
                       x4:NAVIGATION_BUTTON_BORDER y4:NAVIGATION_BUTTON_BORDER z4:0.0f];
    [prevButton end];

    startTourButton = [[Quads alloc] init];
    [startTourButton beginWithTexture:tourButtonTexture];
    [startTourButton setIsOrthoProjection:true];
    [startTourButton addQuadX1:0.5f + (NAVIGATION_BUTTON_SIZE / 2.0f) y1:NAVIGATION_BUTTON_BORDER z1:0.0f
                       		x2:0.5f + (NAVIGATION_BUTTON_SIZE / 2.0f) y2:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z2:0.0f
                       		x3:0.5f - (NAVIGATION_BUTTON_SIZE / 2.0f) y3:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z3:0.0f
                       		x4:0.5f - (NAVIGATION_BUTTON_SIZE / 2.0f) y4:NAVIGATION_BUTTON_BORDER z4:0.0f];
    [startTourButton end];

    stopTourButton = [[Quads alloc] init];
    [stopTourButton beginWithTexture:nextButtonTexture];
    [stopTourButton setIsOrthoProjection:true];
    [stopTourButton addQuadX1:0.5f + (NAVIGATION_BUTTON_SIZE / 2.0f) y1:NAVIGATION_BUTTON_BORDER z1:0.0f
                           x2:0.5f + (NAVIGATION_BUTTON_SIZE / 2.0f) y2:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z2:0.0f
                           x3:0.5f - (NAVIGATION_BUTTON_SIZE / 2.0f) y3:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z3:0.0f
                           x4:0.5f - (NAVIGATION_BUTTON_SIZE / 2.0f) y4:NAVIGATION_BUTTON_BORDER z4:0.0f];
    [stopTourButton end];

    turnAroundPhotoButton = [[Quads alloc] init];
    [turnAroundPhotoButton beginWithTexture:turnAroundPhotoButtonTexture];
    [turnAroundPhotoButton setIsOrthoProjection:true];
    [turnAroundPhotoButton addQuadX1:1.0f - NAVIGATION_BUTTON_BORDER y1:NAVIGATION_BUTTON_BORDER z1:0.0f
                       			  x2:1.0f - NAVIGATION_BUTTON_BORDER y2:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z2:0.0f
                       			  x3:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_SIZE y3:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z3:0.0f
                       			  x4:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_SIZE y4:NAVIGATION_BUTTON_BORDER z4:0.0f];
    [turnAroundPhotoButton end];

    screenOverlay = [[Quads alloc] init];
    [screenOverlay beginWithColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)];
    [screenOverlay setIsOrthoProjection:true];
    [screenOverlay addQuadX1:0.0f y1:0.0f z1:0.0f
                          x2:1.0f y2:0.0f z2:0.0f
                       	  x3:1.0f y3:1.0f z3:0.0f
                       	  x4:0.0f y4:1.0f z4:0.0f];
    [screenOverlay end];

    photoOverlay = [[Quads alloc] init];
    [photoOverlay beginWithTexture:wallTexture[0]];
    [photoOverlay setIsOrthoProjection:true];
    [photoOverlay addQuadX1:1.0f y1:0.0f z1:0.0f
                         x2:1.0f y2:1.0f z2:0.0f
                       	 x3:0.0f y3:1.0f z3:0.0f
                       	 x4:0.0f y4:0.0f z4:0.0f];
    [photoOverlay end];

    overlayAnimation = 0.0f;
    mode = EXHIBITION_MODE_NORMAL;
    startTime = CFAbsoluteTimeGetCurrent();
}

- (void) createExhibition {
    [floorPlan createFloorPlan];

    NSLog(@"Exhibition initialized!");
}

- (void) tap:(GLKVector2)p {
    if (mode == EXHIBITION_MODE_NORMAL) {
	    if ([self clickedInRectX:p.x y:p.y rx:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_SIZE ry:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_SIZE width:NAVIGATION_BUTTON_SIZE height:NAVIGATION_BUTTON_SIZE]) {
		    [self playClickSound];
		    [floorPlan nextPhoto];
		} else if ([self clickedInRectX:p.x y:p.y rx:NAVIGATION_BUTTON_BORDER ry:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_SIZE width:NAVIGATION_BUTTON_SIZE height:NAVIGATION_BUTTON_SIZE]) {
		    [self playClickSound];
		    [floorPlan prevPhoto];
		} else if ([self clickedInRectX:p.x y:p.y rx:0.5f - (NAVIGATION_BUTTON_SIZE / 2.0f) ry:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_SIZE width:NAVIGATION_BUTTON_SIZE height:NAVIGATION_BUTTON_SIZE]) {
		    [self playClickSound];
	        [floorPlan toggleTour];
		} else {
	        [self clickPhoto];
	    }
    } else {
	    if ([self clickedInRectX:p.x y:p.y rx:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_SIZE ry:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_SIZE width:NAVIGATION_BUTTON_SIZE height:NAVIGATION_BUTTON_SIZE]) {
            // TODO!
		} else {
	        [self clickPhoto];
        }
    }
}

- (void) clickPhoto {
    PhotoInfo *photoInfo = [floorPlan getPhoto];
    if (photoInfo == NULL) {
        return;
    }
    if (mode == EXHIBITION_MODE_NORMAL) {
        [self viewPhoto:photoInfo];
    } else {
        [self hidePhoto];
    }
}

- (void) viewPhoto:(PhotoInfo*)photoInfo {
    if (photoInfo.photoTexture.id == demoteketLogoTexture.id) {
        return;
    }
    mode = EXHIBITION_MODE_VIEWING_PHOTO;
    userPhoto = photoInfo;
    photoTexture = photoInfo.photoTexture;
    textureSetBlend(&photoTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [photoOverlay setTexture:photoTexture];
    photoAnimation = 0.0f;
}

- (void) hidePhoto {
    mode = EXHIBITION_MODE_NORMAL;
}

- (void) update {
    if (CFAbsoluteTimeGetCurrent() > startTime + MOVEMENT_START_DELAY) {
	    [floorPlan update];
    }

    overlayAnimation = MIN(1.0f, overlayAnimation + APPEAR_SPEED);
    [screenOverlay setColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f - overlayAnimation)];

    if (mode == EXHIBITION_MODE_VIEWING_PHOTO || mode == EXHIBITION_MODE_VIEWING_TEXT) {
	    photoAnimation = MIN(1.0f, photoAnimation + PHOTO_APPEAR_SPEED);
    } else {
	    photoAnimation = MAX(0.0f, photoAnimation - PHOTO_APPEAR_SPEED);
    }
    [photoOverlay setColor:GLKVector4Make(1.0f, 1.0f, 1.0f, photoAnimation)];
}

- (void) render {
    [floorPlan render];
    glDisable(GL_CULL_FACE);
    if (photoAnimation > 0.0f) {
        [photoOverlay render];
        if (photoAnimation == 1.0f && mode != EXHIBITION_MODE_NORMAL) {
            [turnAroundPhotoButton render];
        }
    } else {
        if ([floorPlan isBackButtonVisible]) {
            [prevButton render];
        }
	    if ([floorPlan isNextButtonVisible]) {
		    [nextButton render];
	    }
	    if ([floorPlan isPaused]) {
		    [startTourButton render];
	    }
	    if ([floorPlan isOnTour]) {
		    [stopTourButton render];
	    }
    }
    if (overlayAnimation < 1.0f) {
        [screenOverlay render];
    }
}

- (bool) clickedInRectX:(float)x y:(float)y rx:(float)rx ry:(float)ry width:(float)width height:(float)height {
    return x >= rx && y >= ry && x <= rx + width && y <= ry + height;
}

- (void) playClickSound {
    AudioServicesPlaySystemSound(clickSoundId);
}

@end

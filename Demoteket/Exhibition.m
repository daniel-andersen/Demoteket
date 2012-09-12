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

#define NAVIGATION_BUTTON_BORDER 0.05f
#define NAVIGATION_BUTTON_SIZE 0.1f
#define NAVIGATION_BUTTON_TOUCH_SIZE 0.15f

@implementation Exhibition

- (id) init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void) initialize {
	rssFeedParser = [[RssFeedParser alloc] init];
    feedFirstTimeLoad = true;
    
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

    turnAroundButton = [[Quads alloc] init];
    [turnAroundButton beginWithTexture:turnAroundButtonTexture];
    [turnAroundButton setIsOrthoProjection:true];
    [turnAroundButton addQuadX1:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE y1:NAVIGATION_BUTTON_BORDER z1:0.0f
                       		 x2:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE y2:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z2:0.0f
                       		 x3:NAVIGATION_BUTTON_BORDER y3:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z3:0.0f
                       		 x4:NAVIGATION_BUTTON_BORDER y4:NAVIGATION_BUTTON_BORDER z4:0.0f];
    [turnAroundButton end];

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

    blogButton = [[Quads alloc] init];
    [blogButton beginWithTexture:blogButtonTexture];
    [blogButton setIsOrthoProjection:true];
    [blogButton addQuadX1:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE y1:NAVIGATION_BUTTON_BORDER z1:0.0f
                       x2:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE y2:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z2:0.0f
                       x3:NAVIGATION_BUTTON_BORDER y3:NAVIGATION_BUTTON_BORDER + NAVIGATION_BUTTON_SIZE z3:0.0f
                       x4:NAVIGATION_BUTTON_BORDER y4:NAVIGATION_BUTTON_BORDER z4:0.0f];
    [blogButton end];

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
    [photoOverlay addQuadX1: 0.5f y1:-0.5f z1:0.0f
                         x2: 0.5f y2: 0.5f z2:0.0f
                       	 x3:-0.5f y3: 0.5f z3:0.0f
                       	 x4:-0.5f y4:-0.5f z4:0.0f];
    [photoOverlay setTranslation:GLKVector3Make(0.5f, 0.5f, 0.0f)];
    [photoOverlay end];

    overlayAnimation = 0.0f;
    mode = EXHIBITION_MODE_NORMAL;
    startTime = CFAbsoluteTimeGetCurrent();
}

- (void) createExhibition {
    [floorPlan createFloorPlan];

    userPhotos[0] = [floorPlan createUserPhotoInRoom:0 x:2 z:6 depth:PILLAR_DEPTH scale:1.7f]; // Demoteket logo
    [userPhotos[0] definePhotoTexture:demoteketLogoTexture];

    userPhotos[1] = [floorPlan createUserPhotoInRoom:0 x:3 z: 4 depth:PILLAR_DEPTH scale:1.2f];
    userPhotos[2] = [floorPlan createUserPhotoInRoom:0 x:1 z: 0 depth:0.0f scale:1.0f];
    userPhotos[3] = [floorPlan createUserPhotoInRoom:1 x:2 z: 3 depth:0.0f scale:1.0f];
    userPhotos[4] = [floorPlan createUserPhotoInRoom:1 x:4 z: 7 depth:0.0f scale:1.0f];
    userPhotos[5] = [floorPlan createUserPhotoInRoom:1 x:2 z:11 depth:0.0f scale:1.0f];

    userPhotos[6] = [floorPlan createUserPhotoInRoom:2 x:3 z:3 depth:PILLAR_DEPTH scale:1.2f]; // Trolls Ahead logo
    [userPhotos[6] definePhotoTexture:trollsAheadLogoTexture];

    userPhotos[7] = [floorPlan createUserPhotoInRoom:2 x:0 z: 3 depth:0.0f scale:1.0f];
    userPhotos[8] = [floorPlan createUserPhotoInRoom:2 x:3 z: 7 depth:0.0f scale:1.0f];
    userPhotos[9] = [floorPlan createUserPhotoInRoom:3 x:3 z: 2 depth:PILLAR_DEPTH scale:1.2f];
    userPhotos[10] = [floorPlan createUserPhotoInRoom:3 x:4 z: 4 depth:PILLAR_DEPTH scale:1.2f];
    userPhotos[11] = [floorPlan createUserPhotoInRoom:3 x:9 z:2 depth:0.0f scale:1.0f];

    [floorPlan createPaths];
    [floorPlan createGeometrics];
    
	[self refreshFeed];
    
    NSLog(@"Exhibition initialized!");
}

- (void) reactivate {
    if (mode != EXHIBITION_MODE_NORMAL) {
        [self hidePhoto];
    }
    [self refreshFeed];
}

- (void) inactivate {
}

- (void) refreshFeed {
    [rssFeedParser loadFeed:[NSURL URLWithString:@"http://www.demotekaarhus.dk/?feed=rss2"] successCallback:^{
        [self loadPhotos];
        feedFirstTimeLoad = false;
    } errorCallback:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ingen netværksforbindelse"
                                                        message:@"Kunne ikke indlæse billeder fra Demotek Aarhus"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void) loadPhotos {
    if (!feedFirstTimeLoad && ![rssFeedParser hasChanges]) {
        NSLog(@"Feed didn't change");
        return;
    }
    NSLog(@"Feed changed");
    int idx = 0;
    for (int i = 0; i < MIN([rssFeedParser photoCount], 10); i++) {
        while ([userPhotos[idx] isStaticButNotLoadingPhoto]) {
            idx++;
        }
        if (!feedFirstTimeLoad && ![rssFeedParser hasChanges]) {
	        idx++;
        }
        [userPhotos[idx] loadPhotoAsynchronously:[rssFeedParser getImage:i]];
        userPhotos[idx].title = [rssFeedParser getTitle:i];
        userPhotos[idx].description = [rssFeedParser getDescription:i];
        userPhotos[idx].link = [rssFeedParser getLink:i];
        idx++;
    }
}

- (void) tap:(GLKVector2)p {
    if (mode == EXHIBITION_MODE_NORMAL) {
	    if ([self clickedInRectX:p.x y:p.y rx:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_TOUCH_SIZE ry:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_TOUCH_SIZE width:NAVIGATION_BUTTON_TOUCH_SIZE height:NAVIGATION_BUTTON_TOUCH_SIZE]) {
		    [floorPlan nextPhoto];
		} else if ([self clickedInRectX:p.x y:p.y rx:NAVIGATION_BUTTON_BORDER ry:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_TOUCH_SIZE width:NAVIGATION_BUTTON_TOUCH_SIZE height:NAVIGATION_BUTTON_TOUCH_SIZE]) {
		    [floorPlan prevPhoto];
		} else if ([self clickedInRectX:p.x y:p.y rx:0.5f - (NAVIGATION_BUTTON_TOUCH_SIZE / 2.0f) ry:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_TOUCH_SIZE width:NAVIGATION_BUTTON_TOUCH_SIZE height:NAVIGATION_BUTTON_TOUCH_SIZE]) {
	        [floorPlan toggleTour];
		} else {
	        [self clickPhoto];
	    }
    } else {
        if (mode == EXHIBITION_MODE_VIEWING_TEXT && [self clickedInRectX:p.x y:p.y rx:NAVIGATION_BUTTON_BORDER ry:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_TOUCH_SIZE width:NAVIGATION_BUTTON_TOUCH_SIZE height:NAVIGATION_BUTTON_TOUCH_SIZE]) {
            [self showBlog];
        } else if ([self clickedInRectX:p.x y:p.y rx:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_TOUCH_SIZE ry:1.0f - NAVIGATION_BUTTON_BORDER - NAVIGATION_BUTTON_TOUCH_SIZE width:NAVIGATION_BUTTON_TOUCH_SIZE height:NAVIGATION_BUTTON_TOUCH_SIZE]) {
            [self turnAroundPhoto];
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

- (void) turnAroundPhoto {
    mode = photoTexture.id == userPhoto.photoTexture.id ? EXHIBITION_MODE_VIEWING_TEXT : EXHIBITION_MODE_VIEWING_PHOTO;
    photoAnimation = 0.0f;
}

- (void) preparePhotoTexture {
    textureSetBlend(&photoTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [photoOverlay setTexture:photoTexture];
}

- (void) viewPhoto:(PhotoInfo*)photoInfo {
    if (![photoInfo isClickable]) {
        return;
    }
    mode = EXHIBITION_MODE_VIEWING_PHOTO;
    userPhoto = photoInfo;
    [photoInfo createTextTexture];
    photoTexture = photoInfo.photoTexture;
    photoFadeAnimation = 0.0f;
    photoAnimation = 2.0f;
    [self preparePhotoTexture];
}

- (void) hidePhoto {
    mode = EXHIBITION_MODE_NORMAL;
}

- (void) showBlog {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:userPhoto.link]];
}

- (void) update {
    if (CFAbsoluteTimeGetCurrent() > startTime + MOVEMENT_START_DELAY) {
	    [floorPlan update];
    }

    if (mode == EXHIBITION_MODE_VIEWING_PHOTO || mode == EXHIBITION_MODE_VIEWING_TEXT) {
	    photoFadeAnimation = MIN(1.0f, photoFadeAnimation + PHOTO_APPEAR_SPEED);
    } else {
	    photoFadeAnimation = MAX(0.0f, photoFadeAnimation - PHOTO_APPEAR_SPEED);
    }
    [photoOverlay setColor:GLKVector4Make(1.0f, 1.0f, 1.0f, photoFadeAnimation)];
    
    if (mode == EXHIBITION_MODE_VIEWING_PHOTO || mode == EXHIBITION_MODE_VIEWING_TEXT) {
	    photoAnimation = MIN(2.0f, photoAnimation + PHOTO_APPEAR_SPEED);
        overlayAnimation = 1.0f - (photoAnimation < 1.0f ? photoAnimation : (2.0f - photoAnimation));
        if (photoAnimation > 1.0f && mode == EXHIBITION_MODE_VIEWING_TEXT && photoTexture.id == userPhoto.photoTexture.id) {
	        photoTexture = userPhoto.textTexture;
            [self preparePhotoTexture];
        } else if (photoAnimation > 1.0f && mode == EXHIBITION_MODE_VIEWING_PHOTO && photoTexture.id == userPhoto.textTexture.id) {
	        photoTexture = userPhoto.photoTexture;
            [self preparePhotoTexture];
        }
    } else {
	    overlayAnimation = MIN(1.0f, overlayAnimation + APPEAR_SPEED);
    }
    [screenOverlay setColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f - overlayAnimation)];
}

- (void) render {
    if (photoFadeAnimation < 1.0f) {
	    [floorPlan render];
    }
    glDisable(GL_CULL_FACE);
    if (photoFadeAnimation > 0.0f) {
        [self renderPhoto];
    }
    [self renderButtons];
    if (overlayAnimation < 1.0f) {
        [screenOverlay render];
    }
}

- (void) renderButtons {
    if (photoFadeAnimation > 0.0f) {
        if (photoFadeAnimation == 1.0f) {
            [turnAroundPhotoButton render];
            if ((mode == EXHIBITION_MODE_VIEWING_TEXT && photoAnimation >= 1.0f) || (mode == EXHIBITION_MODE_VIEWING_PHOTO && photoAnimation <= 1.0f)) {
                [blogButton render];
            }
        }
    } else {
        if ([floorPlan isTurnAroundButtonVisible]) {
            [turnAroundButton render];
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
}

- (void) renderPhoto {
    float rotationX = M_PI_2 * 0.2f * (photoAnimation < 1.0f ? photoAnimation : -(2.0f - photoAnimation));
    float rotationY = M_PI_2 * 1.0f * (photoAnimation < 1.0f ? photoAnimation :  (2.0f - photoAnimation));
    [photoOverlay setRotation:GLKVector3Make(rotationX, rotationY, 0.0f)];
    [photoOverlay render];
}

- (bool) clickedInRectX:(float)x y:(float)y rx:(float)rx ry:(float)ry width:(float)width height:(float)height {
    return x >= rx && y >= ry && x <= rx + width && y <= ry + height;
}

@end

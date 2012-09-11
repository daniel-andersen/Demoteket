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

#import <GLKit/GLKit.h>

#import "FloorPlan.h"
#import "Globals.h"

@implementation FloorPlan

float t = 0.0f;

- (id) init {
    if (self = [super init]) {
        [self createMirrorFramebuffer];
    }
    return self;
}

- (void) dealloc {
}

- (void) createMirrorFramebuffer {
    offscreenTextureWidth = textureAtLeastSize(screenWidthNoScale);
    offscreenTextureHeight = textureAtLeastSize(screenHeightNoScale);
    offscreenSizeInv[0] = 1.0f / offscreenTextureWidth;
    offscreenSizeInv[1] = 1.0f / offscreenTextureHeight;

    NSLog(@"Texture size: %i, %i", offscreenTextureWidth, offscreenTextureHeight);
    
    GLint oldFramebuffer;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFramebuffer);
    
    glGenFramebuffers(1, &mirrorFramebuffer);
    glGenTextures(1, &mirrorTexture);
    glGenRenderbuffers(1, &mirrorDepthBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, mirrorFramebuffer);

    glBindTexture(GL_TEXTURE_2D, mirrorTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, offscreenTextureWidth, offscreenTextureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, mirrorTexture, 0);

    glBindRenderbuffer(GL_RENDERBUFFER, mirrorDepthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, offscreenTextureWidth, offscreenTextureHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, mirrorDepthBuffer);

    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) { 
        NSLog(@"failed to make complete framebuffer object %x", status);
        exit(-1);
    }

    glBindFramebuffer(GL_FRAMEBUFFER, oldFramebuffer);
    
    floorTexture = textureMake(mirrorTexture);
}

- (void) createFloorPlan {
    NSLog(@"Creating floor plan");

    for (int i = 0; i < ROOM_COUNT; i++) {
        rooms[i] = [[Room alloc] initWithNumber:i];
    }
    rooms[0].visible = true;
    rooms[1].visible = true;
    rooms[2].visible = false;
    rooms[3].visible = false;

    currentRoom = 0;
}

- (void) createGeometrics {
    [rooms[0] createGeometrics];
    [rooms[1] createGeometrics];
    [rooms[2] createGeometrics];
    [rooms[3] createGeometrics];
}

- (PhotoInfo*) createUserPhotoInRoom:(int)roomIndex x:(int)x z:(int)z depth:(float)depth scale:(float)scale {
    float angle = [rooms[roomIndex] calculateWallAngleAtX:x z:z];
    return [[PhotoInfo alloc] initWithPosition:[Room displacePosition:roomIndex x:x z:z angle:angle depth:depth] roomNumber:roomIndex roomPosition:GLKVector2Make(x, z) angle:angle scale:scale];
}

- (void) createPaths {
    movement = [[Movement alloc] init];

    [movement setRoomVisibilityCallback:^(int type, int roomIndex) {
        rooms[roomIndex].visible = type == ROOM_VISIBILITY_TYPE_SHOW;
    }];
    
    [movement addUserPhoto:userPhotos[0]];
    [movement addUserPhoto:userPhotos[1]];
    [movement addUserPhoto:userPhotos[2]];
    [movement addUserPhoto:userPhotos[3]];
    [movement addUserPhoto:userPhotos[4]];
    [movement addUserPhoto:userPhotos[5]];
    [movement addUserPhoto:userPhotos[6]];
    [movement addUserPhoto:userPhotos[7]];
    [movement addUserPhoto:userPhotos[8]];
    [movement addUserPhoto:userPhotos[9]];
    [movement addUserPhoto:userPhotos[10]];
    [movement addUserPhoto:userPhotos[11]];

	// Forward walk mode
    [movement setMovement:MOVEMENT_TYPE_FORWARD];
    
    [movement setUserPhoto:0];
    [movement addPointAbsolute:GLKVector2Make(-4.0f, -17.0f)];
    [movement addPointRelative:GLKVector2Make(1.0f, 3.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-0.5f, 2.0f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:false four:true beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:false four:false beginningAt:0.7f];
    
    [movement setUserPhoto:1];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(-2.5f, 2.0f)];
    [movement addPointRelative:GLKVector2Make( 1.0f, 2.5f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-0.25f, 1.0f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:false four:false beginningAt:0.0f];

    [movement setUserPhoto:2];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(1.0f, 6.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(0.5f, 1.0f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:false four:false beginningAt:0.0f];

    [movement setUserPhoto:3];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(4.0f, 4.0f)];
    [movement addPointRelative:GLKVector2Make(3.0f, 0.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-1.75f, -2.5f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:true four:false beginningAt:0.0f];

    [movement setUserPhoto:4];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make( 0.5f, -3.0f)];
    [movement addPointRelative:GLKVector2Make(-2.5f, -4.0f)];
	[movement lookIn:M_PI * 0.9f beginningAt:0.0f];
	[movement lookAtRelativeToEnd:GLKVector2Make(-1.0f, -0.75f) beginningAt:0.5f];
    [movement setRoomVisibilityOne:true two:true three:true four:false beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:true three:true four:false beginningAt:0.5f];

    [movement setUserPhoto:5];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(-1.0f, -4.0f)];
    [movement addPointRelative:GLKVector2Make( 1.2f, -1.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(1.0f, -5.0f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:true three:true four:false beginningAt:0.0f];

    [movement setUserPhoto:6];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(3.0f, -1.0f)];
    [movement addPointRelative:GLKVector2Make(0.9f, -0.8f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(3.0f, -2.5f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:true three:true four:false beginningAt:0.0f];

    [movement setUserPhoto:7];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(4.0f,  -0.5f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(1.5f, -1.0f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:false three:true four:false beginningAt:0.0f];

    [movement setUserPhoto:8];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make( 1.0f, -1.5f)];
    [movement addPointRelative:GLKVector2Make(-0.5f, -4.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-2.0f, -2.0f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:false three:true four:true beginningAt:0.0f];

    [movement setUserPhoto:9];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(-3.5f,  0.0f)];
    [movement addPointRelative:GLKVector2Make(-1.8f, -2.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-2.0f, 0.5f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:false three:true four:true beginningAt:0.0f];

    [movement setUserPhoto:10];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(-3.5f, 0.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-2.0f, -1.5f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:false three:false four:true beginningAt:0.0f];

    [movement setUserPhoto:11];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(-6.5f, -1.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-1.0f, 0.75f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:false three:false four:true beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:false four:true beginningAt:0.9f];

	// Backward walk mode
    [movement setMovement:MOVEMENT_TYPE_BACKWARD];
    
    [movement setUserPhoto:11];
    [movement addPointRelativeToLastPoint:GLKVector2Make(0.0f, 0.0f) ofMovementType:MOVEMENT_TYPE_FORWARD];
    [movement addPointRelative:GLKVector2Make(0.0f, 4.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-2.0f, -1.5f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:false four:true beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:false three:false four:true beginningAt:0.8f];

    [movement setUserPhoto:10];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(2.5f, -3.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(1.0f, -0.75f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:false three:false four:true beginningAt:0.0f];

    [movement setUserPhoto:9];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(3.0f, -1.5f)];
    [movement addPointRelative:GLKVector2Make(3.0f,  0.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-2.0f, 2.0f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:false three:true four:true beginningAt:0.0f];

    [movement setUserPhoto:8];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(3.0f, 4.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(2.5f, -4.0f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:false three:true four:true beginningAt:0.0f];

    [movement setUserPhoto:7];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(2.8f, 1.5f)];
	[movement lookIn:-M_PI * 0.4f beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:false three:true four:true beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:false three:true four:false beginningAt:0.5f];
    
    [movement setUserPhoto:6];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(1.5f, 4.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-3.0f, 3.0f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:true three:true four:false beginningAt:0.0f];

    [movement setUserPhoto:5];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(-6.0f, 0.5f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-2.0f, -1.0f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:false two:true three:true four:false beginningAt:0.0f];

    
    
    
    
    [movement setUserPhoto:4];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(-3.0f, 0.0f)];
    [movement addPointRelative:GLKVector2Make( 0.0f, 3.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-2.0f, 1.5f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:false four:false beginningAt:0.0f];

    [movement setUserPhoto:3];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(4.0f, 6.0f)];
    [movement addPointRelative:GLKVector2Make(0.0f, 0.5f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-3.0f, 0.5f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:false four:false beginningAt:0.0f];

    [movement setUserPhoto:2];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(-1.0f, -1.5f)];
    [movement addPointRelative:GLKVector2Make(-4.5f,  2.0f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-2.5f, 2.5f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:false four:false beginningAt:0.0f];

    [movement setUserPhoto:1];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(-2.5f, -5.8f)];
	[movement lookAtRelativeToEnd:GLKVector2Make(-1.8f, 1.3f) beginningAt:0.0f];
    [movement setRoomVisibilityOne:true two:true three:false four:false beginningAt:0.0f];

    [movement setUserPhoto:0];
    [movement setPointToLastPoint];
    [movement addPointRelative:GLKVector2Make(-3.5f, -3.0f)];
    [movement addPointRelative:GLKVector2Make( 3.5f, -2.0f)];
	[movement lookAtRelativeToStart:GLKVector2Make(-1.8f, 1.3f) beginningAt:0.0f];
	[movement lookAtRelativeToEnd:GLKVector2Make(-0.7f, 1.5f) beginningAt:0.8f];
    [movement setRoomVisibilityOne:true two:true three:false four:false beginningAt:0.0f];

	// Forward tour mode
    

    // Start
    [movement setAngle:0.0f];
    [movement setPositionToFirstPoint];
}

- (GLKVector2) lookAt:(GLKVector2)p angle:(float)angle {
    angle -= M_PI_2;
    return GLKVector2Make(p.x + (cos(angle) * LOOK_AT_DISTANCE), p.y + (sin(angle) * LOOK_AT_DISTANCE));
}

- (void) prevPhoto {
    if ([movement canTurnAround]) {
	    [movement turnAround];
    }
}

- (void) nextPhoto {
    if ([movement canGoForwards]) {
	    [movement resume];
    }
}

- (void) toggleTour {
    if (![movement isOnTour]) {
        if ([movement isPaused]) {
	        [movement startTour];
        }
    } else {
        [movement stopTour];
    }
}

- (PhotoInfo*) getPhoto {
    return [movement getCurrentPhoto];
}

- (void) update {
    for (int i = 0; i < USER_PHOTOS_MAX_COUNT; i++) {
        [userPhotos[i] update];
    }
    [movement move:0.015f];
}

- (void) render {
    [self setupPosition];
    
    isRenderingMirror = true;
    [self renderMirroredFloor];

    isRenderingMirror = false;
    mirrorModelViewMatrix = GLKMatrix4Identity;
    
    [self renderRooms];
    [self renderFloor];
}

- (void) setupPosition {
    GLKVector3 v = [movement getPositionAndAngle];
    worldPosition = GLKVector3Make(v.x, -2.5f, v.y);
    sceneModelViewMatrix = GLKMatrix4Rotate(GLKMatrix4Identity, v.z, 0.0f, 1.0f, 0.0f);
    sceneModelViewMatrix = GLKMatrix4Translate(sceneModelViewMatrix, worldPosition.x, worldPosition.y, worldPosition.z);
}

- (void) renderMirroredFloor {
    GLint oldFramebuffer;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFramebuffer);

    GLint oldViewport[4];
	glGetIntegerv(GL_VIEWPORT, oldViewport);

    glBindFramebuffer(GL_FRAMEBUFFER, mirrorFramebuffer);
    
    glViewport(0, 0, offscreenTextureWidth, offscreenTextureHeight);

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    mirrorModelViewMatrix = GLKMatrix4MakeScale(1.0f, -1.0f, 1.0f);
    
    [self renderRooms];

    glBindFramebuffer(GL_FRAMEBUFFER, oldFramebuffer);
    glViewport(oldViewport[0], oldViewport[1], oldViewport[2], oldViewport[3]);
}

- (void) renderRooms {
    for (int i = 0; i < ROOM_COUNT; i++) {
        [rooms[i] render];
    }
    for (int i = 0; i < USER_PHOTOS_MAX_COUNT; i++) {
        [userPhotos[i] render];
    }
}

- (void) renderFloor {
    for (int i = 0; i < ROOM_COUNT; i++) {
        [rooms[i] renderFloor];
    }
}

- (bool) isTurnAroundButtonVisible {
    return [movement canTurnAround];
}

- (bool) isNextButtonVisible {
    return [movement canGoForwards];
}

- (bool) isPaused {
    return [movement isPaused];
}

- (bool) isOnTour {
    return [movement isOnTour];
}

@end

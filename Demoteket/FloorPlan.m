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
    offscreenTextureWidth = [self textureAtLeastSize:screenWidth];
    offscreenTextureHeight = [self textureAtLeastSize:screenHeight];
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

- (int) textureAtLeastSize:(int)size {
    int l = (int) log2(size);
    if ((int) pow(2, l) == size) {
        return size;
    } else {
        return (int) pow(2, l + 1);
    }
}

- (void) createFloorPlan {
    NSLog(@"Creating floor plan");

    floor = [[Quads alloc] init];
    [floor beginWithTexture:floorDistortionTexture];
    [floor addQuadHorizontalX1:-15.0f z1:-15.0f x2:15.0f z2:15.0f y:0.0f];
    [floor end];

    currentRoom = 0;

    for (int i = 0; i < ROOM_COUNT; i++) {
        rooms[i] = [[Room alloc] init];
    }
    [rooms[0] initializeRoomNumber:0];
    [rooms[1] initializeRoomNumber:1];

    [self createPath];
}

- (void) createPath {
    movement = [[Movement alloc] init];

    [movement addPoint:GLKVector2Make(-4.0f, -17.0f) pause:false];
    [movement addOffsetPoint:[self lookAt:GLKVector2Make(0.5f, 7.0f) angle:letterToAngle('D')] lookAt:GLKVector2Make(0.5f, 7.0f) pause:true];

    [movement addOffsetPoint:GLKVector2Make(-2.0f, -2.5f) lookAt:GLKVector2Make(4.0f, 13.0f)];
    [movement addOffsetPoint:GLKVector2Make(-1.5f,  0.0f)];
    [movement addOffsetPoint:GLKVector2Make(-1.0f,  1.5f)];
    [movement addOffsetPoint:GLKVector2Make( 2.0f,  4.5f)];
    [movement addOffsetPoint:[self lookAt:GLKVector2Make(2.6f, 7.0f) angle:-0.3f] lookAt:GLKVector2Make(2.4f, 7.0f) pause:true];

    [movement lookAt:GLKVector2Make(5.0f, 0.0f) continueDistance:0.7f];
    [movement addOffsetPoint:GLKVector2Make(3.5f, 3.5f)];
    [movement addOffsetPoint:[self lookAt:GLKVector2Make(0.5f, -1.0f) angle:letterToAngle('H')] pause:true];
    
    [movement addOffsetPoint:GLKVector2Make(2.5f, -5.0f) lookAt:GLKVector2Make(-6.0f, -9.0f)];
    [movement addOffsetPoint:GLKVector2Make(-5.0f, -3.0f) pause:true];

    [movement addOffsetPoint:GLKVector2Make(1.5f, -4.0f) lookAt:GLKVector2Make(1.0f, -3.0f) pause:true];

    [movement setAngle:0.0f];
    [movement setPositionToFirstPoint];
}

- (GLKVector2) lookAt:(GLKVector2)p angle:(float)angle {
    angle -= M_PI_2;
    return GLKVector2Make(p.x + (cos(angle) * LOOK_AT_DISTANCE), p.y + (sin(angle) * LOOK_AT_DISTANCE));
}

- (void) nextPhoto {
    [movement resume];
}

- (void) update {
    [movement move:0.015f];
}

- (void) render {
    [self setupPosition];
    
    isRenderingMirror = true;
    [self renderMirroredFloor];

    isRenderingMirror = false;
    mirrorModelViewMatrix = GLKMatrix4Identity;
    
    [self renderFloor];
    [self renderRooms];

	glDisable(GL_CULL_FACE);
}

- (void) setupPosition {
    GLKVector3 v = [movement getPositionAndAngle];
    sceneModelViewMatrix = GLKMatrix4Identity;
    sceneModelViewMatrix = GLKMatrix4Rotate(sceneModelViewMatrix, v.z, 0.0f, 1.0f, 0.0f);
    sceneModelViewMatrix = GLKMatrix4Translate(sceneModelViewMatrix, v.x, -2.5f, v.y);
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
    for (int i = currentRoom - 1; i < currentRoom + 2; i++) {
        if (i >= 0 && i < ROOM_COUNT) {
            [rooms[i] render];
        }
    }
}

- (void) renderFloor {
    currentShaderProgram = glslProgram;

    glDisable(GL_DEPTH_TEST);
    glDepthMask(false);

    [floor render];

    glEnable(GL_DEPTH_TEST);
    glDepthMask(true);

    currentShaderProgram = 0;
}

@end

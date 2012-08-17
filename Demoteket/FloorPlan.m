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

- (id) init {
    if (self = [super init]) {
        [self createMirrorFramebuffer];
    }
    return self;
}

- (void) dealloc {
}

- (void) createMirrorFramebuffer {
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
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, MIRROR_TEXTURE_WIDTH, MIRROR_TEXTURE_HEIGHT, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, mirrorTexture, 0);

    glBindRenderbuffer(GL_RENDERBUFFER, mirrorDepthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, MIRROR_TEXTURE_WIDTH, MIRROR_TEXTURE_HEIGHT);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, mirrorDepthBuffer);

    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) { 
        NSLog(@"failed to make complete framebuffer object %x", status);
        exit(-1);
    }

    glBindFramebuffer(GL_FRAMEBUFFER, oldFramebuffer);

    [textures setPhoto:mirrorTexture];
}

- (void) createFloorPlan {
    NSLog(@"Creating floor plan");

    floor = [[Quads alloc] init];
    //[floor beginWithTexture:[textures getFloorTexture]];
    //[floor setOrthoProjection];
    //[floor addQuadVerticalX1:0.0f y1:screenHeight z1:0.0f x2:screenWidth y2:0.0f z2:0.0f];
    [floor beginWithTexture:[textures getFloorDistortionTexture]];
    [floor addQuadHorizontalX1:-15.0f z1:-15.0f x2:15.0f z2:15.0f y:0.0f];
    [floor end];

    for (int i = 0; i < ROOM_COUNT; i++) {
        rooms[i] = [[Room alloc] init];
    }
    [rooms[0] initializeRoomNumber:0];
}

- (void) render {
    [self renderMirroredFloor];

    mirrorModelViewMatrix = GLKMatrix4Identity;
    
    [self renderFloor];
    [self renderRooms];
}

- (void) renderMirroredFloor {
    GLint oldFramebuffer;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFramebuffer);

    GLint oldViewport[4];
	glGetIntegerv(GL_VIEWPORT, oldViewport);

    glBindFramebuffer(GL_FRAMEBUFFER, mirrorFramebuffer);
    
    glViewport(0, 0, MIRROR_TEXTURE_WIDTH, MIRROR_TEXTURE_HEIGHT);

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

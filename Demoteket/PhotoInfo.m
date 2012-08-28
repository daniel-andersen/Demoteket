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

#import "PhotoInfo.h"

@implementation PhotoInfo

@synthesize position;
@synthesize angle;

@synthesize title;
@synthesize author;

@synthesize photoQuads;
@synthesize textQuads;

@synthesize photoImage;

@synthesize photoTexture;
@synthesize textTexture;

@synthesize photoIndex;
@synthesize textIndex;

@synthesize frontFacing;

- (id) init {
    if (self = [super init]) {
        showText = false;
        animation = 0.0f;
    }
    return self;
}

- (void) beginQuads {
    photoQuads = [[Quads alloc] init];
    [photoQuads beginWithTexture:photoTexture];
	[photoQuads setBackgroundColor:GLKVector4Make(0.0f, 0.0f, 0.0f, photoTexture.id != demoteketLogoTexture.id ? 1.0f : 0.0f)];
    
    textQuads = [[Quads alloc] init];
    [textQuads beginWithTexture:textTexture];
}

- (void) endQuads {
    [photoQuads end];
    [textQuads end];
}

- (void) update {
    if (showText && animation < 1.0f) {
        animation = MIN(animation + PHOTO_ANIMATION_SPEED, 1.0f);
    }
    if (!showText && animation > 0.0f) {
        animation = MAX(animation - PHOTO_ANIMATION_SPEED, 0.0f);
    }

    [photoQuads setDepthTestEnabled:animation <= 0.0f || animation >= 1.0f];
    [textQuads setDepthTestEnabled:animation <= 0.0f || animation >= 1.0f];

    float rot = ((2.0f - (cos(M_PI * (1.0f - animation)) + 1.0f)) / 2.0f) * M_PI;
    
    [photoQuads setRotation:GLKVector3Make(0.0f, rot + M_PI, 0.0f)];
    [textQuads setRotation:GLKVector3Make(0.0f, rot, 0.0f)];
}

- (void) turnAround {
    showText = !showText;
}

@end

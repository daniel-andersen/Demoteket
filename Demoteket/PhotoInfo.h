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

#import "Quads.h"

#define PHOTO_ANIMATION_SPEED 0.02f

@interface PhotoInfo : NSObject {

@private
    
    GLKVector2 position;
    float angle;
    
    NSString *title;
    NSString *author;
    
    Quads *photoQuads;
    Quads *textQuads;
    
    UIImage *photoImage;

    Texture photoTexture;
    Texture textTexture;

    int photoIndex;
    int textIndex;
    
    bool frontFacing;
    
    float animation;
    bool showText;
}

- (void) beginQuads;
- (void) endQuads;

- (void) update;

- (void) turnAround;

@property(readwrite) GLKVector2 position;
@property(readwrite) float angle;

@property(readwrite) NSString *title;
@property(readwrite) NSString *author;

@property(readwrite) Quads *photoQuads;
@property(readwrite) Quads *textQuads;

@property(readwrite) UIImage *photoImage;

@property(readwrite) Texture photoTexture;
@property(readwrite) Texture textTexture;

@property(readwrite) int photoIndex;
@property(readwrite) int textIndex;

@property(readwrite) bool frontFacing;

@end

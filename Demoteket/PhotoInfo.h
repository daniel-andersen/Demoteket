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

#define PHOTO_TRANSITION_SPEED 0.01f

@interface PhotoInfo : NSObject {

@private
    
    NSString *title;
    NSString *author;
    NSString *description;
    NSString *link;

    GLKVector2 roomPosition;
    int roomNumber;
    
    GLKVector2 position;
    float angle;
    float scale;
    
    Quads *photoQuads;
    Quads *borderQuads;
    Quads *backgroundQuads;

    NSString *photoFilename;

    Texture photoTexture;
    Texture textTexture;
}

@property(readwrite) GLKVector2 roomPosition;
@property(readwrite) int roomNumber;

@property(readwrite) GLKVector2 position;

@property(readwrite) NSString *title;
@property(readwrite) NSString *author;
@property(readwrite) NSString *description;
@property(readwrite) NSString *link;
@property(readwrite) NSString *photoFilename;

@property(readwrite) Texture photoTexture;
@property(readwrite) Texture textTexture;

- (id) initWithPosition:(GLKVector2)p roomNumber:(int)roomNum roomPosition:(GLKVector2)roomPos angle:(float)a scale:(float)s;

- (void) definePhotoTexture:(Texture)texture;
- (void) loadPhotoAsynchronously:(NSString*)filename;

- (bool) hasBorder;
- (bool) isClickable;

- (bool) isStaticPhoto;
- (bool) isStaticButNotLoadingPhoto;

- (void) setNoPhoto;

- (void) createTextTexture;
- (void) releaseTextTexture;

- (void) update;
- (void) render;

@end

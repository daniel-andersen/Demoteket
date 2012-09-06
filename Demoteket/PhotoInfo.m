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
#import "Globals.h"
#import "Room.h"

@implementation PhotoInfo

@synthesize roomPosition;
@synthesize title;
@synthesize author;
@synthesize description;
@synthesize photoTexture;
@synthesize textTexture;

- (id) initWithPosition:(GLKVector2)p roomPosition:(GLKVector2)roomPos angle:(float)a scale:(float)s {
    if (self = [super init]) {
        position = p;
        roomPosition = roomPos;
        angle = a;
        scale = s;
        description = @"Dette er en test af demotek aarhus uden internetforbindelse i en bus som ryster helt vildt!";
        [self initialize];
    }
    return self;
}

- (void) initialize {
    photoFilename = NULL;
    photoTexture = photoLoadingTexture;
    [self addPhotoQuads];
}

- (void) definePhotoTexture:(Texture)texture {
    [self photoLoaded:texture];
}

- (void) loadPhotoAsynchronously:(NSString*)filename {
    if ([photoFilename isEqualToString:filename]) {
        return;
    }
    photoFilename = filename;
    if ([filename hasPrefix:@"http"]) {
        NSLog(@"Loading asynchronously: %@", filename);
        [textures loadPhotoAsyncFromUrl:[NSURL URLWithString:filename] callback:^(Texture t) {
            [self photoLoaded:t];
        }];
    } else {
        NSLog(@"Loading synchronously: %@", filename);
        [self photoLoaded:[textures photoFromFile:filename]];
    }
}

- (void) photoLoaded:(Texture)texture {
    if (photoFilename != NULL) {
	    NSLog(@"Loaded photo: %@", photoFilename);
    }
    [self releasePhotoTexture];
    photoTexture = texture;
    [self addPhotoQuads];
}

- (bool) hasBorder {
	return ![self isStaticPhoto];
}

- (bool) isClickable {
	return ![self isStaticPhoto];
}

- (bool) isStaticPhoto {
	return photoTexture.id == demoteketLogoTexture.id || photoTexture.id == photoLoadingTexture.id;
}

- (void) addPhotoQuads {
    float maxSize = MAX(photoTexture.width, photoTexture.height);
    float width = scale * (photoTexture.width / maxSize);
    float height = scale * (photoTexture.height / aspectRatio / maxSize);
    
    photoQuads = [[Quads alloc] init];
    [photoQuads beginWithTexture:photoTexture];

    borderQuads = [[Quads alloc] init];
    [borderQuads beginWithColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)];

    backgroundQuads = [[Quads alloc] init];
    [backgroundQuads beginWithTexture:photoBackgroundTexture];

    [Room addPhotoQuads:photoQuads x:position.x y:ROOM_HEIGHT / 2.0f z:position.y width:width height:height horizontalOffset:0.0f verticalOffset:0.0f angle:angle borderSize:PHOTO_BORDER_WIDTH];

    if ([self hasBorder]) {
        [Room addPhotoBorder:borderQuads x:position.x y:ROOM_HEIGHT / 2.0f z:position.y width:width height:height horizontalOffset:0.0f verticalOffset:0.0f angle:angle];
        [Room addPhotoBackground:backgroundQuads x:position.x y:ROOM_HEIGHT / 2.0f z:position.y width:width height:height angle:angle];
    }
    
    [photoQuads end];
    [borderQuads end];
    [backgroundQuads end];
}

- (void) createTextTexture {
    [EAGLContext setCurrentContext:openglContext];
    [self releaseTextTexture];
    textTexture = [textures textToTexture:description width:textureAtLeastSize(screenWidthNoScale) height:textureAtLeastSize(screenHeightNoScale) asPhoto:false];
    textTexture.released = false;
}

- (void) releasePhotoTexture {
    if ([self isStaticPhoto]) {
        return;
    }
    textureRelease(&photoTexture);
}

- (void) releaseTextTexture {
    textureRelease(&textTexture);
}

- (void) update {
}

- (void) render {
    glDepthMask(GL_FALSE);
    [backgroundQuads render];
    glDepthMask(GL_TRUE);
    
    [photoQuads render];
    [borderQuads render];
}

@end

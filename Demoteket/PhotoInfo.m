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
@synthesize roomNumber;
@synthesize position;
@synthesize title;
@synthesize author;
@synthesize description;
@synthesize link;
@synthesize photoFilename;
@synthesize photoTexture;
@synthesize textTexture;

- (id) initWithPosition:(GLKVector2)p roomNumber:(int)roomNum roomPosition:(GLKVector2)roomPos angle:(float)a scale:(float)s {
    if (self = [super init]) {
        position = p;
        roomNumber = roomNum;
        roomPosition = roomPos;
        angle = a;
        scale = s;
        [self initialize];
    }
    return self;
}

- (void) dealloc {
    [self releasePhotoTexture];
    [self releaseTextTexture];
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
        [textures loadPhotoAsyncFromUrl:[NSURL URLWithString:[filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] callback:^(Texture t) {
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
	return photoTexture.id == demoteketLogoTexture.id || photoTexture.id == photoLoadingTexture.id || photoTexture.id == trollsAheadLogoTexture.id || photoTexture.id == noPhotoTexture.id;
}

- (bool) isStaticButNotLoadingPhoto {
	return [self isStaticPhoto] && photoTexture.id != photoLoadingTexture.id && photoTexture.id != noPhotoTexture.id;
}

- (void) setNoPhoto {
    photoQuads.texture = noPhotoTexture;
}

- (void) addPhotoQuads {
    float actualScale = photoTexture.id == photoLoadingTexture.id || photoTexture.id == noPhotoTexture.id ? 1.0f : scale;
    
    float maxSize = MAX(photoTexture.width, photoTexture.height);
    float width = actualScale * (photoTexture.width / maxSize);
    float height = actualScale * (photoTexture.height / aspectRatio / maxSize);
    
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
    NSString *text = [[title stringByAppendingString:@"\n\n"] stringByAppendingString:description];
    [textures textToTexture:text width:textureAtLeastSize(screenWidthNoScale) height:textureAtLeastSize(screenHeightNoScale) texture:&textTexture];
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

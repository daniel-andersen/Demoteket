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

@implementation PhotoInfo

@synthesize position;

@synthesize title;
@synthesize author;

@synthesize photoQuads;
@synthesize textQuads;

@synthesize photoImage;

@synthesize textTexture;

@synthesize frontFacing;

- (id) init {
    if (self = [super init]) {
        callbackHandler = nil;
        photoImage = NULL;
        photoTexture.isReadyForRendering = false;
        photoThumbTexture.isReadyForRendering = false;
    }
    return self;
}

- (void) setPhotoTexture:(Texture)texture {
    photoTexture = texture;
    photoTexture.isReadyForRendering = true;
}

- (Texture) getPhotoTexture {
    if (photoTexture.isReadyForRendering) {
        return photoTexture;
    }
    if (photoThumbTexture.isReadyForRendering) {
        return photoThumbTexture;
    }
    return photoLoadingTexture;
}

- (Texture) getFullSizePhotoTexture {
    return photoTexture;
}

- (void) loadPhotoAsynchronously:(NSString*)filename {
    photoFilename = filename;
    if ([filename hasPrefix:@"http"]) {
        NSLog(@"Loading asynchronously: %@", filename);
        [textures loadPhotoAsyncFromUrl:[NSURL URLWithString:filename] callback:^(Texture t) {
            [self photoLoaded:t];
        }];
    } else {
        NSLog(@"Loading synchronously: %@", filename);
        photoImage = [UIImage imageNamed:photoFilename];
        [self photoLoaded:[textures photoFromImage:photoImage]];
    }
}

- (void) photoLoaded:(Texture)texture {
    NSLog(@"Asynchronous loaded photo: %@", photoFilename);
    photoTexture = texture;
    photoTexture.isReadyForRendering = true;
    if (callbackHandler != nil) {
	    callbackHandler();
    }
}

- (void) setFinishedLoadingCallback:(void(^)())callback {
    callbackHandler = [callback copy];
}

@end

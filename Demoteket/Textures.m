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

#import "Textures.h"

@implementation Textures

static float PHOTOS_LIGHT_TEXTURE_OFFSET[] = {0.0f, 0.1404f, 1.0f, 1.0f - 0.1404f};

- (void) load {
    wall[0] = [self loadTexture:@"wall.png"];
    photos[0] = [self loadTexture:@"photo1.png"];
    photos[1] = [self loadTexture:@"photo1.png"];
    photosLight[0] = [self loadTexture:@"photosLight1.png"];
    photosLight[1] = [self loadTexture:@"photosLight2.png"];
    floorDistortion = [self loadTexture:@"floor_distortion.png"];
}

- (void) setPhoto:(GLuint)texture {
    floor = texture;
}

- (GLuint) getWallTexture:(int)index {
    return wall[index];
}

- (GLuint) getFloorTexture {
    return floor;
}

- (GLuint) getFloorDistortionTexture {
    return floorDistortion;
}

- (GLuint) getPhotosTexture:(int)index {
    return photos[index];
}

- (GLuint) getPhotosLightTexture:(int)index {
    return photosLight[index];
}

- (float) getTextureOffsetX1:(GLuint)textureId {
    if (textureId == photosLight[1]) {
        return PHOTOS_LIGHT_TEXTURE_OFFSET[0];
    }
    return 0.0f;
}

- (float) getTextureOffsetY1:(GLuint)textureId {
    if (textureId == photosLight[1]) {
        return PHOTOS_LIGHT_TEXTURE_OFFSET[1];
    }
    return 0.0f;
}

- (float) getTextureOffsetX2:(GLuint)textureId {
    if (textureId == photosLight[1]) {
        return PHOTOS_LIGHT_TEXTURE_OFFSET[2];
    }
    return 1.0f;
}

- (float) getTextureOffsetY2:(GLuint)textureId {
    if (textureId == photosLight[1]) {
        return PHOTOS_LIGHT_TEXTURE_OFFSET[3];
    }
    return 1.0f;
}

- (GLuint) loadTexture:(NSString*)filename {
    NSLog(@"Loading texture: %@", filename);
    UIImage *image = [UIImage imageNamed:filename];
    NSError *error = nil;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:&error];
    if (error) {
        NSLog(@"Error loading texture %@: %@", filename, error);
    }
    return textureInfo.name;
}

@end

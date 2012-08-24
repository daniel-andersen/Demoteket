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

Texture wallTexture[WALL_TEXTURE_COUNT];
Texture wallBorderTexture;

Texture pillarTexture;
Texture pillarBorderTexture;

Texture photosTexture[PHOTOS_TEXTURE_COUNT];

Texture floorTexture;
Texture floorDistortionTexture;

Texture nextButtonTexture;
Texture prevButtonTexture;

Texture textureMake(GLuint id) {
    Texture texture;
    texture.texCoordX1 = 0.0f;
    texture.texCoordY1 = 0.0f;
    texture.texCoordX2 = 1.0f;
    texture.texCoordY2 = 1.0f;
    texture.blendEnabled = false;
    texture.id = id;
    return texture;
}

Texture textureCopy(Texture texture, float texCoordX1, float texCoordY1, float texCoordX2, float texCoordY2) {
    Texture newTexture;
    newTexture.id = texture.id;
    newTexture.blendEnabled = texture.blendEnabled;
    newTexture.texCoordX1 = texCoordX1;
    newTexture.texCoordY1 = texCoordY1;
    newTexture.texCoordX2 = texCoordX2;
    newTexture.texCoordY2 = texCoordY2;
    return newTexture;
}

void textureSetTexCoords(Texture *texture, float texCoordX1, float texCoordY1, float texCoordX2, float texCoordY2) {
    texture->texCoordX1 = texCoordX1;
    texture->texCoordY1 = texCoordY1;
    texture->texCoordX2 = texCoordX2;
    texture->texCoordY2 = texCoordY2;
}

void textureSetBlend(Texture *texture, GLenum blendSrc, GLenum blendDst) {
    texture->blendEnabled = true;
    texture->blendSrc = blendSrc;
    texture->blendDst = blendDst;
}

@implementation Textures

- (void) load {
    nextButtonTexture = [self loadTexture:@"next_button.png"]; textureSetBlend(&nextButtonTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    prevButtonTexture = [self loadTexture:@"prev_button.png"]; textureSetBlend(&prevButtonTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    wallTexture[0] = [self loadTexture:@"wall1.png"];
    wallTexture[1] = [self loadTexture:@"wall2.png"];
    wallTexture[2] = wallTexture[0]; textureSetTexCoords(&wallTexture[2], 0.0f, 0.0f, 0.25f, 1.0f);
    wallTexture[3] = wallTexture[0]; textureSetTexCoords(&wallTexture[3], 1.0f, 0.0f, 0.75f, 1.0f);
    wallTexture[4] = wallTexture[1]; textureSetTexCoords(&wallTexture[4], 0.0f, 0.0f, 0.25f, 1.0f);
    wallTexture[5] = wallTexture[1]; textureSetTexCoords(&wallTexture[5], 0.75f, 0.0f, 1.0f, 1.0f);

    wallBorderTexture = textureCopy(wallTexture[2], 0.0f, 0.0f, 0.1f, 1.0f);

    pillarTexture = [self loadTexture:@"pillar.png"];
    pillarBorderTexture = textureCopy(pillarTexture, 0.0f, 0.0f, 0.1f, 1.0f);
    
    photosTexture[0] = [self loadTexture:@"photo1.png"];
    photosTexture[1] = [self loadTexture:@"photo2.png"];
    photosTexture[2] = [self loadTexture:@"photo3.png"];
    photosTexture[3] = [self loadTexture:@"photo4.png"]; textureSetTexCoords(&photosTexture[3], 0.0f, 0.0f, 1.0f, 0.7382f);
    photosTexture[4] = [self loadTexture:@"photo5.png"]; textureSetTexCoords(&photosTexture[4], 0.0f, 0.0f, 0.9062f, 1.0f);
    photosTexture[5] = [self loadTexture:@"demoteket_logo.png"]; textureSetBlend(&photosTexture[5], GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    floorDistortionTexture = [self loadTexture:@"floor_distortion.png" repeat:true]; textureSetTexCoords(&floorDistortionTexture, 0.0f, 0.0f, 55.0f, 55.0f);
}

- (Texture) loadTexture:(NSString*)filename {
    return [self loadTexture:filename repeat:false];
}

- (Texture) loadTexture:(NSString*)filename repeat:(bool)repeat {
    NSLog(@"Loading texture: %@", filename);
    UIImage *image = [UIImage imageNamed:filename];
    NSError *error = nil;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:&error];
    if (error) {
        NSLog(@"Error loading texture %@: %@", filename, error);
    }
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    if (repeat) {
	    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    }
	glBindTexture(GL_TEXTURE_2D, 0);
    Texture texture = textureMake(textureInfo.name);
    return texture;
}

@end

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

#define USER_PHOTOS_MAX_COUNT 32

#define WALL_TEXTURE_COUNT 6
#define PHOTOS_TEXTURE_COUNT (3 + USER_PHOTOS_MAX_COUNT)
#define LIGHT_TYPE_COUNT 3

#define PHOTO_INDEX_DEMOTEKET_LOGO 5

#define TEXT_BORDER 10
#define PHOTO_WHITE_BORDER_PCT 0.05f
#define PHOTO_BLACK_BORDER_PCT 0.02f

typedef struct {
    GLuint id;
    int width, height;
    int imageWidth, imageHeight;
    float texCoordX1, texCoordY1, texCoordX2, texCoordY2;
    bool blendEnabled;
    GLenum blendSrc, blendDst;
} Texture;

extern Texture textureMake(GLuint id);
extern Texture textureCopy(Texture texture, float texCoordX1, float texCoordY1, float texCoordX2, float texCoordY2);
extern void textureSetTexCoords(Texture *texture, float texCoordX1, float texCoordY1, float texCoordX2, float texCoordY2);
extern void textureSetBlend(Texture *texture, GLenum blendSrc, GLenum blendDst);

extern Texture wallTexture[WALL_TEXTURE_COUNT];
extern Texture wallBorderTexture;

extern Texture pillarTexture;
extern Texture pillarBorderTexture;

extern Texture photosTexture[PHOTOS_TEXTURE_COUNT];
extern int photosTextureCount;

extern Texture demoteketLogoTexture;

extern Texture floorTexture;
extern Texture floorDistortionTexture;

extern Texture lightTexture[LIGHT_TYPE_COUNT];

extern Texture nextButtonTexture;
extern Texture prevButtonTexture;
extern Texture tourButtonTexture;
extern Texture cameraButtonTexture;

extern void loadTextures();

@interface Textures : NSObject

- (void) load;

- (Texture) loadTexture:(NSString*)filename;
- (Texture) loadTexture:(NSString*)filename repeat:(bool)repeat;

- (Texture) textToTexture:(NSString*)text withSizeOf:(Texture)texture asPhoto:(bool)asPhoto;
- (Texture) textToTexture:(NSString*)text width:(int)width height:(int)height asPhoto:(bool)asPhoto;
- (Texture) textToTexture:(NSString*)text width:(int)width height:(int)height color:(UIColor*)color backgroundColor:(UIColor*)bgColor asPhoto:(bool)asPhoto;

- (Texture) photoFromFile:(NSString*)filename;

@end

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

#define QUADS_MAX_COUNT 256
#define VERTICES_MAX_COUNT (QUADS_MAX_COUNT * 9 * 3 * sizeof(GLfloat))

typedef struct {
    float x1, y1, z1;
    float x2, y2, z2;
    float x3, y3, z3;
    float x4, y4, z4;
} Quad;

@interface Quads : NSObject {

@private

    Quad quads[QUADS_MAX_COUNT];
    int quadCount;
    
    GLKTextureInfo *textureInfo;
    GLKEffectPropertyTexture *textureProperty;
    bool textureToggled;

    GLKVector4 color;
    
    GLfloat vertices[VERTICES_MAX_COUNT];
    
    GLuint vertexArray;
    GLuint vertexBuffer;
}

- (id) init;
- (void) dealloc;

- (void) beginWithColor:(GLKVector4)col;
- (void) beginWithTexture:(GLKTextureInfo*)texture;
- (void) beginWithTexture:(GLKTextureInfo*)texture color:(GLKVector4)col;
- (void) end;

- (void) calculateNormals;

- (void) addQuadVerticalX1:(float)x1 y1:(float)y1 z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2;
- (void) addQuadHorizontalX1:(float)x1 z1:(float)z1 x2:(float)x2 z2:(float)z2 y:(float)y;
- (void) addQuadX1:(float)x1 y1:(float)y1 z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2 x3:(float)x3 y3:(float)y3 z3:(float)z3 x4:(float)x4 y4:(float)y4 z4:(float)z4;

- (void) render;

@end
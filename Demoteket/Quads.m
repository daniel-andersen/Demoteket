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
#import "Globals.h"

@implementation Quads

- (id) init {
    if (self = [super init]) {
    }
    return self;
}

- (void) dealloc {
    if (quadCount != 0) {
	    glDeleteBuffers(1, &vertexBuffer);
		glDeleteVertexArraysOES(1, &vertexArray);
    }
}

- (void) beginWithColor:(GLKVector4)col {
    quadCount = 0;
    textureToggled = false;
    color = col;
}

- (void) beginWithTexture:(GLKTextureInfo*)texture {
    [self beginWithTexture:texture color:GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)];
}

- (void) beginWithTexture:(GLKTextureInfo*)texture color:(GLKVector4)col {
    quadCount = 0;
    textureInfo = texture;
    textureToggled = true;
    color = col;
}

- (void) end {
    if (quadCount == 0) {
        return;
    }
    int v = 0;
    for (int i = 0; i < quadCount; i++) {
        
        // Triangle 1
        vertices[v + 0] = quads[i].x1;
        vertices[v + 1] = quads[i].y1;
        vertices[v + 2] = quads[i].z1;
        vertices[v + 3] = [textures getTextureOffsetX1:textureInfo];
        vertices[v + 4] = [textures getTextureOffsetY2:textureInfo];
		v += 8;
        
        vertices[v + 0] = quads[i].x2;
        vertices[v + 1] = quads[i].y2;
        vertices[v + 2] = quads[i].z2;
        vertices[v + 3] = [textures getTextureOffsetX1:textureInfo];
        vertices[v + 4] = [textures getTextureOffsetY1:textureInfo];
		v += 8;
        
        vertices[v + 0] = quads[i].x3;
        vertices[v + 1] = quads[i].y3;
        vertices[v + 2] = quads[i].z3;
        vertices[v + 3] = [textures getTextureOffsetX2:textureInfo];
        vertices[v + 4] = [textures getTextureOffsetY1:textureInfo];
		v += 8;
        
        // Triangle 2
        vertices[v + 0] = quads[i].x3;
        vertices[v + 1] = quads[i].y3;
        vertices[v + 2] = quads[i].z3;
        vertices[v + 3] = [textures getTextureOffsetX2:textureInfo];
        vertices[v + 4] = [textures getTextureOffsetY1:textureInfo];
		v += 8;
        
        vertices[v + 0] = quads[i].x4;
        vertices[v + 1] = quads[i].y4;
        vertices[v + 2] = quads[i].z4;
        vertices[v + 3] = [textures getTextureOffsetX2:textureInfo];
        vertices[v + 4] = [textures getTextureOffsetY2:textureInfo];
		v += 8;
        
        vertices[v + 0] = quads[i].x1;
        vertices[v + 1] = quads[i].y1;
        vertices[v + 2] = quads[i].z1;
        vertices[v + 3] = [textures getTextureOffsetX1:textureInfo];
        vertices[v + 4] = [textures getTextureOffsetY2:textureInfo];
		v += 8;
	}
    [self calculateNormals];
    
    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), BUFFER_OFFSET(0));

    if (textureToggled) {
    	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    	glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), BUFFER_OFFSET(3));
    } else {
    	glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), BUFFER_OFFSET(5));
    
    glBindVertexArrayOES(0);
    
    textureProperty = [[GLKEffectPropertyTexture alloc] init];
    if (textureToggled) {
    	textureProperty.enabled = YES;
        textureProperty.envMode = GLKTextureEnvModeDecal;
        textureProperty.name = textureInfo.name;
    } else {
    	textureProperty.enabled = NO;
    }
}

- (void) calculateNormals {
    int v = 0;
    for (int i = 0; i < quadCount * 8; i++) {
        vertices[v + 5] = 1.0f;
        vertices[v + 6] = 0.0f;
        vertices[v + 7] = 0.0f;
        v += 8;
    }
}

- (void) addQuadVerticalX1:(float)x1 y1:(float)y1 z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2 {
    [self addQuadX1:x1 y1:y1 z1:z1 x2:x1 y2:y2 z2:z1 x3:x2 y3:y2 z3:z2 x4:x2 y4:y1 z4:z2];
}

- (void) addQuadHorizontalX1:(float)x1 z1:(float)z1 x2:(float)x2 z2:(float)z2 y:(float)y {
    [self addQuadX1:x1 y1:y z1:z1 x2:x1 y2:y z2:z2 x3:x2 y3:y z3:z2 x4:x2 y4:y z4:z1];
}

- (void) addQuadX1:(float)x1 y1:(float)y1 z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2 x3:(float)x3 y3:(float)y3 z3:(float)z3 x4:(float)x4 y4:(float)y4 z4:(float)z4 {
    if (quadCount >= QUADS_MAX_COUNT) {
        NSLog(@"Too many quads!");
    }
    quads[quadCount].x1 = x1;
    quads[quadCount].y1 = y1;
    quads[quadCount].z1 = z1;
    quads[quadCount].x2 = x2;
    quads[quadCount].y2 = y2;
    quads[quadCount].z2 = z2;
    quads[quadCount].x3 = x3;
    quads[quadCount].y3 = y3;
    quads[quadCount].z3 = z3;
    quads[quadCount].x4 = x4;
    quads[quadCount].y4 = y4;
    quads[quadCount].z4 = z4;
    quadCount++;
}

- (void) render {
    glkEffect.texture2d0.name = textureProperty.name;
    glkEffect.texture2d0.enabled = textureToggled ? GL_TRUE : GL_FALSE;
    
    glkEffect.useConstantColor = YES;
    glkEffect.constantColor = color;

    glkEffect.transform.modelviewMatrix = GLKMatrix4Multiply(sceneModelViewMatrix, mirrorModelViewMatrix);
	
    [glkEffect prepareToDraw];
    
    glBindVertexArrayOES(vertexArray);
    glDrawArrays(GL_TRIANGLES, 0, quadCount * 6);
}

@end

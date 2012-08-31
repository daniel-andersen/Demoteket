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

#ifndef Demoteket_Globals_h
#define Demoteket_Globals_h

#import <GLKit/GLKit.h>

#import "Textures.h"
#import "PhotoInfo.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i * sizeof(GLfloat)))

PhotoInfo *userPhotos[USER_PHOTOS_MAX_COUNT];
int userPhotosCount;

Textures *textures;
GLKBaseEffect *glkEffectNormal;
GLKBaseEffect *glkEffectShader;

GLKVector3 worldPosition;

GLKMatrix4 sceneModelViewMatrix;
GLKMatrix4 sceneProjectionMatrix;

GLKMatrix4 mirrorModelViewMatrix;

GLKMatrix4 orthoProjectionMatrix;
GLKMatrix4 orthoModelViewMatrix;

bool isRenderingMirror;

float screenWidth;
float screenHeight;
float screenWidthNoScale;
float screenHeightNoScale;
float aspectRatio;

GLuint glslProgram;
GLuint uniformModelViewProjectionMatrix;
GLuint uniformSampler1;
GLuint uniformSampler2;
GLuint uniformScreenSizeInv;
GLuint uniformOffscreenSizeInv;
GLuint uniformRefractionConstant;

GLfloat screenSizeInv[2];
GLfloat offscreenSizeInv[2];
GLfloat refractionConstant;

GLuint currentShaderProgram;

GLKTextureLoader *textureLoader;

extern float letterToAngle(char ch);
extern int textureAtLeastSize(int size);

#endif

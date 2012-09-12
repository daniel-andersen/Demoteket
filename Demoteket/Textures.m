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

#import <QuartzCore/QuartzCore.h>
#import "Textures.h"
#import "Globals.h"

Texture wallTexture[WALL_TEXTURE_COUNT];
Texture wallBorderTexture;

Texture pillarTexture;
Texture pillarBorderTexture;

Texture photosTexture[PHOTOS_TEXTURE_COUNT];
int photosTextureCount = 0;

Texture demoteketLogoTexture;
Texture trollsAheadLogoTexture;

Texture floorTexture;
Texture floorDistortionTexture;

Texture lightTexture[LIGHT_TYPE_COUNT];

Texture nextButtonTexture;
Texture turnAroundButtonTexture;
Texture tourButtonTexture;
Texture turnAroundPhotoButtonTexture;
Texture blogButtonTexture;

Texture photoLoadingTexture;
Texture photoBackgroundTexture;

Texture labelTexture;
UIImage *textImage;

Texture textureMake(GLuint id) {
    Texture texture;
    texture.texCoordX1 = 0.0f;
    texture.texCoordY1 = 0.0f;
    texture.texCoordX2 = 1.0f;
    texture.texCoordY2 = 1.0f;
    texture.blendEnabled = false;
    texture.id = id;
    texture.released = false;
    return texture;
}

Texture textureCopy(Texture texture, float texCoordX1, float texCoordY1, float texCoordX2, float texCoordY2) {
    Texture newTexture;
    newTexture.id = texture.id;
    newTexture.blendEnabled = texture.blendEnabled;
    newTexture.blendSrc = texture.blendSrc;
    newTexture.blendDst = texture.blendDst;
    newTexture.texCoordX1 = texCoordX1;
    newTexture.texCoordY1 = texCoordY1;
    newTexture.texCoordX2 = texCoordX2;
    newTexture.texCoordY2 = texCoordY2;
    newTexture.released = false;
    return newTexture;
}

void textureCopyTo(Texture src, Texture *dst) {
    dst->id = src.id;
    dst->blendEnabled = src.blendEnabled;
    dst->blendSrc = src.blendSrc;
    dst->blendDst = src.blendDst;
    dst->texCoordX1 = src.texCoordX1;
    dst->texCoordY1 = src.texCoordY1;
    dst->texCoordX2 = src.texCoordX2;
    dst->texCoordY2 = src.texCoordY2;
    dst->released = false;
}

void textureRelease(Texture *texture) {
    if (texture->released) {
        return;
    }
    glDeleteTextures(1, &texture->id);
    texture->released = true;
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
    turnAroundButtonTexture = [self loadTexture:@"prev_button.png"]; textureSetBlend(&turnAroundButtonTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    tourButtonTexture = [self loadTexture:@"tour_button.png"]; textureSetBlend(&tourButtonTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    turnAroundPhotoButtonTexture = [self loadTexture:@"turn_around_button.png"]; textureSetBlend(&turnAroundPhotoButtonTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    blogButtonTexture = [self loadTexture:@"blog_button.png"]; textureSetBlend(&blogButtonTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    wallTexture[0] = [self loadTexture:@"wall1.png"];
    wallTexture[1] = [self loadTexture:@"wall2.png"];
    wallTexture[2] = wallTexture[0]; textureSetTexCoords(&wallTexture[2], 0.5f, 0.0f, 1.0f, 1.0f);
    wallTexture[3] = wallTexture[0]; textureSetTexCoords(&wallTexture[3], 0.0f, 0.0f, 0.5f, 1.0f);
    wallTexture[4] = wallTexture[1]; textureSetTexCoords(&wallTexture[4], 0.5f, 0.0f, 1.0f, 1.0f);
    wallTexture[5] = wallTexture[1]; textureSetTexCoords(&wallTexture[5], 0.0f, 0.0f, 0.5f, 1.0f);

    wallBorderTexture = textureCopy(wallTexture[2], 0.0f, 0.0f, 0.1f, 1.0f);

    pillarTexture = [self loadTexture:@"pillar.png"];
    pillarBorderTexture = textureCopy(pillarTexture, 0.0f, 0.0f, 0.1f, 1.0f);
    
    photosTexture[photosTextureCount++] = [self loadTexture:@"photo1.png"];
    photosTexture[photosTextureCount++] = [self loadTexture:@"photo2.png"];
    photosTexture[photosTextureCount++] = [self loadTexture:@"photo3.png"];

    lightTexture[0] = [self loadTexture:@"light1.png"];
    lightTexture[1] = [self loadTexture:@"light2.png"];
    lightTexture[2] = [self loadTexture:@"light3.png"];
    
    demoteketLogoTexture = [self loadTexture:@"demoteket_logo.png"]; textureSetBlend(&demoteketLogoTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    trollsAheadLogoTexture = [self loadTexture:@"trolls_ahead_logo.png"]; textureSetBlend(&trollsAheadLogoTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    photoLoadingTexture = [self loadTexture:@"loading_photo.png"]; textureSetBlend(&photoLoadingTexture, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); textureSetTexCoords(&photoLoadingTexture, 0.0f, 0.1679f, 1.0f, 1.0f - 0.1679f);
    photoBackgroundTexture = [self loadTexture:@"photo_background.png"];

    floorDistortionTexture = [self loadTexture:@"floor_distortion.png" repeat:true]; textureSetTexCoords(&floorDistortionTexture, 0.0f, 0.0f, 55.0f, 55.0f);
}

- (void) dealloc {
    NSLog(@"Releasing textures");
    textureRelease(&nextButtonTexture);
    textureRelease(&turnAroundButtonTexture);
    textureRelease(&tourButtonTexture);
    textureRelease(&turnAroundPhotoButtonTexture);
    textureRelease(&blogButtonTexture);
    
    for (int i = 0; i < WALL_TEXTURE_COUNT; i++) {
	    textureRelease(&wallTexture[i]);
    }
    
    textureRelease(&wallBorderTexture);
    
    textureRelease(&pillarTexture);
    textureRelease(&pillarBorderTexture);
    
    for (int i = 0; i < PHOTOS_TEXTURE_COUNT; i++) {
	    textureRelease(&photosTexture[i]);
    }
    for (int i = 0; i < LIGHT_TYPE_COUNT; i++) {
	    textureRelease(&lightTexture[i]);
    }
    
    textureRelease(&demoteketLogoTexture);
    textureRelease(&trollsAheadLogoTexture);
    textureRelease(&photoLoadingTexture);
    textureRelease(&photoBackgroundTexture);
    textureRelease(&floorDistortionTexture);
}

- (Texture) loadTexture:(NSString*)filename {
    return [self loadTexture:filename repeat:false];
}

- (Texture) loadTexture:(NSString*)filename repeat:(bool)repeat {
    NSLog(@"Loading texture: %@", filename);
    return [self loadTextureWithImage:[UIImage imageNamed:filename] repeat:repeat];
}

- (Texture) loadTextureWithImage:(UIImage*)image repeat:(bool)repeat {
    NSError *error = nil;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:&error];
    if (error) {
        NSLog(@"Error loading texture: %@", error);
    }
    return [self textureFromTextureInfo:textureInfo repeat:repeat];
}

- (void) loadPhotoAsyncFromUrl:(NSURL*)url callback:(void(^)(Texture))callback {
    [textureLoader textureWithContentsOfURL:url options:nil queue:NULL completionHandler:^(GLKTextureInfo *textureInfo, NSError *error) {
        if (error) {
            NSLog(@"Error loading texture asynchronously: %@", error);
        }
        Texture texture = [self textureFromTextureInfo:textureInfo repeat:false];
        callback(texture);
    }];
}

- (void) loadTextureWithImageAsync:(UIImage*)image texture:(Texture*)texture {
    [textureLoader textureWithCGImage:image.CGImage options:nil queue:NULL completionHandler:^(GLKTextureInfo *textureInfo, NSError *error) {
        if (error) {
            NSLog(@"Error loading texture asynchronously: %@", error);
        }
        textureCopyTo([self textureFromTextureInfo:textureInfo repeat:false], texture);
    }];
}

- (Texture) textureFromTextureInfo:(GLKTextureInfo*)textureInfo repeat:(bool)repeat {
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    if (repeat) {
	    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    }
	glBindTexture(GL_TEXTURE_2D, 0);
    Texture texture = textureMake(textureInfo.name);
    texture.width = textureInfo.width;
    texture.height = textureInfo.height;
    texture.imageWidth = textureInfo.width;
    texture.imageHeight = textureInfo.height;
    return texture;
}

- (void) textToTexture:(NSString*)text width:(int)width height:(int)height texture:(Texture*)texture {
    [self textToTexture:text width:width height:height color:[UIColor colorWithRed:248.0f / 255.0f green:230.0f / 255.0f blue:213.0f / 255.0f alpha:1.0f] backgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f] texture:texture];
}

- (void) textToTexture:(NSString*)text width:(int)width height:(int)height color:(UIColor*)color backgroundColor:(UIColor*)bgColor texture:(Texture*)texture {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    label.text = text;
    label.font = [UIFont fontWithName:@"Times New Roman" size:24.0f];
    label.textColor = color;
    label.backgroundColor = bgColor;
    label.numberOfLines = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIGraphicsBeginImageContext(label.bounds.size);
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, 0);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, 1.0);
        
        [label.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        textImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        [self loadTextureWithImageAsync:textImage texture:texture];
    });
}

- (Texture) photoFromFile:(NSString*)filename {
    NSLog(@"Converting texture to photo: %@", filename);
    return [self photoFromImage:[UIImage imageNamed:filename]];
}

- (Texture) photoFromImage:(UIImage*)image {
    float whiteBorderWidth = (float) image.size.width * PHOTO_WHITE_BORDER_PCT;
    float whiteBorderHeight = (float) image.size.height * PHOTO_WHITE_BORDER_PCT;
    
    float blackBorderWidth = (float) image.size.width * PHOTO_BLACK_BORDER_PCT;
    float blackBorderHeight = (float) image.size.height * PHOTO_BLACK_BORDER_PCT;

    UIGraphicsBeginImageContext(CGSizeMake(image.size.width + (whiteBorderWidth * 2), image.size.height + (whiteBorderHeight * 2)));
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);

    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    UIRectFill(CGRectMake(0, 0, image.size.width + (whiteBorderWidth * 2), image.size.height + (whiteBorderHeight * 2)));

    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    UIRectFill(CGRectMake(blackBorderWidth, blackBorderHeight, image.size.width + (whiteBorderWidth * 2) - (blackBorderWidth * 2), image.size.height + (whiteBorderHeight * 2) - (blackBorderHeight) * 2));

    [image drawInRect:CGRectMake(whiteBorderWidth, whiteBorderHeight, image.size.width, image.size.height)];

    UIGraphicsPopContext();
    UIImage *photoImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [self loadTextureWithImage:photoImage repeat:false];
}

@end

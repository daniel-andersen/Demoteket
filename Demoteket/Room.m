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

#import "Room.h"
#import "Globals.h"

@implementation Room

static int ROOM_OFFSET_X[] = {0, 0, 0, 0, 0};
static int ROOM_OFFSET_Z[] = {0, 0, 0, 0, 0};

- (id) init {
    if (self = [super init]) {
        isVisible = false;
    }
    return self;
}

- (void) initializeRoomNumber:(int)number {
    NSLog(@"Initializing room number %i", number);
    [self createRoomNumber:number];
    [self createGeometrics];
    isVisible = true;
}

- (void) trashRoom {
    NSLog(@"TODO!");
    isVisible = false;
}

- (void) createRoomNumber:(int)number {
    roomNumber = number;
    stripNumber = 0;
    for (int i = 0; i < ROOM_MAX_SIZE; i++) {
        for (int j = 0; j < ROOM_MAX_SIZE; j++) {
            tiles[i][j] = 'X';
        }
    }
    if (number == 0) {
        [self addStrip:@"+---+"];
        [self addStrip:@"d121|"];
        [self addStrip:@"+   |"];
        [self addStrip:@"|  1|"];
        [self addStrip:@"|2  |"];
        [self addStrip:@"|  2|"];
        [self addStrip:@"|1D |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"|   |"];
        [self addStrip:@"+---+"];
	}
}

- (void) addStrip:(NSString *)strip {
    for (int i = 0; i < [strip length]; i++) {
        tiles[stripNumber][i] = [strip characterAtIndex:i];
    }
    stripNumber++;
}

- (void) createGeometrics {
    photosCount = 0;

    for (int i = 0; i < PHOTOS_MAX_COUNT; i++) {
        photos[i] = NULL;
        photosLight[i] = NULL;
    }

    pillars = [[Quads alloc] init];
    [pillars beginWithTexture:[textures getWallTexture:0]];

    photosBorder = [[Quads alloc] init];
    [photosBorder beginWithColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)];

    walls = [[Quads alloc] init];
    [walls beginWithTexture:[textures getWallTexture:0]];
    
    for (int i = 0; i < ROOM_MAX_SIZE; i++) {
        for (int j = 0; j < ROOM_MAX_SIZE; j++) {
            if (tiles[i][j] == 'X' || tiles[i][j] == ' ') {
                continue;
            }
            float x1 = ROOM_OFFSET_X[roomNumber] + ((float) j * BLOCK_SIZE);
            float z1 = ROOM_OFFSET_Z[roomNumber] + ((float) i * BLOCK_SIZE);
            float x2 = x1 + BLOCK_SIZE;
            float z2 = z1 + BLOCK_SIZE;
            float centerX = x1 + (BLOCK_SIZE / 2);
            float centerZ = z1 + (BLOCK_SIZE / 2);
            if (tiles[i][j] == '-') {
                [walls addQuadVerticalX1:x1 y1:0.0f z1:centerZ x2:x2 y2:ROOM_HEIGHT z2:centerZ];
            }
            if (tiles[i][j] == '|') {
                [walls addQuadVerticalX1:centerX y1:0.0f z1:z1 x2:centerX y2:ROOM_HEIGHT z2:z2];
            }
            if (tiles[i][j] == '+') {
                int type = [self getCornerTypeX:j y:i];
                if ((type & (1 | 4)) == (1 | 4)) {
                    [walls addQuadVerticalX1:x1 y1:0.0f z1:centerZ x2:x2 y2:ROOM_HEIGHT z2:centerZ];
                } else if ((type & 1) == 1) {
                    [walls addQuadVerticalX1:x1 y1:0.0f z1:centerZ x2:centerX y2:ROOM_HEIGHT z2:centerZ];
                } else if ((type & 4) == 4) {
                    [walls addQuadVerticalX1:centerX y1:0.0f z1:centerZ x2:x2 y2:ROOM_HEIGHT z2:centerZ];
                }
                if ((type & (2 | 8)) == (2 | 8)) {
                    [walls addQuadVerticalX1:centerX y1:0.0f z1:z1 x2:centerX y2:ROOM_HEIGHT z2:z2];
                } else if ((type & 2) == 2) {
                    [walls addQuadVerticalX1:centerX y1:0.0f z1:z1 x2:centerX y2:ROOM_HEIGHT z2:centerZ];
                } else if ((type & 8) == 8) {
                    [walls addQuadVerticalX1:centerX y1:0.0f z1:centerZ x2:centerX y2:ROOM_HEIGHT z2:z2];
                }
            }
            if (tiles[i][j] == 'd') {
                // TODO! Door!
            }
            if (tiles[i][j] >= 'A' && tiles[i][j] <= 'Z') {
                float angle = 2.0f * 3.14f * (float) (((int) tiles[i][j] - (int) 'A') / (float) ((int) 'Z' - (int) 'A'));
                [self addPhotosPillarAtX:centerX z:centerZ angle:angle];
            }
            if (tiles[i][j] >= '1' && tiles[i][j] <= '9') {
                int photoIndex = (int) tiles[i][j] - (int) '1';
                int photoDirection = [self getPhotosDirectionX:j y:i];
                float dist = BLOCK_SIZE - 0.1f;
                float scaleHorz = BLOCK_SIZE;
                if (photoDirection == 0) {
                    [self addPhotosLightsQuads:photoIndex x1:centerX - dist y1:0.0f z1:z1 - scaleHorz x2:centerX - dist y2:ROOM_HEIGHT z2:z2 + scaleHorz];
                    [self addPhotosQuads:photoIndex dir:photoDirection x:centerX - dist y:ROOM_HEIGHT / 2 z:centerZ];
                }
                if (photoDirection == 1) {
                    [self addPhotosLightsQuads:photoIndex x1:centerX + dist y1:0.0f z1:z1 - scaleHorz x2:centerX + dist y2:ROOM_HEIGHT z2:z2 + scaleHorz];
                    [self addPhotosQuads:photoIndex dir:photoDirection x:centerX + dist y:ROOM_HEIGHT / 2 z:centerZ];
                }
                if (photoDirection == 2) {
                    [self addPhotosLightsQuads:photoIndex x1:x1 - scaleHorz y1:0.0f z1:centerZ - dist x2:x2 + scaleHorz y2:ROOM_HEIGHT z2:centerZ - dist];
                    [self addPhotosQuads:photoIndex dir:photoDirection x:centerX y:ROOM_HEIGHT / 2 z:centerZ - dist];
                }
                if (photoDirection == 3) {
                    [self addPhotosLightsQuads:photoIndex x1:x1 - scaleHorz y1:0.0f z1:centerZ + dist x2:x2 + scaleHorz y2:ROOM_HEIGHT z2:centerZ + dist];
                    [self addPhotosQuads:photoIndex dir:photoDirection x:centerX y:ROOM_HEIGHT / 2 z:centerZ + dist];
                }
            }
        }
    }
    [walls end];
    [photosBorder end];
    [pillars end];
    for (int i = 0; i < PHOTOS_MAX_COUNT; i++) {
        if (photos[i] != NULL) {
		    [photos[i] end];
		    [photosLight[i] end];
        }
    }
}

- (int) getCornerTypeX:(int)x y:(int)y {
    char x1 = x > 0 ? tiles[y][x - 1] : 'X';
    char y1 = y > 0 ? tiles[y - 1][x] : 'X';
    char x2 = x < ROOM_MAX_SIZE - 1 ? tiles[y][x + 1] : 'X';
    char y2 = y < ROOM_MAX_SIZE - 1 ? tiles[y + 1][x] : 'X';
    int type = 0;
    type += [self isCharWallBrick:x1] ? 1 : 0;
    type += [self isCharWallBrick:y1] ? 2 : 0;
    type += [self isCharWallBrick:x2] ? 4 : 0;
    type += [self isCharWallBrick:y2] ? 8 : 0;
    return type;
}

- (int) getDoorDirectionX:(int)x y:(int)y {
    return ![self isWallX:x - 1 y:y] || ![self isWallX:x + 1 y:y] ? 0 : 1;
}

- (int) getPhotosDirectionX:(int)x y:(int)y {
    if ([self isWallX:x - 1 y:y]) {
        return 0;
    }
    if ([self isWallX:x + 1 y:y]) {
        return 1;
    }
    if ([self isWallX:x y:y - 1]) {
        return 2;
    }
    return 3;
}

- (bool) isWallX:(int)x y:(int)y {
    return x >= 0 && y >= 0 && x < ROOM_MAX_SIZE && y < ROOM_MAX_SIZE && [self isCharWallBrick:tiles[y][x]];
}

- (bool) isCharWallBrick:(char)ch {
    return ch == '|' || ch == '-' || ch == '+';
}

- (void) addPhotosLightsQuads:(int)idx x1:(float)x1 y1:(float)y1 z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2 {
    if (photosLight[idx] == NULL) {
	    photosLight[idx] = [[Quads alloc] init];
	    [photosLight[idx] beginWithTexture:[textures getPhotosLightTexture:idx]];
        [photosLight[idx] setBlendFuncSrc:GL_SRC_ALPHA dst:GL_ONE];
    }
    [photosLight[idx] addQuadVerticalX1:x1 y1:y1 z1:z1 x2:x2 y2:y2 z2:z2];
}

- (void) addPhotosQuads:(int)idx dir:(int) dir x:(float)x y:(float)y z:(float)z {
    if (photos[idx] == NULL) {
	    photos[idx] = [[Quads alloc] init];
	    [photos[idx] beginWithTexture:[textures getPhotosTexture:idx]];
    }
    if (idx == 0) {
	    [self addPhotoQuads:idx dir:dir x:x y:y z:z width:0.3f height:0.6f horizontalOffset:0.0f verticalOffset:0.0f];
    }
    if (idx == 1) {
	    [self addPhotoQuads:idx dir:dir x:x y:y z:z width:0.3f height:0.6f horizontalOffset:-0.55f verticalOffset:0.0f];
	    [self addPhotoQuads:idx dir:dir x:x y:y z:z width:0.3f height:0.6f horizontalOffset: 0.55f verticalOffset:0.2f];
    }
}

- (void) addPhotoQuads:(int)idx dir:(int)dir x:(float)x y:(float)y z:(float)z width:(float)width height:(float)height horizontalOffset:(float)offsetHorz verticalOffset:(float)offsetVert {
    y += offsetVert;
    if (dir == 0) {
        z += offsetHorz;
	    [photos[idx] addQuadVerticalX1:x + PHOTO_DEPTH y1:y - height z1:z - width x2:x + PHOTO_DEPTH y2:y + height z2:z + width];
        [photosBorder addQuadVerticalX1:x y1:y - height z1:z - width x2:x + PHOTO_DEPTH y2:y + height z2:z - width];
        [photosBorder addQuadVerticalX1:x y1:y - height z1:z + width x2:x + PHOTO_DEPTH y2:y + height z2:z + width];
        [photosBorder addQuadHorizontalX1:x z1:z - width x2:x + PHOTO_DEPTH z2:z + width y:y - height];
        [photosBorder addQuadHorizontalX1:x z1:z - width x2:x + PHOTO_DEPTH z2:z + width y:y + height];
    }
    if (dir == 1) {
        z += offsetHorz;
	    [photos[idx] addQuadVerticalX1:x - PHOTO_DEPTH y1:y - height z1:z - width x2:x - PHOTO_DEPTH y2:y + height z2:z + width];
        [photosBorder addQuadVerticalX1:x y1:y - height z1:z - width x2:x - PHOTO_DEPTH y2:y + height z2:z - width];
        [photosBorder addQuadVerticalX1:x y1:y - height z1:z + width x2:x - PHOTO_DEPTH y2:y + height z2:z + width];
        [photosBorder addQuadHorizontalX1:x z1:z - width x2:x - PHOTO_DEPTH z2:z + width y:y - height];
        [photosBorder addQuadHorizontalX1:x z1:z - width x2:x - PHOTO_DEPTH z2:z + width y:y + height];
    }
    if (dir == 2) {
        x += offsetHorz;
	    [photos[idx] addQuadVerticalX1:x - width y1:y - height z1:z + PHOTO_DEPTH x2:x + width y2:y + height z2:z + PHOTO_DEPTH];
        [photosBorder addQuadVerticalX1:x - width y1:y - height z1:z x2:x - width y2:y + height z2:z + PHOTO_DEPTH];
        [photosBorder addQuadVerticalX1:x + width y1:y - height z1:z x2:x + width y2:y + height z2:z + PHOTO_DEPTH];
        [photosBorder addQuadHorizontalX1:x - width z1:z x2:x + width z2:z + PHOTO_DEPTH y:y - height];
        [photosBorder addQuadHorizontalX1:x - width z1:z x2:x + width z2:z + PHOTO_DEPTH y:y + height];
    }
    if (dir == 3) {
        x += offsetHorz;
	    [photos[idx] addQuadVerticalX1:x - width y1:y - height z1:z - PHOTO_DEPTH x2:x + width y2:y + height z2:z - PHOTO_DEPTH];
        [photosBorder addQuadVerticalX1:x - width y1:y - height z1:z x2:x - width y2:y + height z2:z - PHOTO_DEPTH];
        [photosBorder addQuadVerticalX1:x + width y1:y - height z1:z x2:x + width y2:y + height z2:z - PHOTO_DEPTH];
        [photosBorder addQuadHorizontalX1:x - width z1:z x2:x + width z2:z - PHOTO_DEPTH y:y - height];
        [photosBorder addQuadHorizontalX1:x - width z1:z x2:x + width z2:z - PHOTO_DEPTH y:y + height];
    }
}

- (void) addPhotosPillarAtX:(float)x z:(float)z angle:(float)angle {
    float x1 = x - cos(angle) * PILLAR_WIDTH;
    float z1 = z - sin(angle) * PILLAR_WIDTH;
    float x2 = x + cos(angle) * PILLAR_WIDTH;
    float z2 = z + sin(angle) * PILLAR_WIDTH;
    [pillars addQuadVerticalX1:x1 y1:0.0f z1:z1 x2:x2 y2:ROOM_HEIGHT z2:z2];
}

- (void) render {
    [walls render];
    [photosBorder render];
	[pillars render];
    for (int i = 0; i < PHOTOS_MAX_COUNT; i++) {
        if (photos[i] != NULL) {
            glDepthMask(false);
            glDepthFunc(GL_LEQUAL);
		    [photosLight[i] render];

            glDepthFunc(GL_LESS);
            glDepthMask(true);
		    [photos[i] render];
        }
    }
}

@end

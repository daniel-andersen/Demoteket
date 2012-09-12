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

#import "ViewController.h"
#import "Exhibition.h"
#import "Globals.h"

enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
};

@interface ViewController () {

@private

    Exhibition *exhibition;

    float frameSeconds;
    double startTime;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@end

@implementation ViewController

@synthesize context = _context;
@synthesize effect = _effect;

- (void) didBecomeInactive {
    [exhibition inactivate];
}

- (void) didBecomeActive {
    [exhibition reactivate];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    openglContext = self.context;
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    self.preferredFramesPerSecond = 60;
    frameSeconds = FRAME_RATE;
    
    [self setupGL];

    exhibition = [[Exhibition alloc] init];
	[exhibition createExhibition];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    startTime = CFAbsoluteTimeGetCurrent();
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
    textureLoader = [[GLKTextureLoader alloc] initWithSharegroup:self.context.sharegroup];
    
    [self loadShaders:@"FloorDistortion" index:0];
    
    glkEffectNormal = [[GLKBaseEffect alloc] init];
    glkEffectShader = [[GLKBaseEffect alloc] init];
    self.effect = glkEffectNormal;

    glEnable(GL_DEPTH_TEST);
    
    [self getScreenSize];
}

- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = nil;
    
    for (int i = 0; i < 2; i++) {
	    if (glslProgram[i]) {
    	    glDeleteProgram(glslProgram[i]);
        	glslProgram[i] = 0;
	    }
    }
}

- (void) getScreenSize {
    screenWidth = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
    screenHeight = [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale;

    screenWidthNoScale = [UIScreen mainScreen].bounds.size.width;
    screenHeightNoScale = [UIScreen mainScreen].bounds.size.height;
    
    aspectRatio = fabsf(screenWidth / screenHeight);
    
    screenSizeInv[0] = 1.0f / (float) screenWidth;
    screenSizeInv[1] = 1.0f / (float) screenHeight;

    refractionConstant = 0.005 * (480.0f / (float) screenHeight);

    NSLog(@"Screen size: %i, %i", (int) screenWidth, (int) screenHeight);
}

- (void) handleTapFrom:(UITapGestureRecognizer*)recognizer {
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    [exhibition tap:GLKVector2Make(touchLocation.x / screenHeightNoScale, touchLocation.y / screenWidthNoScale)];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update {
    sceneProjectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspectRatio, 0.1f, ROOM_MAX_SIZE * BLOCK_SIZE);

    orthoProjectionMatrix = GLKMatrix4MakeOrtho(0.0f, 1.0f, 0.0f, 1.0f, -1.0f, 1.0f);
    orthoModelViewMatrix = GLKMatrix4Identity;

    if (CFAbsoluteTimeGetCurrent() < startTime + START_DELAY) {
        [exhibition update];
    } else {
	    frameSeconds += self.timeSinceLastUpdate;
        if (frameSeconds / FRAME_RATE > 2.0f) {
            frameSeconds = FRAME_RATE * 2.0f;
        }
	    while (frameSeconds >= FRAME_RATE) {
		    [exhibition update];
        	frameSeconds -= FRAME_RATE;
        }
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [exhibition render];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders:(NSString*)filename index:(int)index {
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    glslProgram[index] = glCreateProgram();
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:filename ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:filename ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    glAttachShader(glslProgram[index], vertShader);
    glAttachShader(glslProgram[index], fragShader);
    
    glBindAttribLocation(glslProgram[index], ATTRIB_VERTEX, "position");
    glBindAttribLocation(glslProgram[index], GLKVertexAttribTexCoord0, "texcoord0");
    
    if (![self linkProgram:glslProgram[index]]) {
        NSLog(@"Failed to link program: %d", glslProgram[index]);
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (glslProgram) {
            glDeleteProgram(glslProgram[index]);
            glslProgram[index] = 0;
        }
        
        return NO;
    }
    
    uniformModelViewProjectionMatrix = glGetUniformLocation(glslProgram[index], "modelViewProjectionMatrix");
    uniformSampler1 = glGetUniformLocation(glslProgram[index], "texture0");
    uniformSampler2 = glGetUniformLocation(glslProgram[index], "texture1");
    uniformScreenSizeInv = glGetUniformLocation(glslProgram[index], "screenSizeInv");
    uniformOffscreenSizeInv = glGetUniformLocation(glslProgram[index], "offscreenSizeInv");
    uniformRefractionConstant = glGetUniformLocation(glslProgram[index], "refractionConstant");
    
    if (vertShader) {
        glDetachShader(glslProgram[index], vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(glslProgram[index], fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog {
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog {
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end

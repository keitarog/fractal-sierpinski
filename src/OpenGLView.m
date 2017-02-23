
#include <OpenGL/gl3.h>

#import <CoreMedia/CoreMedia.h>
#import "OpenGLView.h"

#include "shaders.h"


@implementation OpenGLView
{
    CVDisplayLinkRef displayLink;
}


- (void)prepareOpenGL
{
    // manual update/reshape
    // //[self setWantsBestResolutionOpenGLSurface:YES];
    
    // Enable VSync by default
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    // doPrepareInGLContext
    {
        NSOpenGLContext *context = [self openGLContext];
        CGLContextObj contextObj = [context CGLContextObj];
        CGLLockContext(contextObj);
        [context makeCurrentContext];
        [self doPrepareInGLContext];
        [NSOpenGLContext clearCurrentContext];
        CGLUnlockContext(contextObj);
    }
    
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void *)(self));
    
    // Set the display link for the current renderer
    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(displayLink);
}


// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime,
                                      CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(__bridge OpenGLView *)displayLinkContext getFrameForTime:now];
    return result;
}


- (CVReturn)getFrameForTime:(const CVTimeStamp *)now
{
    float deltaTime = 1.0 / (now->rateScalar * (double)now->videoTimeScale / (double)now->videoRefreshPeriod);
    NSOpenGLContext *context = [self openGLContext];
    CGLContextObj contextObj = [context CGLContextObj];
    CGLLockContext(contextObj);
    
    [context makeCurrentContext];
    
    [self doRenderInGLContext:deltaTime];
    
    [context flushBuffer];
    [NSOpenGLContext clearCurrentContext];
    
    CGLUnlockContext(contextObj);
    return kCVReturnSuccess;
}

- (void)doPrepareInGLContext
{
    assert(!"virtual");
}

- (void)doRenderInGLContext:(float)deltaTime
{
    assert(!"virtual");
}

- (void)dealloc
{
    // Release the display link
    
    // Stop the display link BEFORE releasing anything in the view
    // otherwise the display link thread may call into the view and crash
    // when it encounters something that has been released
    CVDisplayLinkStop(displayLink);
    
    CVDisplayLinkRelease(displayLink);
}


- (void)reshape
{
    const NSRect bounds = self.bounds;
    int width = (int)NSWidth(bounds);
    int height = (int)NSHeight(bounds);
    
    NSOpenGLContext *context = [self openGLContext];
    CGLContextObj contextObj = [context CGLContextObj];
    CGLLockContext(contextObj);
    [context makeCurrentContext];
    
    glViewport(0, 0, width, height);
    
    [self doRenderInGLContext:0];
    
    [context flushBuffer];
    [NSOpenGLContext clearCurrentContext];
    CGLUnlockContext(contextObj);
}


- (void)update
{
    NSOpenGLContext *context = [self openGLContext];
    CGLContextObj contextObj = [context CGLContextObj];
    CGLLockContext(contextObj);
    CGLUpdateContext(contextObj);
    CGLUnlockContext(contextObj);
}

//
//- (BOOL)isOpaque
//{
//    // should draw its entire rect (dont allow partial draw)
//    return YES;
//}

@end



void* GetDefaultCGLPixelFormatAttributes() {
    static CGLPixelFormatAttribute attrs[] = {
        kCGLPFAOpenGLProfile, (CGLPixelFormatAttribute)kCGLOGLPVersion_GL3_Core,
        kCGLPFAColorSize, (CGLPixelFormatAttribute)24,
        kCGLPFAAlphaSize, (CGLPixelFormatAttribute)8,
        kCGLPFADepthSize, (CGLPixelFormatAttribute)24, // GL_DEPTH24_STENCIL8
        kCGLPFAStencilSize, (CGLPixelFormatAttribute)8,
        kCGLPFAAccelerated,
        kCGLPFADoubleBuffer,
        kCGLPFASampleBuffers, (CGLPixelFormatAttribute)1,
        kCGLPFASamples, (CGLPixelFormatAttribute)4,
        kCGLPFAAllowOfflineRenderers, // supports multiple gpu??
        kCGLPFANoRecovery,
        // Specifying "NoRecovery" gives us a context that cannot fall back to the software renderer.  This makes the View-based context a compatible with the layer-backed context, enabling us to use the "shareContext" feature to share textures, display lists, and other OpenGL objects between the two.
        (CGLPixelFormatAttribute)0
    };
    
    return attrs;
}

static inline NSError *error_with_message(NSString *message) {
    id userInfo = @{
                    NSLocalizedDescriptionKey: message
                    };
    NSError *error = [NSError errorWithDomain:@"com.synergytec.kit.graphics" code:0 userInfo:userInfo];
    return error;
}


BOOL STGraphicsCreateProgram(NSString *vertSource, NSString *fragSource, NSUInteger *outProgram, NSError *__strong* outError) {
    
    // shader creation
    GLuint vertex_shader;
    GLuint fragment_shader;
    vertex_shader = glCreateShader(GL_VERTEX_SHADER);
    fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
    
    // to relinquish shader appropriately,
    // required to call this block before return
    dispatch_block_t finalize = ^(void) {
        glDeleteShader(vertex_shader);
        glDeleteShader(fragment_shader);
    };
    
    // vertex shader compilation
    {
        char const *source_cstring = vertSource.UTF8String;
        glShaderSource(vertex_shader, 1, &source_cstring, NULL);
        glCompileShader(vertex_shader);
        
        GLint result;
        GLint logLength;
        glGetShaderiv(vertex_shader, GL_COMPILE_STATUS, &result);
        glGetShaderiv(vertex_shader, GL_INFO_LOG_LENGTH, &logLength);
        
        if (result == GL_FALSE) {
            char *log_cstring = malloc(logLength);
            glGetShaderInfoLog(vertex_shader, logLength, NULL, log_cstring);
            
            id message = [NSString stringWithCString:log_cstring encoding:NSUTF8StringEncoding];
            free(log_cstring);
            
            *outError = error_with_message(message);
            finalize();
            return NO;
        }
    }
    
    // fragment shader compilation
    {
        char const *source_cstring = fragSource.UTF8String;
        glShaderSource(fragment_shader, 1, &source_cstring, NULL);
        glCompileShader(fragment_shader);
        
        GLint result;
        GLint logLength;
        glGetShaderiv(fragment_shader, GL_COMPILE_STATUS, &result);
        glGetShaderiv(fragment_shader, GL_INFO_LOG_LENGTH, &logLength);
        
        if (result == GL_FALSE) {
            char *log_cstring = malloc(logLength);
            glGetShaderInfoLog(fragment_shader, logLength, NULL, log_cstring);
            
            id message = [NSString stringWithCString:log_cstring encoding:NSUTF8StringEncoding];
            free(log_cstring);
            
            *outError = error_with_message(message);
            finalize();
            return NO;
        }
    }
    
    // program creation
    GLuint program = glCreateProgram();
    
    // linking
    {
        glAttachShader(program, vertex_shader);
        glAttachShader(program, fragment_shader);
        glLinkProgram(program);
        
        GLint result;
        GLint logLength;
        glGetProgramiv(program, GL_LINK_STATUS, &result);
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
        
        if (result == GL_FALSE) {
            char *log_cstring = malloc(logLength);
            glGetProgramInfoLog(program, logLength, NULL, log_cstring);
            
            id message = [NSString stringWithCString:log_cstring encoding:NSUTF8StringEncoding];
            free(log_cstring);
            
            *outError = error_with_message(message);
            
            finalize();
            glDeleteProgram(program);
            return NO;
        }
    }
    
    *outProgram = (NSUInteger)program;
    
    finalize();
    return YES;
}

BOOL STGraphicsCreateProgramDefault(NSUInteger *outProgram, NSError *__strong* outError) {
	return STGraphicsCreateProgram(kDefaultShaderVertex, kDefaultShaderFragment, outProgram, outError);
}



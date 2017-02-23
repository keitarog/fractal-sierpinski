
#import <Cocoa/Cocoa.h>

void *GetDefaultCGLPixelFormatAttributes();
BOOL STGraphicsCreateProgram(NSString *vertSource, NSString *fragSource, NSUInteger *outProgram, NSError *__strong* outError);
BOOL STGraphicsCreateProgramDefault(NSUInteger *outProgram, NSError *__strong* outError);
 
@interface OpenGLView: NSOpenGLView {
    
}

- (void)doPrepareInGLContext;
- (void)doRenderInGLContext:(float)deltaTime;

@end



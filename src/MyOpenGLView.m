
#include <OpenGL/gl3.h>

#import <Cocoa/Cocoa.h>
#import "MyOpenGLView.h"

#include "bridge.h"


@implementation MyOpenGLView {
	void *_context;
}	


- (void)dealloc {
	engine_destroy(_context);
	_context = NULL;
}

// do a process once for preparation
- (void)doPrepareInGLContext {
	if (_context != NULL) return;

	_context = engine_create();
	engine_prepare(_context);
}


// do a process every frame
- (void)doRenderInGLContext:(float)frameTime {
	engine_render(_context, frameTime);
}



@end


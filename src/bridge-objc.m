
#include "bridge.h"

#import "OpenGLView.h"

uint32_t CreateShaderProgram(void) {
	NSUInteger program = 0;
	NSError *err = nil;

	if (STGraphicsCreateProgramDefault(&program, &err)) {
		return (uint32_t)program;
	}
	else {
		NSLog(@"%@", err);
	}

	return 0;
}



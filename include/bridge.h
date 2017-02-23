
#ifndef __BRIDGE_H__
#define __BRIDGE_H__

#include <stdint.h>

// implemented at AppDelegate.m
int ApplicationMain(void);


// implemented at bridge-objc.m
uint32_t CreateShaderProgram(void);


// implemented at bridge-cpp.cpp
// graphic engine (c++)
void *engine_create(void);
void engine_destroy(void *);

void engine_prepare(void *);
void engine_render(void *, float);


#endif


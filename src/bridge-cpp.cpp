

#include "Engine.h"

extern "C" {
  #include "bridge.h"
}


void *engine_create(void) {
  Engine *ctx = new Engine();
  return ctx;
}

void engine_prepare(void *ctx) {
  Engine *engine = static_cast<Engine *>(ctx);
  if (engine == nullptr) return;
  engine->PrepareGL();
}

void engine_render(void *ctx, float frame_time) {
  Engine *engine = static_cast<Engine *>(ctx);
  if (engine == nullptr) return;
  engine->RenderGL(frame_time);
}

void engine_destroy(void *ctx) {
  Engine *engine = static_cast<Engine *>(ctx);
  delete engine;
}



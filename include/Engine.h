
#ifndef __ENGINE_H__
#define __ENGINE_H__


struct EngineState;

class Engine {
 private:
  EngineState *state_;

 public:
  Engine();
  ~Engine();

  void Init();
  void PrepareGL();
  void RenderGL(float frame_time);
};



#endif



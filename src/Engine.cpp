

#include <iostream>
#include <vector>
#include <memory>


#define GLM_FORCE_RADIANS

#include <glm/glm.hpp>
#include <glm/ext.hpp>

extern "C" {
  #include "bridge.h"
  #include <OpenGL/gl3.h>
}

#include "Engine.h"


struct Triangle {
  float radius;
  GLuint vertex_buffer;

  
  std::vector<float> data;
  std::vector<glm::vec3> vertices;

  Triangle(float r) {
    radius = r;

    long v = 3;
    float m = 2.0f * glm::pi<float>() / v;
    
    for (long i = 0; i < v; i++) {
      float x = cosf(m * i) * r;
      float y = sinf(m * i) * r;
      data.push_back(x);
      data.push_back(y);
      data.push_back(0);
    }
    
    for (int i = 0; i < 3; i++) {
      glm::vec3 v(data[i * 3 + 0], data[i * 3 + 1], data[i * 3 + 2]);
      vertices.push_back(v);
    }
  }
  
  void Transfer() {
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, data.size() * sizeof(float), data.data(), GL_STATIC_DRAW);
    
    vertex_buffer = vbo;
  }

  void Draw() {
    // draw a triangle
    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
    glVertexAttribPointer(
      0, // layout number - declared at vertex shader
      3, // [X,Y,Z]
      GL_FLOAT,
      GL_FALSE,
      0,
      (void*)0
    );
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(0);
  }

  const std::vector<glm::vec3> &GetVertices() {
    return vertices;
  }
};

struct EngineState {
  GLuint program;
  GLint uniform_color;
  GLint uniform_matrix;
  
  float timer = 0;
  
  std::unique_ptr<Triangle> triangle;
};

// ------------------

void draw_sierpinski(glm::mat4 local, glm::mat4 offset, EngineState *state, int limit, float scale) { 
  local = glm::scale(glm::vec3(1.0f / 2, 1.0f / 2, 1.0f)) * local;
  glUniformMatrix4fv(state->uniform_matrix, 1, GL_FALSE, glm::value_ptr(local * offset));

  state->triangle->Draw();
  
  if (limit == 0) return;
  for (const glm::vec3 &vertex: state->triangle->GetVertices()) {
    glm::vec3 v = vertex * -2.0f * scale;
    draw_sierpinski(local, glm::translate(v) * offset, state, limit-1, scale * 2.0f);
  }
}

// ------------------

Engine::Engine() : state_(new EngineState()) {
  
}

Engine::~Engine() {
  delete state_;
  state_ = nullptr; 
}

void Engine::Init() {

}

void Engine::PrepareGL() {
  GLuint VertexArrayID;
  glGenVertexArrays(1, &VertexArrayID);
  glBindVertexArray(VertexArrayID);
    float radius = 1.0;

  std::unique_ptr<Triangle> p(new Triangle(radius));

  // generate a vertex buffer
  p->Transfer();
  
  state_->triangle = std::move(p);
  
  GLuint program = static_cast<GLuint>(CreateShaderProgram());
  glUseProgram(program);
  
  state_->program = program;
  state_->uniform_color  = glGetUniformLocation(program, "fragmentColor");
  state_->uniform_matrix = glGetUniformLocation(program, "MVP");

}


void Engine::RenderGL(float frame_time) {
  
  float timer = state_->timer;
  
  long timer_n = lroundf(timer * 1.0f);

  // clear our canvas
  glClearColor(1, 1, 1, 1);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  // transforms
  float rotation_speed = 1.0f; 
  glm::vec3 axis(0.0f, 0.0f, 1.0f);
  glm::mat4 rotation = glm::rotate(timer * glm::pi<float>() * rotation_speed, axis);
  
  float translation_speed = 0.25f;
  glm::vec3 offset(0.0f, 0.5f, 0.0f);
  offset = glm::rotateZ(offset, timer * glm::pi<float>() * translation_speed);
  
  glm::mat4 trans = glm::rotate(glm::pi<float>() / 3.0f / 2.0f + glm::pi<float>(), glm::vec3(0.0f, 0.0f, 1.0f));

  glUniform4f(state_->uniform_color, 0, 0, 0, 1.0);
  glUniformMatrix4fv(state_->uniform_matrix, 1, GL_FALSE, glm::value_ptr(trans));
  state_->triangle->Draw();
   
  glUniform4f(state_->uniform_color, 1.0, 1.0, 1.0, 1.0);
  
  trans = glm::scale(glm::vec3(1, -1, 1)) * trans;
  draw_sierpinski(trans, glm::mat4(), state_, timer_n % 7, 1.0f);

  // calculate elapsed time 
  state_->timer += frame_time;
}






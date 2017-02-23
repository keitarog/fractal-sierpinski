
#ifndef __SHADERS_H__
#define __SHADERS_H__


// vertex shader
static NSString *kDefaultShaderVertex = 
@"#version 330 core "
"layout(location = 0) in vec3 vertexPosition_modelspace; "
"uniform mat4 MVP; "
"void main() { "
"   gl_Position = MVP * vec4(vertexPosition_modelspace, 1.0); "
"}";


// fragment shader
static NSString *kDefaultShaderFragment =
@"#version 330 core "
"out vec4 color;"
"uniform vec4 fragmentColor;"
"void main() {"
"    color = fragmentColor; "
"}";


#endif


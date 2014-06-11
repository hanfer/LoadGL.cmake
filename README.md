LoadGL.cmake
============

Dead simple cmake OpenGL function loading based on [gl3w](https://github.com/skaslev/gl3w)

# Introduction

LoadGL.cmake is a small cmake script which downloads the lastest OpenGL headers from the [registry](http://www.opengl.org/registry/) and turns them into gl3w.h and gl3w.c.  
These files can be either linked (statically or dynamically) or compiled into your application directly.

#Example

The usage on the cmake side of things is as easy as it could get.  
Just add the files in this repository (or use a [git submodule](http://git-scm.com/book/de/Git-Tools-Submodule)) into your module path and you are ready to go.

```cmake
cmake_minimum_required(VERSION 2.6)
project(MyAwesomeProject)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

set(LOADGL_COMPAT 1)
include(LoadGL.cmake)
include_directories(${LOADGL_DIR})

file(GLOB_RECURSE SOURCE *.cpp *.hpp)

add_executable(MyAwesomeProject ${SOURCE})
target_link_libraries(MyAwesomeProject LoadGL)
```

The C/C++ side behaves exactly as [gl3w](https://github.com/skaslev/gl3w) does.  
(from [gl3w](https://github.com/skaslev/gl3w) Readme)

```CPP
#include <stdio.h>
#include <GL/gl3w.h>
#include <GL/glut.h>

// ...

int main(int argc, char **argv)
{
        glutInit(&argc, argv);
        glutInitDisplayMode(GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE);
        glutInitWindowSize(width, height);
        glutCreateWindow("cookie");

        glutReshapeFunc(reshape);
        glutDisplayFunc(display);
        glutKeyboardFunc(keyboard);
        glutSpecialFunc(special);
        glutMouseFunc(mouse);
        glutMotionFunc(motion);

        if (gl3wInit()) {
                fprintf(stderr, "failed to initialize OpenGL\n");
                return -1;
        }
        if (!gl3wIsSupported(3, 2)) {
                fprintf(stderr, "OpenGL 3.2 not supported\n");
                return -1;
        }
        printf("OpenGL %s, GLSL %s\n", glGetString(GL_VERSION),
               glGetString(GL_SHADING_LANGUAGE_VERSION));

        // ...

        glutMainLoop();
        return 0;
}
```

# Config & Api

## LoadGL.cmake

LoadGL.cmakes behaivour is controlable by setting some cmake variables _befor_ calling `include(LoadGL.cmake)`.  
By default LoadGL will build a static library which can be linked as seen in the example above.

`LOADGL_DIR`

> The dir into wich gl3w.h and gl3w.c will be outputed into. 
> defaults to `"${PROJECT_BINARY_DIR}/LoadGL"`

`LOADGL_BUILD_LIB`

> sets if a library should be built. 
> defaults to `1`

`LOADGL_SHARED`

> sets which kind of library should be built. 
> defaults to `0`

`LOADGL_STATIC`

> sets which kind of library should be built.
> defaults to `1`

`LOADGL_COMPAT`

> decides if LoadGL should use the compatibility profile.
> defaults to `0`

## gl3w API

The gl3w API is quite simple.  
(from [gl3w](https://github.com/skaslev/gl3w) Readme)

`int gl3wInit(void)`

> Initializes the library. Should be called once after an OpenGL context has
> been created. Returns `0` when gl3w_ was initialized successfully,
> `-1` if there was an error.

`int gl3wIsSupported(int major, int minor)`

> Returns `1` when OpenGL core profile version *major.minor* is available,
> and `0` otherwise.

`void *gl3wGetProcAddress(const char *proc)`

> Returns the address of an OpenGL extension function. Generally, you won't
> need to use it since gl3w loads all the functions defined in the OpenGL
> core profile on initialization. It allows you to load OpenGL extensions
> outside of the core profile.

# License

gl3w is in the public domain.  
LoadGL.cmake is in the public domain.

# Credits

__Slavomir Kaslev <slavomir.kaslev@gmail.com>__  
> gl3w Initial implementation

__Kelvin McDowell__  
> gl3w Mac OS X support

__Sjors Gielen__  
> gl3w Mac OS X support

__Travis Gesslein__  
> gl3w Patches regarding glcorearb.h

__[Rommel160](github.com/Rommel160)__  
> gl3w Code contributions
    
__Benedikt Kleiner__  
> LoadGL.cmake Initial implementation
    
# Note

I removed the OS X support since i have no way to test and/or maintain it. 
If somebody has some expertise feel free to contact me and/or pull request.

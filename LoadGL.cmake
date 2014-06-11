message("") # newline
#------------------Config------------------------
if(NOT LOADGL_DIR)
	set(LOADGL_DIR "${PROJECT_BINARY_DIR}/LoadGL")
endif()

if(NOT ${LOADGL_BUILD_LIB})
	set(LOADGL_STATIC 0)
	set(LOADGL_SHARED 0)
endif()

if(NOT DEFINED LOADGL_SHARED AND NOT DEFINED LOADGL_STATIC)
	set(LOADGL_STATIC 1)
endif()

if(LOADGL_SHARED OR LOADGL_STATIC)
	set(LOADGL_BUILD_LIB 1)
endif()

if(LOADGL_COMPAT)
	set(LOADGL_GL_HEADER "glext.h")
else()
	set(LOADGL_GL_HEADER "glcorearb.h")
endif()

set(LOADGL_GL_URL "http://www.opengl.org/registry/api/GL/${LOADGL_GL_HEADER}")
set(LOADGL_PROCREGEX "^GLAPI.+APIENTRY ([^( ]+).+$")

if(LOADGL_DEBUG)
	message("LoadGL: LOADGL_DIR ${LOADGL_DIR}")
	message("LoadGL: LOADGL_PROCREGEX ${LOADGL_PROCREGEX}")
	message("LoadGL: LOADGL_COMPAT ${LOADGL_COMPAT}")
	message("LoadGL: LOADGL_GL_HEADER ${LOADGL_GL_HEADER}")
	message("LoadGL: LOADGL_GL_URL ${LOADGL_GL_URL}")
	message("LoadGL: LOADGL_BUILD_LIB ${LOADGL_BUILD_LIB}")
	message("LoadGL: LOADGL_SHARED ${LOADGL_SHARED}")
	message("LoadGL: LOADGL_STATIC ${LOADGL_STATIC}")
endif()

if(LOADGL_COMPAT)
	message("LoadGL: Using compatibility profile")
else()
	message("LoadGL: Using core profile")
endif()

if(${LOADGL_BUILD_LIB})
	if(${LOADGL_STATIC})
		message("LoadGL: Building static lib")
	elseif(${LOADGL_SHARED})
		message("LoadGL: Building shared lib")
	endif()
else()
	message("LoadGL: Building sources only")
endif()

#---------------Download header------------------
if(NOT EXISTS "${LOADGL_DIR}/GL/${LOADGL_GL_HEADER}")
	file(DOWNLOAD "${LOADGL_GL_URL}" "${LOADGL_DIR}/GL/${LOADGL_GL_HEADER}" STATUS status)
	list(GET status 0 error_code)
	list(GET status 1 error_string)
	
	if(error_code)
		message("LoadGL: Failed to download OpenGL header ${error_string}")
		file(REMOVE "${LOADGL_DIR}/GL/${LOADGL_GL_HEADER}")
	endif()
	
	message("LoadGL: OpenGL header downloaded to ${LOADGL_DIR}/GL/${LOADGL_GL_HEADER}")
endif()

file(STRINGS "${LOADGL_DIR}/GL/${LOADGL_GL_HEADER}" proc_lines REGEX "${LOADGL_PROCREGEX}")

#---------------Create strings------------------
set(PROCDECS "" CACHE INTERNAL "")
set(PROCDEFS "" CACHE INTERNAL "")
set(PROCLOAD "" CACHE INTERNAL "")

foreach(proc_line ${proc_lines})
	string(REGEX REPLACE "${LOADGL_PROCREGEX}" "\\1" procname ${proc_line})
	string(TOUPPER ${procname} upperProcname)
	
	if(LOADGL_DEBUG)
		message("LoadGL: Found function ${proc_line}")
		message("LoadGL: Found function ${procname}")
	endif()
	
	set(PROCDECS "${PROCDECS}extern PFN${upperProcname}PROC ${procname}; \n")
	set(PROCDEFS "${PROCDEFS}PFN${upperProcname}PROC ${procname} = NULL; \n")
	set(PROCLOAD "${PROCLOAD}\t${procname} = get_proc(\"${procname}\");  \n")
	
endforeach()

configure_file("${CMAKE_CURRENT_LIST_DIR}/gl3w.h.in" "${LOADGL_DIR}/GL/gl3w.h")
configure_file("${CMAKE_CURRENT_LIST_DIR}/gl3w.c.in" "${LOADGL_DIR}/GL/gl3w.c")

set(LOADGL_SOURCE "${LOADGL_DIR}/GL/gl3w.h" "${LOADGL_DIR}/GL/gl3w.c")

#---------------Build lib-----------------------
if(${LOADGL_BUILD_LIB})
	find_package(OpenGL REQUIRED)
	
	include_directories(${OPENGL_INCLUDE_DIR})
	
	if(${LOADGL_STATIC})
		add_library(LoadGL STATIC ${LOADGL_SOURCE})
	elseif(${LOADGL_SHARED})
		add_library(LoadGL SHARED ${LOADGL_SOURCE})
	endif()
	
	target_link_libraries(LoadGL ${OPENGL_LIBRARIES})
endif()
message("") # newline
	
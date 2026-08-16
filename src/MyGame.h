// MyGame.h : Include file for standard system include files,
// or project specific include files.

#pragma once

#include <iostream>

// TODO: Reference additional headers your program requires here.

#ifdef DEBUG_BUILD
#include <iostream>
#define DEBUG_LOG(x) std::cout << "[DEBUG] " << x << std::endl
#else
#define DEBUG_LOG(x)
#endif



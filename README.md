Custom C++ Game Project used to practice CMake and building executable projects.

CMake Minimum Version 3.26

How to setup:
- Run generate_vs_solution.bat
- Open MyGame.sln
- - Set MyGame as Startup Project
  - Run
 
Game will switch through game screens on booting, "gameplay" is a cube that can be controlled with directional arrows

Builds are located in builds/ directory located at project root.

CMake handles the following:
- cmake/Dependencies.cmake setups up 3rd party libraries
- cmake/Pack.cmake intended to created a zipped version of the built project (WIP, doesn't work yet)
- src/CMakeLists.txt pulls in custom source files and creates executable

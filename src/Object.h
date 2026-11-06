#pragma once
#include <string>
#include <iostream>

using namespace std;

class Object
{
public:
	Object();
	~Object();

	std::string GetTexturePath() { return texturePath; }
private:
	std::string texturePath;
};


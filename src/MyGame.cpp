// MyGame.cpp : Defines the entry point for the application.
//

#include "MyGame.h"
#include "raylib.h"
#include "whereami.h"
#include "Object.h"

using namespace std;

const int SCREEN_WIDTH = 800;
const int SCREEN_HEIGHT = 800;

int frameCounter = 0;
int xPos, yPos, xCentre, yCentre;
int speed = 5;

bool shouldClose = false;

std::string resources;

Texture2D logTexture;

enum GameScreen {
	LOGO = 0,
	TITLE,
	GAMEPLAY,
	ENDING,
};

GameScreen currentScreen = LOGO;

void UpdateFrame();
std::string GetResourcePath();

int main()
{
	InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "My Game");
	SetTargetFPS(60);
	currentScreen = LOGO;
	xCentre = SCREEN_WIDTH / 2;
	yCentre = SCREEN_WIDTH / 2;
	xPos = xCentre;
	yPos = yCentre;

	resources = GetResourcePath();

	std::string tex = resources + "textures/raylib_256x256.png";
	logTexture = LoadTexture(tex.c_str());

	Object newObject;

	// Main Game Loop
	while (!WindowShouldClose() && !shouldClose)
	{
		// Update
		UpdateFrame();
	}

	CloseWindow();
	return 0;
}

static void UpdateFrame()
{
	// Update current screen e.g. process inputs
	switch (currentScreen)
	{
	case LOGO:
		frameCounter++;
		if (frameCounter > 120)
		{
			currentScreen = TITLE;
			frameCounter = 0;
		}
		break;
	case TITLE:
		frameCounter++;
		if (frameCounter > 120)
		{
			currentScreen = GAMEPLAY;
			frameCounter = 0;
		}
		break;
	case GAMEPLAY:
		if (IsKeyDown(KEY_RIGHT))
			xPos += speed;
		if (IsKeyDown(KEY_LEFT))
			xPos -= speed;
		if (IsKeyDown(KEY_UP))
			yPos -= speed;
		if (IsKeyDown(KEY_DOWN))
			yPos += speed;
		if (IsKeyPressed(KEY_ENTER))
		{
			currentScreen = ENDING;
			frameCounter = 0;
		}
		break;
	case ENDING:
		frameCounter++;
		if (frameCounter > 120)
		{
			shouldClose = true;
			return;
		}
		break;
	default:
		break;
	}

	// Draw Screen
	BeginDrawing();

	ClearBackground(RAYWHITE);

	switch (currentScreen)
	{
	case LOGO:
		DrawTexture(logTexture, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, WHITE);
		//DrawRectangle(SCREEN_WIDTH / 2 - 128, SCREEN_HEIGHT / 2 - 128, 256, 256, BLACK);
		//DrawRectangle(SCREEN_WIDTH / 2 - 112, SCREEN_HEIGHT / 2 - 112, 224, 224, RAYWHITE);
		//DrawText("raylib", SCREEN_WIDTH / 2 - 44, SCREEN_WIDTH / 2 + 48, 50, BLACK);
		break;
	case TITLE:
		DrawText("IWheelBarrows Presents...", xCentre / 2 - 44, yCentre / 2, 30, BLACK);
		DrawText("Box Mover!", xCentre / 2 - 30, yCentre, 70, DARKGREEN);
		break;
	case GAMEPLAY:
		DrawRectangle(xPos, yPos, 20, 20, GREEN);
		break;
	case ENDING:
		DrawText("Thank You for Playing!", 190, 200, 20, BLACK);
		break;
	default:
		DrawText("Bad State Entered!", 190, 200, 20, BLACK);
		break;
	}

	EndDrawing();
}

std::string GetResourcePath()
{
	char* path = NULL;
	std::string resourcePath;
	int dirname_length;
	int length = wai_getExecutablePath(NULL, 0, NULL);
	if (length > 0)
	{
		path = (char*)malloc(length + 1);
		wai_getExecutablePath(path, length, &dirname_length);
		if (path)
		{
			path[dirname_length] = '\0';
			resourcePath = std::string(path) + "/resources/";
		}
		else
		{
			resourcePath = std::string(RESOURCE_PATH);
		}
		free(path);
	}
	else
	{
		resourcePath = std::string(RESOURCE_PATH);
	}
	return resourcePath;
}

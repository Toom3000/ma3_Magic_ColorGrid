# Magic_ColorGrid
This plugin creates a ColorGrid for the grandMA3

![Magic_ColorGrid_ScreenShot](/Magic_ColorGrid_ScreenShot.png)

## Features
* Discovery of all current groups prior to installation
  * Auto discovery of color capabilities (RGB_CMY,ColorWheel or None)
  * Groups with no color capabilities will be omitted by the installer
  * Groups to be included to the grid are fully user definable
* Support for color wheel fixtures
  * The color names from the standard gel are compared to the color wheel configuration and mapped as good as possible
  * Delay and Fadetime functionality is not applied for the color wheel fixtures
* Direct and manual mode for color picking
  * In manual mode the colors can be picked and will be applied by a trigger button
  * In direct mode the colors will be immediately applied if picked
* Delay Align buttons for each group
* Delaytime adjustment 
* Fadetime adjustment
* ColorFlip Feature to flip between the last and current colors

## Compatibility
* Tested on **grandMA3 Version 1.8.1.0**

## Installation
* Copy the files in lib_images/ to 
  * <YOUR_INSTALLATION_DRIVE>:\ProgramData\MALightingTechnology\gma3_library\media\images\
* Copy the Magic_ColorGrid folder in lib_plugins/ to 
  * <YOUR_INSTALLATION_DRIVE>:\ProgramData\MALightingTechnology\gma3_library\datapools\plugins
* Prepare your showfile
  * Patch fixtures
  * Arrange the fixtures using 3d or selectiongrid 
    * If this is not done in advance, the fade and delay functionality may not work properly
  * Create your fixture groups
* Now import the plugin
  * Start your grandMA3 software
  * Navigate to your plugin pool or create a new one on an empty View
  * Create a new plugin
  * Import the Magic_ColorGrid plugin
* Execute the plugin and enjoy the ride :)

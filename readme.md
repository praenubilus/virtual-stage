# Virtual Stage Spatial Audio Demo
Virtual Stage is a simple OSX spatial audio demo App. Through this app, you will have a first impression on what the spatial audio is. This app demonstrates how to use [OpenAL-Soft](openal soft github) for native OSX development instead of the stock OpenAL framework. The reason to use OpenAL-Soft is because the stock OpenAL lib from Apple is outdated and missing lots of state-of- art features, such as custom HRTF support. In this implementation, Kemar-HRTF has been used. You can always swap out with another HRTF profile which satisfying OpenAL-Soft format.
From tech perspective, this app is also a good demo for how to mix _C_, _C++_ and _Objective-C_ together in an Apple project.

## How to Run the App
1. Install the latest version of OpenAL-Soft. 1.17.2 or higher version.
  * To install OpenAL-Soft, homebrew is highly recommended. Following the instruction on: http://brew.sh to install homebrew.
  * 1.2 Install the openAL formula using the command below in console:
```bash
brew install openal-soft
```

2. Install latest version of XCode(7.0 or later version) from App Store.

3. Open the VirtualStage project file: "virtualStage.xcodeproj"

4. As long as the project has been loaded, click the Run Arrow on the top left of XCode. The project should start running.

If there's any problem for running this program, please contact yunhao@ufl.edu/praenubilus@gmail.com

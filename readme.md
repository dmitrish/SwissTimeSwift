World Clock with timezones is a mighty little app that adds fun to timekeeping. Ditch boring digital clock faces and instead use intricate mechanical watchfaces.
<p>This is a port of the Android version, work in progress: https://github.com/dmitrish/SwissTime
<p></p>
For the metal file:
Open your Xcode project
Select your project in the Project Navigator
Select the SwissTimeSwift target
Go to Build Phases tab
Find the Run Script phase that compiles the Metal shader (or create one if it doesn't exist)
Replace the script with this:

# Compile Metal shader
xcrun -sdk "${PLATFORM_NAME}" metal -c "${SRCROOT}/SwissTimeSwift/SwissTimeSwift/Effects/WaterShader.metal" -o "${DERIVED_FILE_DIR}/WaterShader.air"

# Create Metal library  
xcrun -sdk "${PLATFORM_NAME}" metallib "${DERIVED_FILE_DIR}/WaterShader.air" -o "${DERIVED_FILE_DIR}/default.metallib"

# Copy to app bundle
mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
cp "${DERIVED_FILE_DIR}/default.metallib" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/default.metallib"

echo "Metal library built and copied to: ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/default.metallib"
Make sure "Run script: Based on dependency analysis" is UNCHECKED
Add input file: $(SRCROOT)/SwissTimeSwift/SwissTimeSwift/Effects/WaterShader.metal
Add output file: $(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/default.metallib

<table style="width:100%; border-collapse:collapse;">
  <tr>
    <th style="width:33%">Time Screen</th>
    <th style="width:33%">Watch List Screen</th>
    <th style="width:33%">Watch Detail Screen</th>
  </tr>
  <tr>
    <td style="vertical-align:top; text-align:center; padding:10px;">
      <img src="https://raw.githubusercontent.com/dmitrish/SwissTimeSwift/main/docs/swisstimeswift-timescreen.gif" 
           style="height:500px; width:auto;"/>
    </td>
    <td style="vertical-align:top; text-align:center; padding:10px;">
      <img src="https://raw.githubusercontent.com/dmitrish/SwissTimeSwift/main/docs/watchlist.png" 
           style="height:500px; width:auto;"/>
    </td>
        <td style="vertical-align:top; text-align:center; padding:10px;">
      <img src="https://raw.githubusercontent.com/dmitrish/SwissTimeSwift/main/docs/iosdetailscreen.gif" 
           style="height:500px; width:auto;"/>
    </td>
  </tr>
</table>

<table style="width:100%">
  <tr>
    <th>Water Shader Effects</th>
    <th>Water Shader Effects</th>
    <th>Welcome Screen</th>
  </tr>
  <tr>
    <td style="width:33%"><img src="https://github.com/dmitrish/SwissTimeSwift/blob/main/docs/iosWaterShader.gif"/></td>
    <td style="width:33%"><img src="https://github.com/dmitrish/SwissTimeSwift/blob/main/docs/iosWaterShader2.gif"/></td>
    <td style="width:33%"><img src="https://github.com/dmitrish/SwissTimeSwift/blob/main/docs/siwsstimeswift-welcome.gif"/></td>
  </tr>
</table>

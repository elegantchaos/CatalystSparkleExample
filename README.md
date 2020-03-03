# Catalyst + SwiftUI + Sparkle = ?

Now that we can make Mac applications using Catalyst, the question arises of how to distribute updates if we're not in the App Store. Even if we are in the App Store, we might want to be able to distribute beta versions to testers.

The traditional approach would be to use Sparkle, but that doesn't work out of the box with a Catalyst app, because some of the API that Sparkle relies on is not available.

This project illustrates a way to get it working.

## The Basic Plan

Create a plugin which your Catalyst app loads.

Have the plugin link with Sparkle and talk to it.

Have the plugin call back to the main app to present the user interface for updates, and pass back user actions to Sparkle.

See the [CatalystSparkle project](https://github.com/elegantchaos/CatalystSparkle) for more details of the implementation. 


## How To Use This Project

This project is a proof of concept containing an example application.

The actual code for bridging Sparkle is contained in a sub-project - CatalystSparkle. 

The CatalystSparkle project supplies a framework (`SparkleBridge.bundle`) that you include in your application's `Resources/` folder, and a static library  (`libSparkleBridgeClient`) which you use in your host application.

To use this approach in your own application, you just need the `CatalystSparkle` project from the submodule. You don't need anything from this repository.

For the purposes of testing, this project also contains another target which runs as a test webserver. The code for this is lifted pretty much whole from Sparkle's own test application, and wrapped up as a plugin. 


## The Test Server

This example includes another plugin: TestServer.

What this does when its run is make a copy of the application, increase its bundle version to 2, re-sign it, and zips it up. It then serves this zip in an appcast, on `http://localhost:1337/appcast.xml`.

The main application is set up to look at this appcast for its updates. This allows us to test the Sparkle mechanism without needing external servers.

Most of the code for this plugin is taken verbatim from Sparkle's own Test Application, which uses the same approach.


## Sandboxing, Codesigning & Sparkle

This project is set up to sign the application with my keys. You will need to modify it to use yours instead.

For the purposes of this demo, I've turned sandboxing off. 

This is not because using Sparkle from a plugin doesn't work with it on. It's just because the TestServer plugin needs to use `xcrun` to re-sign its copy of the application, and that won't work in a sandbox. The original Sparkle test application uses an XPC service to get round this, but I wanted to avoid that complication here.   

In general these days you will probably want to turn sandboxing on. 

This means that you'll want to use the `2.x` branch of Sparkle (this project is linking to it via a submodule).

When you embed Sparkle and the various Sparkle XPC services in your app, you will also need to arrange to sign them properly; especially if you want to notarize the app.

Xcode is usually quite good now at managing the re-signing of embedded things for you. However, as mentioned above, the fact that the Sparkle-related things are built for a different architecture makes it hard to get Xcode to embed them properly, so I'm doing it in a script phase.

This script phase can also doubles up as a place to re-sign all the embedded executables.

I'm not doing it in this example, but here's a snippet of the sort of code you'll need:

```
# By default, use the configured code signing identity for the project/target
IDENTITY="${EXPANDED_CODE_SIGN_IDENTITY}"
if [ "$IDENTITY" == "" ]
then
    # If a code signing identity is not specified, use ad hoc signing
    IDENTITY="-"
fi


codesign --verbose --force --deep --options runtime --sign "$IDENTITY" "$BUILT_RESOURCES_DIR/AppKitBridge.bundle/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/Updater.app"
codesign --verbose --force --deep --options runtime --sign "$IDENTITY" "$BUILT_RESOURCES_DIR/AppKitBridge.bundle/Contents/Frameworks/Sparkle.framework/Versions/A"
codesign --verbose --force --deep --options runtime --sign "$IDENTITY" "$BUILT_RESOURCES_DIR/SparkleBridge.bundle"

for name in ${XPCS[@]}
do
    echo "Re-signing $name"
    codesign --verbose --force --deep --options runtime --sign "$IDENTITY" "$BUILT_XPCSERVICES_DIR/$name"
done
```

This script expects the various Sparkle products to be signed already, so you may also have to modify your copy of Sparkle slightly to sign everything with your keys. 

There are probably simpler/cleaner ways to handle all of this. One idea might be to have the script build Sparkle using `xcodebuild`, supplying overrides for the code signing settings. That way you can ensure they get built right first time, without having to modify Sparkle.

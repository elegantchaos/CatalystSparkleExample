# Catalyst + SwiftUI + Sparkle = ?

Now that we can make Mac applications using Catalyst, the question arises of how to distribute updates if we're not in the App Store. Even if we are in the App Store, we might want to be able to distribute beta versions to testers.

The traditional approach would be to use Sparkle, but that doesn't work out of the box with a Catalyst app, because some of the API that Sparkle relies on is not available.

This project illustrates a way to get it working.

## How To Use This Project

This project is a proof of concept. It contains three components: the bridging plugin, an example host application, and a third plugin which runs as a test webserver (lifted pretty much whole from Sparkle's own test application), allowing you to test the Sparkle mechanism locally. 

As things stand, you will probably need to copy bits of this project into your own projects in order to adopt the approach shown here. You'll need to copy/re-create the plugin target, and the parts of the application that load the plugin and implement the `SparkleDriver` protocol. 

Eventually I plan to make the plugin (and glue code) into a separate library that your app can just depend on. 

At that point I'll update this example application to depend on that library too.

## The Basic Plan

Create a plugin which your Catalyst app loads.

Have the plugin link with Sparkle and talk to it.

Have the plugin call back to the main app to present the user interface for updates, and pass back user actions to Sparkle.


## The Tricky Details

The basic mechanism for bridging the gap between Catalyst and AppKit is to load a plugin. There's [a great blog post](https://www.highcaffeinecontent.com/blog/20190607-Beyond-the-Checkbox-with-Catalyst-and-AppKit) explaining how this all works, so I won't go over that ground again.

In our case, the plugin links against AppKit and Sparkle, and embeds the Sparkle framework.

The Catalyst-based app embeds the plugin (in its `Resources/` folder). The various Sparkle-related keys go into the App's `Info.plist` file, as normal. Similarly, it is the app embeds various Sparkle XPC helpers (in its `XPCServices` folder). 

Because they are targetting different architectures, the app and Sparkle get built into different locations (`Debug-maccatalyst/` vs `Debug/`, for a `Debug` configuration). As a result, its cleaner to use a script phase to copy over the XPC bits. 

At runtime, the app loads the plugin and creates an instance of its primary class. This is the object that forms the bridge between the two worlds. The app then calls a method on this bridge, and passes over to it another object that it has implemented. Methods on this object get called when Sparkle needs to show some user interface. Some of these methods pass callback blocks to the app - it calls these when it needs to pass back user responses to Sparkle.  


## User Interface Issues 

You might hope that we could just use Sparkle's default user interface, and indeed this does work in principle. 

Unfortunately though, the default sheet that Sparkle shows when an update is found uses the `WebView` class. Loading a window with a `WebView` instance in it, from the AppKit side of the fence, seems to cause a hard crash. This is likely because two different versions of the `WebKit` framework exist - one that thinks its using UIKit, another that thinks its using AppKit, and somehow we're ending up talking to the wrong one.  

There may be a way to get round this, but there is another solution. Version 2.0 of Sparkle (which is aimed at apps that are sandboxed) has a clean mechanism for replacing the default user interface. 

So the alternative solution is to use this mechanism in the plugin, and to forward all user interface requests to the Catalyst application, which can show its own views to tell the user that there's an update, and pass back user responses to the plugin.

Clearly, having to make your own user interface for Sparkle is more work, especially given the amount of effort that has been put into localization of Sparkle already. However, it potentially has some advantages too - for example it allows you to use SwiftUI, or to do a funky update-status-in-the-titlebar implementation.

When it comes to opportunities for re-use, there's no reason in the long run why a UIKit or SwiftUI based Sparkle interface could not be developed and shared (either by the Sparkle project, or as a separate resource by someone else).

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

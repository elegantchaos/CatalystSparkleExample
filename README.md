# Catalyst + SwiftUI + Sparkle = ?

Now that we can make Mac applications using Catalyst, the question arises of how to distribute updates (if we're not in the App Store) and/or test versions (even if we are).

The traditional approach would be to use Sparkle, but that doesn't work out of the box with a Catalyst app, because some of the API that Sparkle relies on is not available.

This project illustrates a way to get it working.

## How To Use This Project

This project is a proof of concept. It contains three components: the bridging plugin, an example host application, and a third plugin which runs as a test webserver (lifted pretty much whole from Sparkle's own test application), allowing you to test the Sparkle mechanism locally. 

As things stand, you will probably need to copy bits of this project into your own projects in order to adopt the approach shown here. You'll need to copy/re-create the plugin target, and the parts of the application that load the plugin and implement the `SparkleDriver` protocol. 

Eventually I plan to make the plugin (and glue code) into a library that your app can just adopt. 

At that point I'll probably move the example application out of here and into its own separate repository. It will then use the plugin library just like any other app.

**Disclaimer**: *currently this project is working right up until the point where it tries to run the Sparkle installer. It downloads and update and decompresses it, but then falls over when trying to install. The code here is taken from another project (where it was first developed), and that project is working fine - so I'm confident that the approach taken here is valid. I've obviously just done something stupid whilst trying to generalise the Sparkle code for this example. I'll track down the problem eventually, but in the meantime I figured I might as well put this example up here, as it may be enough to help people work out what they need to do. If you fix the launcher error before I do, please let me know (and send me a pull request!).* 

## The Basic Plan

Create a plugin which your Catalyst app loads.

Have the plugin link with Sparkle and talk to it.

Have the plugin call back to the main app to present the user interface for updates, and pass back user actions to Sparkle.


## The Tricky Details

The basic mechanism for bridging the gap between Catalyst and AppKit is to load a plugin. There's [a great blog post](https://www.highcaffeinecontent.com/blog/20190607-Beyond-the-Checkbox-with-Catalyst-and-AppKit) explaining how this all works, so I won't go over that ground again.

In our case, the plugin links against AppKit and Sparkle, and embeds the Sparkle framework.

The Catalyst-based app embeds the plugin (in its `Resources/` folder). The various Sparkle-related keys go into the App's `Info.plist` file, as normal. Similarly, it is the app embeds various Sparkle XPC helpers (in its `XPCServices` folder). 

Because they are targetting different architectures, the app and Sparkle get built into different locations (`Debug-maccatalyst/` vs `Debug/`, for a `Debug` configuration). As a result, its cleaner to use a script phase to copy over the XPC bits. This script also doubles up as a place to re-sign all the embedded executables, which is essential if you want to notarize your app.

At runtime, the app loads the plugin and creates an instance of its primary class. This is the object that forms the bridge between the two worlds. The app then calls a method on this bridge, and passes over to it another object that it has implemented. Methods on this object get called when Sparkle needs to show some user interface. Some of these methods pass callback blocks to the app - it calls these when it needs to pass back user responses to Sparkle.  


## User Interface Issues 

You might hope that we could just use Sparkle's default user interface, and indeed this does work in principle. 

Unfortunately though, the default sheet that Sparkle shows when an update is found uses the `WebView` class. Loading a window with a `WebView` instance in it, from the AppKit side of the fence, seems to cause a hard crash. This is likely because two different versions of the `WebKit` framework exist - one that thinks its using UIKit, another that thinks its using AppKit, and somehow we're ending up talking to the wrong one.  

There may be a way to get round this, but there is another solution. Version 2.0 of Sparkle (which is aimed at apps that are sandboxed) has a mechanism for replacing the default user interface. 

So the alternative solution is to use this mechanism in the plugin, and to forward all user interface requests to the Catalyst application, which can show its own views to tell the user that there's an update, and pass back user responses to the plugin.

Clearly, having to make your own user interface for Sparkle is more work, especially given the amount of effort that has been put into localization of Sparkle already. However, it potentially has some advantages too - for example it allows you to use SwiftUI, or to do a funky update-status-in-the-titlebar implementation.

When it comes to opportunities for re-use, there's no reason in the long run why a UIKit or SwiftUI based Sparkle interface could not be developed and shared (either by the Sparkle project, or as a separate resource by someone else).


# Catalyst + SwiftUI + Sparkle = ?

Now that we can make Mac applications using Catalyst, the question arises of how to distribute updates (if we're not in the App Store) and/or test versions (even if we are).

The traditional approach would be to use Sparkle, but that doesn't work out of the box with a Catalyst app, because some of the API that Sparkle relies on is not available.

This project illustrates a way to get it working.

## The Basic Plan

Create a plugin which your Catalyst app loads.

Have the plugin link with Sparkle and talk to it.

Have the plugin call back to the main app to present the user interface for updates, and pass back user actions to Sparkle.

## The Tricky Details

The plugin links against AppKit and Sparkle, and embeds the Sparkle framework.

The app embeds the plugin (in its `Resources/` folder), and also embeds various Sparkle XPC helpers (in its `XPCServices` folder). 

Because they are targetting different architectures, the app and the plugin get built into different locations (`Debug-maccatalyst` vs `Debug`, for example). As a result, its cleaner to use a script phase to copy over the XPC bits. This script also doubles up as a place to re-sign all the embedded executables, which is essential if you want to notarize your app.

At runtime, the app loads the plugin and creates an instance of its primary class. This is the object that forms the bridge between the two worlds.

There's [a great blog post](https://www.highcaffeinecontent.com/blog/20190607-Beyond-the-Checkbox-with-Catalyst-and-AppKit) explaining how this all works, so I won't go over that ground again.

## Interface Issues 

You might hope that we could just use Sparkle's default user interface, and indeed this does work in principle. 

Unfortunately though, the default sheet that Sparkle shows when an update is found uses the `WebView` class. Loading a window with a `WebView` instance in it, from the AppKit side of the fence, seems to cause a hard crash. This is likely because two different versions of the `WebKit` framework exist - one that thinks its using UIKit, another that thinks its using AppKit, and somehow we're ending up talking to the wrong one.  

There may be a way to get round this, but there is another solution. Version 2.0 of Sparkle (which is aimed at apps that are sandboxed) has a mechanism for replacing the default user interface. 

So the alternative solution is to use this mechanism in the plugin, and to forward all user interface requests to the Catalyst application, which can show its own views to tell the user that there's an update, and pass back user responses to the plugin.

Clearly, having to make your own user interface for Sparkle is more work, especially given the amount of effort that has been put into localization of Sparkle already. However, it potentially has some advantages too - for example it allows you to use SwiftUI, or to do a funky update-status-in-the-titlebar implementation.

When it comes to opportunities for re-use, there's no reason in the long run why a UIKit or SwiftUI based Sparkle interface could not be developed and shared (either by the Sparkle project, or as a separate resource by someone else).

## About This Project

This project is a proof of concept. It contains three components: the bridging plugin, an example host application, and a third plugin which runs as a test webserver and allows you to test the Sparkle mechanism locally. 

As things stand, you will probably need to copy bits of this project into your own projects in order to adopt the approach shown here. 

Eventually though I plan to make the plugin (and glue code) into a library that your app can just adopt. At that point I'll probably move the example application into a separate repository, and make it a client of this one too.




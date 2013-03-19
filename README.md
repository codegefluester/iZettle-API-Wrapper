iZettle API Wrapper for iOS
===========
With [iZettle](http://www.izettle.com) you can easily accept card payments on the go by using your iPhone/iPod Touch or iPad.
They've even build a small "API" for 3rd party developers to incorporate the iZettle iOS App into their
own applications.

This class is a wrapper around the custom [URL scheme](http://developer.izettle.com) iZettle is offering and makes it easy to 
add iZettle Payments to your own app.

**This is not an official repository from iZettle!**

## Setup
Add all files from this repository to your Xcode project and add your custom URL scheme to the `Info.plist` of your app (see [Implementing Custom URL Schemes](http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphoneosprogrammingguide/AdvancedAppTricks/AdvancedAppTricks.html) if you don't know how to register one)

## Usage
First of all, open the header file of your app delegate and import the file `iZettle.h` at the top of the file.

Add the following code to your `application:didFinishLaunchingWithOptions:` method, to perform a basic setup
of the iZettle wrapper class.

```objc
[[iZettle instance] setApiKey:@"YOUR_API_KEY"];
[[iZettle instance] setSourceName:@"Demo App"];
[[iZettle instance] setSuccessCallbackUrl:@"zettledemo://zettle-success"];
[[iZettle instance] setFailureCallbackUrl:@"zettledemo://zettle-failure"];
```

You also have to implement the method `application:openURL:sourceApplication:annotation:` in your app delegate. It should look like the sample 
below. This is required because the iZettle App will call our custom URL scheme once the payment is complete or has been
cancelled by the user. The wrapper class will then check the URL to determine if the payment was successfull or not. 

```objc
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[iZettle instance] handleOpenURL:url];
}
```

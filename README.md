iZettle API Wrapper for iOS
===========
With [iZettle](http://www.izettle.com) you can easily accept card payments on the go by using your iPhone/iPod Touch or iPad.
They've even build a small "API" for 3rd party developers to incorporate the iZettle iOS App into their
own applications.

This class is a wrapper around the custom [URL scheme](http://developer.izettle.com) iZettle is offering and makes it easy to 
add iZettle Payments to your own app.

It has not been tested in real life yet. I was only able to test if the URL callbacks work. Once I tested thze code with a 
complete payment I can somehow guarantee you that it really works.

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

Now that we have setup everything, we'll request a payment through the iZettle App. Open the header file of your view controller
and import `iZettle.h` just like in the app delegate.

The wrapper uses the `NSNoticiationCenter` class to notify all observers that a payment is either successfull or failed. 
First of all we have to add our view controller as an observer for the two notifications the iZettle wrapper is using. 
A good place to do this is the `viewWillAppear:` method.

```objc
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentComplete:) name:kZettlePaymentSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentFailed:) name:kZettlePaymentFailedNotification object:nil];   
}
```

Addionally we will unsubscribe from the notifications in the `viewWillDissapear:` method as we no longer need to be notified
about payments in that case.

```objc
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kZettlePaymentSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kZettlePaymentFailedNotification object:nil];
}
```

No we need to implement the `paymentComplete:` and `paymentFailed:` method to handle the completion of the payment process.

```objc
- (void) paymentComplete:(NSNotification *)notification
{
    UIAlertView *paymentCompleteAlert = [[UIAlertView alloc] initWithTitle:@"Payment complete" message:@"The payment has been processed successfully by iZettle. Thank you!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
    [paymentCompleteAlert show];
}

- (void) paymentFailed:(NSNotification *)notification
{
    NSString *reason = @"The payment was cancelled.";
    if (notification.object != nil) {
        reason = [notification.object objectForKey:@"failureReason"];
    }
    
    UIAlertView *paymentFailedAlert = [[UIAlertView alloc] initWithTitle:@"Payment failed" message:[NSString stringWithFormat:@"The payment could not be processed. Reason: %@", reason] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
    [paymentFailedAlert show];
}
```

No that we're all set, we can request a payment. You can do this by simply calling `requestPaymentForItem:price:currency:image:` method of the iZettle wrapper.
The `image` parameter is optional. It can be used to display an image in the iZettle App (photo of the item being sold for example).

```objc
[[iZettle instance] requestPaymentForItem:@"Flowers" price:@"12.46" currency:@"EUR" image:nil];
```

After this method has been called, the iZettle App should open (otherwise an error will be displayed saying that the iZettle App is not installed)
and prompt the user to pay for the product. If the user hits cancel or completes the purchase, iZettle will call our custom
URL scheme to notify your app about the status of the payment.

## License
This code is licensed under my very own and special "Do whatever you want with it" license.

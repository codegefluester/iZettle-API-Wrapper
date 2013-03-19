//
//  iZettle.m
//  iZettle API Wrapper
//
//  Created by Björn Kaiser on 19.03.13.
//  Copyright (c) 2013 Björn Kaiser. All rights reserved.
//

#import "iZettle.h"
#import "NSData+Base64.h"

@interface iZettle ()
- (NSString *)addPercentEscapesToURLString:(NSString*)string;
@end

@implementation iZettle

@synthesize apiKey, successCallbackUrl, failureCallbackUrl, sourceName;

static iZettle *_sharedInstance = nil;

+ (iZettle*) instance
{
    if (_sharedInstance == nil) {
        _sharedInstance = [[iZettle alloc] init];
    }
    return _sharedInstance;
}

- (BOOL) handleOpenURL:(NSURL*)url
{
    if ([[url absoluteString] hasPrefix:self.successCallbackUrl]) {
        // Payment complete
        [[NSNotificationCenter defaultCenter] postNotificationName:kZettlePaymentSuccessNotification object:nil];
        return YES;
    } else if([[url absoluteString] hasPrefix:self.failureCallbackUrl]) {
        // Payment failed
        [[NSNotificationCenter defaultCenter] postNotificationName:kZettlePaymentFailedNotification object:nil];
        return YES;
    }
    
    return NO;
}

- (NSString *)addPercentEscapesToURLString:(NSString*)string
{
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes (NULL, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"=&", kCFStringEncodingUTF8);
}

- (void) requestPaymentForItem:(NSString*)itemName price:(NSString*)price currency:(NSString*)currency image:(NSData*)image
{
    NSMutableString *paymentUrlString = [NSMutableString stringWithFormat:@"izettle://x-callback-url/payment/1.0?x-source=%@&api-key=%@&price=%@&currency=%@&title=%@&x-success=%@&x-failure=%@", [self.sourceName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.apiKey, [price stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], currency, [itemName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self addPercentEscapesToURLString:self.successCallbackUrl], [self addPercentEscapesToURLString:self.failureCallbackUrl]];
    
    // Append image data (base64 encoded)
    if(image != nil) {
        [paymentUrlString appendFormat:@"&image=%@", [image base64Encoding]];
    }
    
    NSLog(@"Payment URL: %@", paymentUrlString);
    
    NSURL *paymentUrl = [NSURL URLWithString:paymentUrlString];
    
    if([[UIApplication sharedApplication] canOpenURL:paymentUrl]) {
        [[UIApplication sharedApplication] openURL:paymentUrl];
    } else {
        // iZettle App is not installed
        [[NSNotificationCenter defaultCenter] postNotificationName:kZettlePaymentFailedNotification object:[NSDictionary dictionaryWithObject:@"The iZettle App is not installed" forKey:@"failureReason"]];
    }
}

@end

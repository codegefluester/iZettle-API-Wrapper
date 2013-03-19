//
//  iZettle.h
//  iZettle API Wrapper
//
//  Created by Björn Kaiser on 19.03.13.
//  Copyright (c) 2013 Björn Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kZettlePaymentSuccessNotification @"ZettlePaymentSuccessNotification"
#define kZettlePaymentFailedNotification @"ZettlePaymentFailedNotification"

@interface iZettle : NSObject {
    NSString *apiKey;
    NSString *successCallbackUrl;
    NSString *failureCallbackUrl;
    NSString *sourceName;
}

@property (strong) NSString *apiKey;
@property (strong) NSString *successCallbackUrl;
@property (strong) NSString *failureCallbackUrl;
@property (strong) NSString *sourceName;

+ (iZettle*) instance;

- (void) setApiKey:(NSString*)apiKey;
- (void) setSuccessCallbackUrl:(NSString*)successCallback;
- (void) setFailureCallbackUrl:(NSString*)failureCallback;
- (void) setSourceName:(NSString*)source;

- (void) requestPaymentForItem:(NSString*)itemName price:(NSString*)price currency:(NSString*)currency image:(NSData*)image;
- (BOOL) handleOpenURL:(NSURL*)theUrl;

@end

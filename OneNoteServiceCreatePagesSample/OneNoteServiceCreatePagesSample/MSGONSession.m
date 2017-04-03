//*********************************************************
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the ""License"");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED ON AN  *AS IS* BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS
// OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT.
//
// See the Apache Version 2.0 License for specific language
// governing permissions and limitations under the License.
//*********************************************************

#import <ADAL/ADAL.h>
#import "MSGONSession.h"
#import "ONSCPSCreateExamples.h"
#import "ONSCPSExampleDelegate.h"
#import "MSGONConstants.h"

NSTimeInterval const Expires = 300;

// Add private extension members
@interface MSGONSession () {
    
    //Callback for app-defined behavior when state changes
    id<ONSCPSExampleDelegate> _delegate;
}


@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *authority;
@property (nonatomic, strong) NSDate *expiresDate;
@property (nonatomic, strong) NSString *refreshToken;

@property (nonatomic, strong) ADAuthenticationContext *context;

@end

@implementation MSGONSession

// Singleton session
+ (MSGONSession*)sharedSession {
    static MSGONSession *sharedSession;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSession = [[self alloc] init];
    });
    return sharedSession;
}

#pragma mark - init
- (id)init {
    if (self  = [super init]) {
        [self initWithAuthority:authority
                       clientId:clientId
                    redirectURI:redirectUri
                     resourceID:resourceId
                     completion:^(ADAuthenticationError *error) {
                         if(error){
                             // handle error
                         }
                     }];
    }
    return self;
}

- (void)initWithAuthority:(NSString *)authority
                 clientId:(NSString *)clientId
              redirectURI:(NSString *)redirectURI
               resourceID:(NSString *)resourceID
               completion:(void (^)(ADAuthenticationError *error))completion {
    ADAuthenticationError *error;
    _context = [ADAuthenticationContext authenticationContextWithAuthority:authority error:&error];
    
    if(error){
        // Log error
        completion(error);
    }
    else{
        completion(nil);
    }
}



// Get the delegate in use
- (id<ONSCPSExampleDelegate>)delegate {
    return _delegate;
}

// Update the delegate to use
- (void)setDelegate:(id<ONSCPSExampleDelegate>)newDelegate {
    _delegate = newDelegate;
    // Force a refresh on the new delegate with the current state
    [_delegate exampleAuthStateDidChange:self];
}

- (void)authenticate:(UIViewController *)controller {
    if (self.accessToken != nil) {
        [self clearCredentials];
        [_delegate exampleAuthStateDidChange:nil];
        // update view to say sign in
    }
    else {
        [self acquireAuthTokenCompletion:^(ADAuthenticationError *acquireTokenError) {
            if(acquireTokenError){
                // handle error
            }
        }];
    }
}


#pragma mark - acquire token
- (void)acquireAuthTokenCompletion:(void (^)(ADAuthenticationError *error))completion {
    [self acquireAuthTokenWithResource:resourceId
                              clientID:clientId
                           redirectURI: [NSURL URLWithString:redirectUri]
                            completion:^(ADAuthenticationError *error) {
                                completion(error);}];
}

- (void)acquireAuthTokenWithResource:(NSString *)resourceID
                            clientID:(NSString *)clientID
                         redirectURI:(NSURL*)redirectURI
                          completion:(void (^)(ADAuthenticationError *error))completion {
    [self.context acquireTokenWithResource:resourceID
                                  clientId:clientID
                               redirectUri:redirectURI
                           completionBlock:^(ADAuthenticationResult *result) {
                               if (result.status !=AD_SUCCEEDED){
                                   completion(result.error);
                               }
                               
                               else{
                                   self.expiresDate = result.tokenCacheItem.expiresOn;
                                   self.accessToken = result.accessToken;
                                   self.refreshToken = result.tokenCacheItem.refreshToken;
                                   self.userId = result.tokenCacheItem.userInformation.userId;
                                   completion(nil);
                               }
                           }];
}

#pragma mark - Refresh token
- (void) checkAndRefreshTokenWithCompletion:(void (^)(ADAuthenticationError *error))completion{
    if (self.refreshToken) {
        NSDate *nowWithBuffer = [NSDate dateWithTimeIntervalSinceNow:Expires];
        NSComparisonResult result = [self.expiresDate compare:nowWithBuffer];
        if (result == NSOrderedSame || result == NSOrderedAscending) {
            [self.context acquireTokenSilentWithResource:resourceId
                                                clientId:clientId
                                            redirectUri:[NSURL URLWithString:redirectUri]
                                          completionBlock:^(ADAuthenticationResult *result) {
                                         if(AD_SUCCEEDED == result.status){
                                             completion(nil);
                                         }
                                         else{
                                             completion(result.error);
                                         }
                                     }];
            return;
        }
    }
    else {
    completion(nil);
    }
}

#pragma mark - clear credentials
//Clears the ADAL token cache and the cookie cache.
- (void)clearCredentials {
    
    // Remove all the cookies from this application's sandbox. The authorization code is stored in the
    // cookies and ADAL will try to get to access tokens based on auth code in the cookie.
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStore.cookies) {
        [cookieStore deleteCookie:cookie];
    }
    
    [[ADKeychainTokenCache new] removeAllForClientId:clientId error:nil];
}



@end

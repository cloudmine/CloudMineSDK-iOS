//
//  CMUserCredentials.m
//  cloudmine-ios
//
//  Copyright (c) 2012 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import "CMUser.h"
#import "CMWebService.h"
#import "CMObjectSerialization.h"
#import "CMObjectDecoder.h"
#import "CMObjectEncoder.h"
#import "CMCardPayment.h"

#import "MARTNSObject.h"
#import "RTProperty.h"

@interface CMUser ()
+ (NSURL *)cacheLocation;
+ (NSMutableDictionary *)cachedUsers;
+ (CMUser *)userFromCacheWithIdentifier:(NSString *)objectId;
+ (void)cacheMultipleUsers:(NSArray *)users;
- (void)writeToCache;
@end


NSString * const CMSocialNetworkFacebook = @"facebook";
NSString * const CMSocialNetworkTwitter = @"twitter";
NSString * const CMSocialNetworkFoursquare = @"foursquare";
NSString * const CMSocialNetworkInstagram = @"instagram";
NSString * const CMSocialNetworkTumblr = @"tumblr";
NSString * const CMSocialNetworkDropbox = @"dropbox";
NSString * const CMSocialNetworkFitbit = @"fitbit";
NSString * const CMSocialNetworkGithub = @"github";
NSString * const CMSocialNetworkLinkedin = @"linkedin";
NSString * const CMSocialNetworkMeetup = @"meetup";
NSString * const CMSocialNetworkRunkeeper = @"runkeeper";
NSString * const CMSocialNetworkWhithings = @"whithings";
NSString * const CMSocialNetworkWordpress = @"wordpress";
NSString * const CMSocialNetworkYammer = @"yammer";
NSString * const CMSocialNetworkSingly = @"singly";

static CMWebService *webService;

@implementation CMUser

@synthesize userId = _userId; // Delete in Version 2.0
@synthesize email = _email;
@synthesize password;
@synthesize token;
@synthesize tokenExpiration;
@synthesize objectId;
@synthesize isDirty;
@synthesize services;
@synthesize username;

+ (NSString *)className {
    return NSStringFromClass([self class]);
}

#pragma mark - Constructors

+ (void)initialize {
    if (!webService) {
        @try {
            webService = [[CMWebService alloc] init];
        } @catch (NSException *e) {
            webService = nil;
        }
    }
}

- (id)init {
    return [self initWithEmail:nil andUsername:nil andPassword:nil];
}

- (id)initWithUsername:(NSString *)theUsername andPassword:(NSString *)thePassword {
    return [self initWithEmail:nil andUsername:theUsername andPassword:thePassword];
}

// Delete in Version 2.0
- (id)initWithUserId:(NSString *)theUserId andPassword:(NSString *)thePassword {
    return [self initWithEmail:theUserId andUsername:nil andPassword:thePassword];
}

- (id)initWithEmail:(NSString *)theEmail andPassword:(NSString *)thePassword {
    return [self initWithEmail:theEmail andUsername:nil andPassword:thePassword];
}

// Delete in Version 2.0
- (id)initWithUserId:(NSString *)theUserId andUsername:(NSString *)theUsername andPassword:(NSString *)thePassword {
    return [self initWithEmail:theUserId andUsername:theUsername andPassword:thePassword];
}

- (id)initWithEmail:(NSString *)theEmail andUsername:(NSString *)theUsername andPassword:(NSString *)thePassword {
    if (self = [super init]) {
        self.token = nil;
        self.email = theEmail;
        self.username = theUsername;
        self.password = thePassword;
        self.services = nil;
        objectId = @"";
        if (!webService) {
            webService = [[CMWebService alloc] init];
        }
        isDirty = NO;
        [self registerAllPropertiesForKVO];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        objectId = [coder decodeObjectForKey:CMInternalObjectIdKey];
        if (!objectId) {
            objectId = @"";
        }
        token = [coder decodeObjectForKey:@"token"];
        tokenExpiration = [coder decodeObjectForKey:@"tokenExpiration"];
        _userId = [coder decodeObjectForKey:@"userId"];
        _email = [coder decodeObjectForKey:@"email"];
        username = [coder decodeObjectForKey:@"username"];
        services = [coder decodeObjectForKey:@"services"];
        if (!webService) {
            webService = [[CMWebService alloc] init];
        }
        isDirty = NO;
        [self registerAllPropertiesForKVO];
    }
    return self;
}

- (void)dealloc {
    [self deregisterAllPropertiesForKVO];
}

#pragma mark - Dirty tracking

- (void)executeBlockForAllUserDefinedProperties:(void (^)(RTProperty *property))block {
    NSArray *properties = [[self class] rt_properties];
    NSArray *ignoredProperties = [CMUser rt_properties]; // none of these are user profile fields, so ignore them
    for (RTProperty *property in properties) {
        if (![ignoredProperties containsObject:property]) {
            block(property);
        }
    }
}

- (void)registerAllPropertiesForKVO {
    [self executeBlockForAllUserDefinedProperties:^(RTProperty *property) {
        [self addObserver:self forKeyPath:[property name] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }];
}

- (void)deregisterAllPropertiesForKVO {
    [self executeBlockForAllUserDefinedProperties:^(RTProperty *property) {
        [self removeObserver:self forKeyPath:[property name]];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.isCreatedRemotely) {
        // Only change the state to dirty if the object has been at least saved remotely once. Doesn't matter otherwise and
        // just confuses matters.
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (![oldValue isEqual:newValue]) {
            // Only apply the change if a change was actually made.
            #ifdef DEBUG
                NSLog(@"Detected change for property %@. Old value was \"%@\", new value is \"%@\"", keyPath, oldValue, newValue);
            #endif
            isDirty = YES;
        }
    }
}

#pragma mark - Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.objectId forKey:CMInternalObjectIdKey];
    [coder encodeObject:self.token forKey:@"token"];
    [coder encodeObject:self.tokenExpiration forKey:@"tokenExpiration"];
    if (self.email) {
        [coder encodeObject:self.email forKey:@"email"];
    }
    if (self.username) {
        [coder encodeObject:self.username forKey:@"username"];
    }

    [coder encodeObject:self.services forKey:@"services"];
}

#pragma mark - Comparison

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[CMUser class]]) {
        return NO;
    }

    if (_email) {
        return ([[object email] isEqualToString:_email] && [[object password] isEqualToString:password]);
    } else if (username) {
        return ([[object username] isEqualToString:username] && [[object password] isEqualToString:password]);
    } else {
        return ([[object token] isEqualToString:token]);
    }
}

#pragma mark - State operations and accessors

- (BOOL)isLoggedIn {
    return (self.token != nil && [self.tokenExpiration compare:[NSDate date]] == NSOrderedDescending /* if token comes after now */);
}

- (void)setToken:(NSString *)theToken {
    @synchronized(self) {
        token = theToken;

        // Once a token is set, clear the password for security reasons.
        self.password = nil;
    }
}

- (NSString *)token {
    @synchronized(self) {
        return token;
    }
}

- (void)copyValuesFromDictionaryIntoState:(NSDictionary *)dict {
    for (NSString *key in dict) {
        if (![CMInternalKeys containsObject:key]) {
            //
            // Fix for crashing when the Key and Property named are different
            //
            @try {
                id value = [dict objectForKey:key];
                if ([[NSNull null] isEqual:value]) {
                    value = nil;
                }
                [self setValue:value forKey:key];
            }
            @catch (NSException *e) {
                #ifdef DEBUG
                    NSLog(@"Failed to set value: %@ for key: %@", [dict objectForKey:key], key);
                #endif
            }
        }
    }
    isDirty = NO;
}

// Delete in Version 2.0
- (NSString *)userId {
    @synchronized(self) {
        return _email;
    }
}
// Delete in Version 2.0
- (void)setUserId:(NSString *)userId {
    @synchronized(self) {
        _email = userId;
    }
}

#pragma mark - Remote user account and session operations

- (BOOL)isCreatedRemotely {
    // objectId is set server side, so if it's empty it hasn't been sent over the wire yet.
    return (![self.objectId isEqualToString:@""]);
}

- (void)save:(CMUserOperationCallback)callback {
    [webService saveUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        [self copyValuesFromDictionaryIntoState:responseBody];
        if (callback) {
            callback(result, [NSArray array]);
        }
    }];
}

- (void)loginWithCallback:(CMUserOperationCallback)callback {
    [webService loginUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        NSArray *messages = [NSArray array];

        if (result == CMUserAccountLoginSucceeded) {            
            self.token = [responseBody objectForKey:@"session_token"];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setLenient:YES];
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"; // RFC 1123 format
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [df setLocale:usLocale];
            self.tokenExpiration = [df dateFromString:[responseBody objectForKey:@"expires"]];

            NSDictionary *userProfile = [responseBody objectForKey:@"profile"];
            objectId = [userProfile objectForKey:CMInternalObjectIdKey];
            
            self.services = [[responseBody objectForKey:@"profile"] objectForKey:@"__services__"];

            if (!self.isDirty) {
                // Only bring the changes from the server into the object state if there weren't local modifications.
                [self copyValuesFromDictionaryIntoState:userProfile];
            }
        }

        if (callback) {
            callback(result, messages);
        }
    }];
}

- (void)logoutWithCallback:(CMUserOperationCallback)callback {
    [webService logoutUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        NSArray *messages = [NSArray array];
        if (result == CMUserAccountLogoutSucceeded) {
            self.token = nil;
            self.tokenExpiration = nil;
        } else {
            messages = [responseBody allValues];
        }

        if (callback) {
            callback(result, messages);
        }
    }];
}

- (void)createAccountWithCallback:(CMUserOperationCallback)callback {
    [webService createAccountWithUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        NSArray *messages = [NSArray array];

        if (result != CMUserAccountCreateSucceeded) {
            messages = [responseBody objectForKey:@"errors"];
        } else {
            objectId = [responseBody objectForKey:CMInternalObjectIdKey];
            isDirty = NO;
        }

        if (callback) {
            callback(result, messages);
        }
    }];
}

- (void)createAccountAndLoginWithCallback:(CMUserOperationCallback)callback {
    [self createAccountWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
        if (resultCode == CMUserAccountCreateFailedDuplicateAccount || resultCode == CMUserAccountCreateSucceeded) {
            [self loginWithCallback:callback];
        } else {
            if (callback) {
                callback(resultCode, messages);
            }
        }
    }];
}

- (void)changePasswordTo:(NSString *)newPassword from:(NSString *)oldPassword callback:(CMUserOperationCallback)callback {
    [self changeUserCredentialsWithPassword:oldPassword newPassword:newPassword newUsername:nil newEmail:nil callback:callback];
}

// Delete in Version 2.0
- (void)changeUserIdTo:(NSString *)newUserId password:(NSString *)currentPassword callback:(CMUserOperationCallback)callback {
    [self changeUserCredentialsWithPassword:currentPassword newPassword:nil newUsername:nil newEmail:newUserId callback:callback];
}

- (void)changeEmailTo:(NSString *)newEmail password:(NSString *)currentPassword callback:(CMUserOperationCallback)callback {
    [self changeUserCredentialsWithPassword:currentPassword newPassword:nil newUsername:nil newEmail:newEmail callback:callback];
}

- (void)changeUsernameTo:(NSString *)newUsername password:(NSString *)currentPassword callback:(CMUserOperationCallback)callback {
    [self changeUserCredentialsWithPassword:currentPassword newPassword:nil newUsername:newUsername newEmail:nil callback:callback];
}

// Delete in Version 2.0
- (void)changeUserCredentialsWithPassword:(NSString *)currentPassword
                              newPassword:(NSString *)newPassword
                              newUsername:(NSString *)newUsername
                                newUserId:(NSString *)newUserId
                                 callback:(CMUserOperationCallback)callback {
    [self changeUserCredentialsWithPassword:currentPassword newPassword:newPassword newUsername:newUsername newEmail:newUserId callback:callback];
}

- (void)changeUserCredentialsWithPassword:(NSString *)currentPassword
                              newPassword:(NSString *)newPassword
                              newUsername:(NSString *)newUsername
                                newEmail:(NSString *)newEmail
                                 callback:(CMUserOperationCallback)callback {
    
    [webService changeCredentialsForUser:self
                                password:currentPassword
                             newPassword:newPassword
                             newUsername:newUsername
                               newEmail:newEmail
                                callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
                                    
                                    if (result == CMUserAccountCredentialChangeSucceeded ||
                                        result == CMUserAccountPasswordChangeSucceeded ||
                                        result == CMUserAccountUsernameChangeSucceeded ||
                                        result == CMUserAccountEmailChangeSucceeded) {
                                        
                                        self.password = currentPassword;
                                        
                                        if (newPassword) {
                                            self.password = newPassword;
                                        }
                                        if (newUsername) {
                                            self.username = newUsername;
                                        }
                                        if (newEmail) {
                                            self.email = newEmail;
                                        }
                                        
                                        // Only login if it was successful, otherwise it won't expire the session token.
                                        [self loginWithCallback:^(CMUserAccountResult resultCode, NSArray *messages) {
                                            callback(result, [NSArray array]);
                                        }];
                                        
                                    } else {
                                        callback(result, [NSArray array]);
                                    }
                                }];
    
}

- (void)resetForgottenPasswordWithCallback:(CMUserOperationCallback)callback  {
    [webService resetForgottenPasswordForUser:self callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        if (callback) {
            callback(result, [NSArray array]);
        }
    }];
}

#pragma mark - Payment Methods

- (void)addPaymentMethod:(CMCardPayment *)paymentMethod callback:(CMPaymentServiceCallback)callback;
{
        [self addPaymentMethods:@[paymentMethod] callback:callback];
    }

- (void)addPaymentMethods:(NSArray *)paymentMethods callback:(CMPaymentServiceCallback)callback;
{
    //serialize payment method
    NSString *urlString = @"payments/account/methods/card";
    
    NSURL *url = [webService constructAppURLWithString:urlString andDescriptors:nil];
    NSMutableURLRequest *request = [webService constructHTTPRequestWithVerb:@"POST" URL:url binaryData:NO user:self];
    
    NSMutableArray *payments = [NSMutableArray array];
    NSDictionary *encoded = [CMObjectEncoder encodeObjects:paymentMethods];
    [encoded enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [payments addObject:obj];
    }];
    
    NSDictionary *finalEncoding = @{@"payments": payments};
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:finalEncoding options:0 error:&error];
    if (error) {
        NSLog(@"There was an error serializing the CMPayment Object! %@", error);
    }
    
    [request setHTTPBody:data];
    
    [webService executeGenericRequest:request successHandler:^(id parsedBody, NSUInteger httpCode, NSDictionary *headers) {
        NSLog(@"Result %@", parsedBody);
        CMPaymentResponse *response = [[CMPaymentResponse alloc] initWithResponseBody:parsedBody httpCode:httpCode headers:headers errors:nil];
        if (callback) callback(response);
    } errorHandler:^(id responseBody, NSUInteger httpCode, NSDictionary *headers, NSError *error, NSDictionary *errorInfo) {
        CMPaymentResponse *response = [[CMPaymentResponse alloc] initWithResponseBody:responseBody httpCode:httpCode headers:headers errors:errorInfo];
        if (callback) callback(response);
    }];
}

- (void)removePaymentMethodAtIndex:(NSUInteger)index callback:(CMPaymentServiceCallback)callback;
{
    NSString *urlString = [NSString stringWithFormat:@"payments/account/methods/card/%d", index];
    
    NSURL *url = [webService constructAppURLWithString:urlString andDescriptors:nil];
    NSMutableURLRequest *request = [webService constructHTTPRequestWithVerb:@"DELETE" URL:url binaryData:NO user:self];
    
    [webService executeGenericRequest:request successHandler:^(id parsedBody, NSUInteger httpCode, NSDictionary *headers) {
        NSLog(@"Result %@", parsedBody);
        CMPaymentResponse *response = [[CMPaymentResponse alloc] initWithResponseBody:parsedBody httpCode:httpCode headers:headers errors:nil];
        if (callback) callback(response);
    } errorHandler:^(id responseBody, NSUInteger httpCode, NSDictionary *headers, NSError *error, NSDictionary *errorInfo) {
        CMPaymentResponse *response = [[CMPaymentResponse alloc] initWithResponseBody:responseBody httpCode:httpCode headers:headers errors:errorInfo];
        if (callback) callback(response);
    }];
}

- (void)paymentMethods:(CMPaymentServiceCallback)callback;
{
    NSString *urlString = @"payments/account/methods";
    
    NSURL *url = [webService constructAppURLWithString:urlString andDescriptors:nil];
    NSMutableURLRequest *request = [webService constructHTTPRequestWithVerb:@"GET" URL:url binaryData:NO user:self];
    
    [webService executeGenericRequest:request successHandler:^(id parsedBody, NSUInteger httpCode, NSDictionary *headers) {
        
        NSLog(@"Result %@", parsedBody);
        NSMutableArray *finishedObjects = [NSMutableArray array];
        for (NSDictionary *dictionary in parsedBody[@"card"]) {
            CMCardPayment *newPayment = [[CMCardPayment alloc] init];
            newPayment.expirationDate = dictionary[@"expirationDate"];
            newPayment.last4Digits = dictionary[@"last4Digits"];
            newPayment.nameOnCard = dictionary[@"nameOnCard"];
            newPayment.token = dictionary[@"token"];
            newPayment.type = dictionary[@"type"];
            [finishedObjects addObject:newPayment];
        }
        
        CMPaymentResponse *response = [[CMPaymentResponse alloc] initWithResponseBody:finishedObjects httpCode:httpCode headers:headers errors:nil];
        if (callback) callback(response);
    } errorHandler:^(id responseBody, NSUInteger httpCode, NSDictionary *headers, NSError *error, NSDictionary *errorInfo) {
        CMPaymentResponse *response = [[CMPaymentResponse alloc] initWithResponseBody:responseBody httpCode:httpCode headers:headers errors:errorInfo];
        if (callback) callback(response);
    }];
}




#pragma mark - Social login with Singly

// This code is very similar to login above, perhaps we can refactor.
- (void)loginWithSocialNetwork:(NSString *)service viewController:(UIViewController *)viewController params:(NSDictionary *)params callback:(CMUserOperationCallback)callback {
    
    [webService loginWithSocial:self withService:service viewController:viewController params:params callback:^(CMUserAccountResult result, NSDictionary *responseBody) {
        NSArray *messages = [NSArray array];
        
        if (result == CMUserAccountLoginSucceeded) {
            self.token = [responseBody objectForKey:@"session_token"];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setLenient:YES];
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"; // RFC 1123 format
            self.tokenExpiration = [df dateFromString:[responseBody objectForKey:@"expires"]];
            NSDictionary *userProfile = [responseBody objectForKey:@"profile"];
            objectId = [userProfile objectForKey:CMInternalObjectIdKey];
            
            self.services = [[responseBody objectForKey:@"profile"] objectForKey:@"__services__"];

            if (!self.isDirty) {
                // Only bring the changes from the server into the object state if there weren't local modifications.
                [self copyValuesFromDictionaryIntoState:userProfile];
            }
        }
        
        if (callback) {
            callback(result, messages);
        }
    }];
}

#pragma mark - Discovering other users

+ (void)allUsersWithCallback:(CMUserFetchCallback)callback {
    NSParameterAssert(callback);
    [webService getAllUsersWithCallback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
        NSArray *users = [CMObjectDecoder decodeObjects:results];
        [self cacheMultipleUsers:users];
        callback(users, errors);
    }];
}

+ (void)searchUsers:(NSString *)query callback:(CMUserFetchCallback)callback {
    NSParameterAssert(callback);
    [webService searchUsers:query callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
        NSArray *users = [CMObjectDecoder decodeObjects:results];
        [self cacheMultipleUsers:users];
        callback(users, errors);
    }];
}

+ (void)userWithIdentifier:(NSString *)identifier callback:(CMUserFetchCallback)callback {
    NSParameterAssert(callback);

    CMUser *cachedUser = [self userFromCacheWithIdentifier:identifier];
    if (cachedUser) {
        callback(@[cachedUser], [NSDictionary dictionary]);
    } else {
        [webService getUserProfileWithIdentifier:identifier callback:^(NSDictionary *results, NSDictionary *errors, NSNumber *count) {
            if (errors.count > 0) {
                callback([NSArray array], errors);
            } else {
                NSArray *users = [CMObjectDecoder decodeObjects:results];
                [self cacheMultipleUsers:users];
                callback(users, errors);
            }
        }];
    }
}

#pragma mark - Caching

+ (NSURL *)cacheLocation {
    static NSURL *_cacheLocation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cacheLocation = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        _cacheLocation = [_cacheLocation URLByAppendingPathComponent:@"cmusers.plist"];
    });

    return _cacheLocation;
}

+ (NSMutableDictionary *)cachedUsers {
    NSURL *cacheLocation = [self cacheLocation];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[cacheLocation relativePath]]) {
        // Since the file doesn't already exist, create it with an empty dictionary.
        [[NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionary]] writeToURL:cacheLocation atomically:YES];
        return [NSMutableDictionary dictionary];
    }
    return [[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfURL:cacheLocation]] mutableCopy];
}

- (void)writeToCache {
    [CMUser cacheMultipleUsers:@[self]];
}

+ (void)cacheMultipleUsers:(NSArray *)users {
    NSMutableDictionary *cachedUsers = [self cachedUsers];
    [users enumerateObjectsUsingBlock:^(CMUser *obj, NSUInteger idx, BOOL *stop) {
        [cachedUsers setObject:obj forKey:obj.objectId];
    }];

    [[NSKeyedArchiver archivedDataWithRootObject:cachedUsers] writeToURL:[self cacheLocation] atomically:YES];
}

+ (CMUser *)userFromCacheWithIdentifier:(NSString *)objectId {
    return [[self cachedUsers] objectForKey:objectId];
}

#pragma mark - Private stuff

- (void)setWebService:(CMWebService *)newWebService {
    webService = newWebService;
}

- (CMWebService *)webService {
    return webService;
}

@end

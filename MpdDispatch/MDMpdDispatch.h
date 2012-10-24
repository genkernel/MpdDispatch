//
//  MpdDispath.h
//  MpdDispath
//
//  Created by kernel on 5/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDDirectory.h"
#import "MDPlayer.h"
#import "MDSearch.h"

@interface MDMpdDispatch : NSObject
@property (copy, nonatomic) void(^didConnect)();
@property (copy, nonatomic) void (^didAuthenticate)();

@property (strong, nonatomic, readonly) MDPlayer *player;
@property (strong, nonatomic, readonly) MDDirectory *directory;
@property (strong, nonatomic, readonly) MDSearch *search;

- (BOOL)connect:(NSNetService *)service;
- (BOOL)connect:(NSString *)hostName port:(NSInteger)port;
- (BOOL)authenticate:(NSString *)password;
- (void)disconnect;

@property (assign, nonatomic, readonly) NSUInteger lastErrorCode, lastOperationHasFailed;
- (BOOL)isDisconnected;
- (NSString *)version;

- (NSArray *)allowedCommands;
- (NSArray *)disallowedCommands;
- (NSArray *)supportedSchemes;
- (NSArray *)tagTypes;
@end

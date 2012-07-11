//
//  MpdDispath.h
//  MpdDispath
//
//  Created by kernel on 5/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Directory.h"
#import "Player.h"
#import "Search.h"

@interface MpdDispatch : NSObject
@property (copy, nonatomic) void(^didConnect)();
@property (copy, nonatomic) void (^didAuthenticate)();

@property (strong, nonatomic, readonly) Player *player;
@property (strong, nonatomic, readonly) Directory *directory;
@property (strong, nonatomic, readonly) Search *search;

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

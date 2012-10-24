//
//  MpdDispath.m
//  MpdDispath
//
//  Created by kernel on 5/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDMpdDispatch.h"
#import <netinet/in.h>
#import "MDHelper+Internals.h"

static unsigned connection_timeout = 5 * 1000;

typedef enum {
	MpdSupportedAllowedCommands,
	MpdSupportedDisallowedCommands,
	MpdSupportedUrlSchemes,
	MpdSupportedTagTypes,
	
	MpdSupportedActionsCount
} MpdSupportedActions;
typedef bool (*ActionMethod)(struct mpd_connection *);

@interface MDMpdDispatch()
@property (strong, nonatomic) NSArray *helpers;
@property (strong, nonatomic, readwrite) MDPlayer *player;
@property (strong, nonatomic, readwrite) MDDirectory *directory;
@property (strong, nonatomic, readwrite) MDSearch *search;

- (NSArray *)performEnumaration:(ActionMethod)action withKey:(const char *)key cachingRequest:(dispatch_once_t *)request container:(NSArray **)container;
- (void)freeConnection;
@end

@implementation MDMpdDispatch {
	struct mpd_connection *conn;
	
	const char *actionKeys[MpdSupportedActionsCount];
	ActionMethod actions[MpdSupportedActionsCount];
	dispatch_once_t cachedRequests[MpdSupportedActionsCount];
	NSArray *containers[MpdSupportedActionsCount];
}
@synthesize didConnect, didAuthenticate;
@synthesize helpers, player, directory, search;
@dynamic lastErrorCode, lastOperationHasFailed;

- (id)init {
	self = [super init];
	if (self) {
		actionKeys[MpdSupportedAllowedCommands] = "command";
		actions[MpdSupportedAllowedCommands] = &mpd_send_allowed_commands;
		
		actionKeys[MpdSupportedAllowedCommands] = "command";
		actions[MpdSupportedDisallowedCommands] = &mpd_send_disallowed_commands;
		
		actionKeys[MpdSupportedAllowedCommands] = "handler";
		actions[MpdSupportedUrlSchemes] = &mpd_send_list_url_schemes;
		
		actionKeys[MpdSupportedAllowedCommands] = "tagtype";
		actions[MpdSupportedTagTypes] = &mpd_send_list_tag_types;
		
		self.player = [MDPlayer new];
		self.directory = [MDDirectory new];
		self.search = [MDSearch new];
		self.helpers = [NSArray arrayWithObjects:self.player, self.directory, self.search, nil];
	}
	return self;
}

- (void)dealloc {
	[self disconnect];
}

- (BOOL)connect:(NSNetService *)service {
	return [self connect:service.hostName port:service.port];
}

- (BOOL)connect:(NSString *)hostName port:(NSInteger)port {
	[self disconnect];
	
	NSLog(@"Connecting to: %@:%d", hostName, port);
	
	conn = mpd_connection_new([hostName UTF8String], port, connection_timeout);
	 
	BOOL connected = MPD_ERROR_SUCCESS==mpd_connection_get_error(conn);
	if (connected) {
		NSLog(@"Connected!");
		
		for (MDHelper *helper in self.helpers) {
			helper.conn = conn;
			[helper didConnect];
		}
		if (self.didConnect) {
			self.didConnect();
		}
	}
	return connected;
}

- (BOOL)authenticate:(NSString *)password {
	BOOL completed = mpd_run_password(conn, [password UTF8String]);
	if (completed) {
		for (MDHelper *helper in self.helpers) {
			helper.conn = conn;
			[helper didAuthenticate];
		}
		if (self.didAuthenticate) {
			self.didAuthenticate();
		}
	}
	return completed;
}

- (void)disconnect {
	[self freeConnection];
}

- (void)freeConnection {
	if (conn) {
		mpd_connection_free(conn);
		conn = NULL;
		
		for (MDHelper *helper in self.helpers) {
			helper.conn = NULL;
			[helper didDisconnect];
		}
		self.helpers = nil;
		
		for (int i=0; i<MpdSupportedActionsCount; i++) {
			containers[i] = nil;
		}
	}
}

- (NSUInteger)lastErrorCode {
	if (!conn) {
		return MPD_ERROR_TIMEOUT;
	}
	enum mpd_error code = mpd_connection_get_error(conn);
	if (MPD_ERROR_CLOSED==code || MPD_ERROR_TIMEOUT==code) {
		[self freeConnection];
	}
	return code;
}

- (NSUInteger)lastOperationHasFailed {
	return MPD_ERROR_SUCCESS != self.lastErrorCode;
}

- (BOOL)isDisconnected {
	BOOL isStatusOk = nil!=player.status;
	NSUInteger code = self.lastErrorCode;
	return MPD_ERROR_TIMEOUT==code || MPD_ERROR_CLOSED==code || !isStatusOk;
}

- (NSString *)version {
	const unsigned *number = mpd_connection_get_server_version(conn);
	return [NSString stringWithFormat:@"%d.%d.%d", number[0], number[1], number[2]];
}

- (NSArray *)performEnumaration:(ActionMethod)action withKey:(const char *)key cachingRequest:(dispatch_once_t *)request container:(NSArray **)container {
	dispatch_once(request, ^{
		if (!(*action)(conn)) {
			return;
		}
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:70];
		struct mpd_pair *pair = NULL;
		while ((pair = mpd_recv_pair_named(conn, key))) {
			[items addObject:[NSString stringWithUTF8String:pair->value]];
			mpd_return_pair(conn, pair);
		}
		*container = [NSArray arrayWithArray:items];
	});
	return *container;
}

- (NSArray *)allowedCommands {
	NSArray *arr = containers[MpdSupportedAllowedCommands];
	return [self performEnumaration:actions[MpdSupportedAllowedCommands]
					 withKey:"command"
			  cachingRequest:&cachedRequests[MpdSupportedAllowedCommands]
				   container:&arr];
}

- (NSArray *)disallowedCommands {
	NSArray *arr = containers[MpdSupportedDisallowedCommands];
	return [self performEnumaration:actions[MpdSupportedDisallowedCommands]
							withKey:"command"
					 cachingRequest:&cachedRequests[MpdSupportedDisallowedCommands]
						  container:&arr];
}

- (NSArray *)supportedSchemes {
	NSArray *arr = containers[MpdSupportedUrlSchemes];
	return [self performEnumaration:actions[MpdSupportedUrlSchemes]
							withKey:"handler"
					 cachingRequest:&cachedRequests[MpdSupportedUrlSchemes]
						  container:&arr];
}

- (NSArray *)tagTypes {
	NSArray *arr = containers[MpdSupportedTagTypes];
	return [self performEnumaration:actions[MpdSupportedTagTypes]
							withKey:"tagtype"
					 cachingRequest:&cachedRequests[MpdSupportedTagTypes]
						  container:&arr];
}

@end

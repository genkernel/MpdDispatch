//
//  MpdDispath.m
//  MpdDispath
//
//  Created by kernel on 5/06/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MpdDispatch.h"
#import <netinet/in.h>
#import "Helper+Internals.h"

static unsigned connection_timeout = 10 * 60 * 1000;

typedef enum {
	MpdSupportedAllowedCommands,
	MpdSupportedDisallowedCommands,
	MpdSupportedUrlSchemes,
	MpdSupportedTagTypes,
	
	MpdSupportedActionsCount
} MpdSupportedActions;
typedef bool (*ActionMethod)(struct mpd_connection *);

@interface MpdDispatch()
@property (strong, nonatomic) NSArray *helpers;
@property (strong, nonatomic, readwrite) Playlist *playlist;
@property (strong, nonatomic, readwrite) Player *player;
@property (strong, nonatomic, readwrite) Directory *directory;
@property (strong, nonatomic, readwrite) Search *search;

- (NSArray *)performEnumaration:(ActionMethod)action withKey:(const char *)key cachingRequest:(dispatch_once_t *)request container:(NSArray **)container;
@end

@implementation MpdDispatch {
	struct mpd_connection *conn;
	
	const char *actionKeys[MpdSupportedActionsCount];
	ActionMethod actions[MpdSupportedActionsCount];
	dispatch_once_t cachedRequests[MpdSupportedActionsCount];
	NSArray *containers[MpdSupportedActionsCount];
}
@synthesize helpers, playlist, player, directory, search;

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
		
		self.player = [Player new];
		self.playlist = [Playlist new];
		self.directory = [Directory new];
		self.search = [Search new];
		self.helpers = [NSArray arrayWithObjects:self.playlist, self.player, self.directory, self.search, nil];
	}
	return self;
}

- (void)dealloc {
	[self disconnect];
	
	for (int i=0; i<MpdSupportedActionsCount; i++) {
		containers[i] = nil;
	}
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
		for (Helper *helper in self.helpers) {
			helper.conn = conn;
			[helper didConnect];
		}
	}
	return connected;
}

- (BOOL)authenticate:(NSString *)password {
	BOOL completed = mpd_run_password(conn, [password UTF8String]);
	if (completed) {
		for (Helper *helper in self.helpers) {
			helper.conn = conn;
			[helper didAuthenticate];
		}
	}
	return completed;
}

- (void)disconnect {
	if (conn) {
		mpd_connection_free(conn);
		conn = NULL;
	}
}

- (NSUInteger)lastErrorCode {
	if (!conn) {
		return MPD_ERROR_TIMEOUT;
	}
	return mpd_connection_get_error(conn);
}

- (BOOL)isDisconnected {
	return MPD_ERROR_TIMEOUT==self.lastErrorCode || MPD_ERROR_CLOSED==self.lastErrorCode;
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
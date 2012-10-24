//
//  LibraryItems.m
//  MpdDispatch
//
//  Created by kernel on 5/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDLibraryItems.h"
#import "MDLibraryItems+Internals.h"

@interface MDLibraryItems()
@property (strong, nonatomic) NSMutableDictionary *items, *sectionTitles, *indeces;
@end

@implementation MDLibraryItems {
	SongTags tag;
}
@synthesize sections, sectionIndexTitles;
@synthesize items, sectionTitles, indeces;

- (id)initWithSortingTag:(SongTags)sortingTag {
	self = [self init];
	if (self) {
		tag = sortingTag;
	}
	return self;
}

- (void)loadItems:(NSArray *)songs {
	NSMutableDictionary *d = [NSMutableDictionary dictionary];
	for (MDSong *song in songs) {
		NSString *val = [song tagValueOfType:tag];
		if (!val) {
			continue;
		}
		
		NSMutableArray *arr = d[val];
		if (arr) {
			[arr addObject:song];
		} else {
			arr = [NSMutableArray arrayWithObject:song];
			d[val] = arr;
		}
	}
	self.items = [NSDictionary dictionaryWithDictionary:d];
	// TODO: Sort items.
	
	// Sort sections.
	NSArray *allSections = self.items.allKeys;
	sections = [allSections sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	// Generate sectionIndexTitles.
	self.sectionTitles = [NSMutableDictionary dictionary];
	for (NSString *title in allSections) {
		const char *str = [title UTF8String];
		int letter = toupper(str[0]);
		NSString *firstLetter = [NSString stringWithCharacters:(const unichar *)&letter length:1];
		
		NSMutableArray *arr = self.sectionTitles[firstLetter];
		if (arr) {
			[arr addObject:title];
		} else {
			arr = [NSMutableArray arrayWithObject:title];
			self.sectionTitles[firstLetter] = arr;
		}
	}
	
	// Create sectionIndexTitles - Sort sectionTitles.
	sectionIndexTitles = [self.sectionTitles.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	// Precalculate * indeces offsets.
	self.indeces = [NSMutableDictionary dictionaryWithCapacity:self.sectionIndexTitles.count];
	NSUInteger baseIndex = 0;
	for (NSString *letter in self.sectionIndexTitles) {
		self.indeces[letter] = [NSNumber numberWithInt:baseIndex];
		
		NSArray *titles = self.sectionTitles[letter];
		baseIndex += titles.count;
	}
}

- (MDSong *)itemForSection:(NSUInteger)section atRow:(NSUInteger)row {
	NSArray *sectionItems = [self itemsForSection:section];
	MDSong *song = sectionItems[row];
	return song;
}

- (NSArray *)sectionItemsForSection:(NSUInteger)section {
	NSString *key = self.sectionIndexTitles[section];
	return self.sectionTitles[key];
}

- (NSArray *)itemsForSection:(NSUInteger)section {
	NSString *title = self.sections[section];
	return self.items[title];
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [self.indeces[title] intValue];
}

@end

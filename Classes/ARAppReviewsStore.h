//
//	Copyright (c) 2008-2011, AppReviews
//	http://github.com/gambcl/AppReviews
//	http://www.perculasoft.com/appreviews
//	All rights reserved.
//
//	This software is released under the terms of the BSD License.
//	http://www.opensource.org/licenses/bsd-license.php
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//	* Redistributions of source code must retain the above copyright notice, this
//	  list of conditions and the following disclaimer.
//	* Redistributions in binary form must reproduce the above copyright notice,
//	  this list of conditions and the following disclaimer
//	  in the documentation and/or other materials provided with the distribution.
//	* Neither the name of AppReviews nor the names of its contributors may be used
//	  to endorse or promote products derived from this software without specific
//	  prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//	IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//	OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>


typedef enum
{
	ARMostHelpfulSortOrder = 1,
	ARMostFavorableSortOrder,
	ARMostCriticalSortOrder,
	ARMostRecentSortOrder
} ARReviewsSortOrder;


@class FMDatabase;
@class ARAppStore;
@class ARAppStoreApplication;
@class ARAppStoreApplicationDetails;


/**
 * Singleton class to encapsulate model data access.
 */
@interface ARAppReviewsStore : NSObject
{
	FMDatabase *database;
	NSString *iTunesUserAgent;
	NSArray *appStores;
	NSMutableArray *applications;
	NSMutableDictionary *appDetails;	// dict(appId => dict(storeId => details))
	NSMutableDictionary *appReviews;	// dict(appId => dict(storeId => array(review)))
}

@property (readonly) NSString *iTunesUserAgent;
@property (retain) NSArray *appStores;

/**
 * Get the singleton instance.
 */
+ (ARAppReviewsStore *)sharedInstance;

- (BOOL)save;
- (void)close;

- (ARAppStore *)storeForIdentifier:(NSString *)storeIdentifier;
- (NSArray *)applications;
- (ARAppStoreApplication *)applicationForIdentifier:(NSString *)appIdentifier;
- (ARAppStoreApplication *)applicationAtIndex:(NSUInteger)index;
- (NSUInteger)applicationCount;
- (void)addApplication:(ARAppStoreApplication *)app;
- (void)addApplication:(ARAppStoreApplication *)app atIndex:(NSUInteger)index;
- (void)moveApplicationAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)removeApplication:(ARAppStoreApplication *)app;
- (void)resetDetailsForApplication:(ARAppStoreApplication *)app;
- (ARAppStoreApplicationDetails *)detailsForApplication:(ARAppStoreApplication *)app inStore:(ARAppStore *)store;
- (void)setReviews:(NSArray *)reviews forApplication:(ARAppStoreApplication *)app inStore:(ARAppStore *)store;
- (NSArray *)reviewsForApplication:(ARAppStoreApplication *)app inStore:(ARAppStore *)store;
- (void)refreshAppStores;

@end

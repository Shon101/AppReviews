//
//	Copyright (c) 2008-2010, AppReviews
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

#import "ARAppStoreApplicationDetailsImporter.h"
#import "ARAppStoreApplicationDetails.h"
#import "ARAppStoreApplication.h"
#import "ARAppStore.h"
#import "AppReviewsAppDelegate.h"
#import "GTMRegex.h"
#import "NSString+PSPathAdditions.h"
#import "NSString+PSIconFilenames.h"
#import "PSLog.h"
#import "TouchXML.h"
#import "CXMLNode_XPathExtensions.h"


#define kARAppIconSize (29)


@interface ARAppStoreApplicationDetailsImporter ()

- (void)fetchApplicationIcon;
- (NSData *)dataFromURL:(NSURL *)url;
+ (CGImageRef)iconMask;
+ (UIImage *)iconOutline;
- (NSString *)appIconPath;

@end


@implementation ARAppStoreApplicationDetailsImporter

@synthesize appIdentifier, storeIdentifier, category, categoryIdentifier, ratingCountAll, ratingCountCurrent, ratingAll, ratingCurrent, reviewCountAll, reviewCountCurrent, lastSortOrder, lastUpdated;
@synthesize released, appVersion, appSize, localPrice, appName, appCompany, companyURL, companyURLTitle, supportURL, supportURLTitle, appIconURL;
@synthesize ratingCountAll5Stars, ratingCountAll4Stars, ratingCountAll3Stars, ratingCountAll2Stars, ratingCountAll1Star;
@synthesize ratingCountCurrent5Stars, ratingCountCurrent4Stars, ratingCountCurrent3Stars, ratingCountCurrent2Stars, ratingCountCurrent1Star;
@synthesize hasNewReviews, importState, fetchAppIcon;

- (id)init
{
	return [self initWithAppIdentifier:nil storeIdentifier:nil];
}

- (id)initWithAppIdentifier:(NSString *)inAppIdentifier storeIdentifier:(NSString *)inStoreIdentifier
{
	if (self = [super init])
	{
		self.appIdentifier = inAppIdentifier;
		self.storeIdentifier = inStoreIdentifier;
		self.category = nil;
		self.categoryIdentifier = nil;
		self.ratingCountAll = 0;
		self.ratingCountAll5Stars = 0;
		self.ratingCountAll4Stars = 0;
		self.ratingCountAll3Stars = 0;
		self.ratingCountAll2Stars = 0;
		self.ratingCountAll1Star = 0;
		self.ratingCountCurrent = 0;
		self.ratingCountCurrent5Stars = 0;
		self.ratingCountCurrent4Stars = 0;
		self.ratingCountCurrent3Stars = 0;
		self.ratingCountCurrent2Stars = 0;
		self.ratingCountCurrent1Star = 0;
		self.ratingAll = 0.0;
		self.ratingCurrent = 0.0;
		self.reviewCountAll = 0;
		self.reviewCountCurrent = 0;
		self.released = nil;
		self.appVersion = nil;
		self.appSize = nil;
		self.localPrice = nil;
		self.appName = nil;
		self.appCompany = nil;
		self.companyURL = nil;
		self.companyURLTitle = nil;
		self.supportURL = nil;
		self.supportURLTitle = nil;
		self.lastSortOrder = (ARReviewsSortOrder) [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"];
		self.lastUpdated = [NSDate distantPast];
		self.hasNewReviews = NO;
		self.importState = DetailsImportStateEmpty;
		self.fetchAppIcon = NO;
	}
	return self;
}

- (void)dealloc
{
	[appIdentifier release];
	[storeIdentifier release];
	[category release];
	[categoryIdentifier release];
	[released release];
	[appVersion release];
	[appSize release];
	[localPrice release];
	[appName release];
	[appCompany release];
	[companyURL release];
	[companyURLTitle release];
	[supportURL release];
	[supportURLTitle release];
	[lastUpdated release];
	[super dealloc];
}

- (NSURL *)detailsURL
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&type=Purple+Software", appIdentifier]];
}

- (NSString *)localXMLFilename
{
	NSString *documentsDirectory = [NSString documentsPath];
	NSString *result = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@-details.xml", self.appIdentifier, self.storeIdentifier]];
	return result;
}

- (BOOL)validateDetails
{
	if (self.category==nil || [self.category length]==0)
		return NO;
	if (self.categoryIdentifier==nil || [self.categoryIdentifier length]==0)
		return NO;
	if (self.released==nil || [self.released length]==0)
		return NO;
	if (self.appVersion==nil || [self.appVersion length]==0)
		return NO;
	if (self.appSize==nil || [self.appSize length]==0)
		return NO;
	if (self.localPrice==nil || [self.localPrice length]==0)
		return NO;
	if (self.appName==nil || [self.appName length]==0)
		return NO;
	if (self.appCompany==nil || [self.appCompany length]==0)
		return NO;

	// Everything looks OK.
	return YES;
}

- (void)processDetails:(NSData *)data
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

#ifdef DEBUG
	// Save XML file for debugging.
	[data writeToFile:[self localXMLFilename] atomically:YES];
#else
	// Clean up files written by previous debug builds.
	NSString *debugFilename = [self localXMLFilename];
	[[NSFileManager defaultManager] removeItemAtPath:debugFilename error:NULL];
#endif

	// Initialise some members used whilst parsing XML content.
	self.importState = DetailsImportStateParsing;

	CXMLDocument *xmlDocument = [[CXMLDocument alloc] initWithData:data options:0 error:nil];
	if (xmlDocument)
	{
		// Extract details from XML content.
		CXMLElement *rootElem = [xmlDocument rootElement];

		// First get all the easy text nodes.
		NSError *error = nil;
		NSDictionary *xmlnsDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"http://www.apple.com/itms/",
							  @"itunes",
							  nil];
		NSArray *textNodes = [rootElem nodesForXPath:@"//itunes:TextView/itunes:SetFontStyle" namespaceMappings:xmlnsDict error:&error];
		if (textNodes && [textNodes count] >= 9)
		{
			self.appCompany = [[[textNodes objectAtIndex:0] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			self.appName = [[[textNodes objectAtIndex:1] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

			NSString *categoryValue = [[[textNodes objectAtIndex:2] stringValue] stringByReplacingOccurrencesOfString:@"Category: " withString:@""];
			self.category = [categoryValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

			NSString *updatedValue = [[[textNodes objectAtIndex:3] stringValue] stringByReplacingOccurrencesOfString:@"Updated " withString:@""];
			self.released = [updatedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

			NSString *currentVersionValue = [[[textNodes objectAtIndex:4] stringValue] stringByReplacingOccurrencesOfString:@"Current Version: " withString:@""];
			self.appVersion = [currentVersionValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

			self.appSize = [[[textNodes objectAtIndex:7] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			self.localPrice = [[[textNodes objectAtIndex:8] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

			// Use category string to find the categoryId.
			textNodes = [rootElem nodesForXPath:[NSString stringWithFormat:@"//itunes:PathElement[@displayName='%@']", self.category] namespaceMappings:xmlnsDict error:&error];
			if (textNodes && [textNodes count] > 0)
			{
				NSString *catUrl = [[[textNodes objectAtIndex:0] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				NSArray *parts = [catUrl componentsSeparatedByString:@"/id"];
				parts = [[parts lastObject] componentsSeparatedByString:@"?"];
				self.categoryIdentifier = [parts objectAtIndex:0];
			}

			// Company/support URLs.
			textNodes = [rootElem nodesForXPath:@"//itunes:OpenURL" namespaceMappings:xmlnsDict error:&error];
			if (textNodes && [textNodes count] >= 5)
			{
				CXMLElement *companyURLNode = [textNodes objectAtIndex:2];
				self.companyURL = [[companyURLNode attributeForName:@"url"] stringValue];
				self.companyURLTitle = [[companyURLNode attributeForName:@"draggingName"] stringValue];

				CXMLElement *supportURLNode = [textNodes objectAtIndex:4];
				self.supportURL = [[supportURLNode attributeForName:@"url"] stringValue];
				self.supportURLTitle = [[supportURLNode attributeForName:@"draggingName"] stringValue];
			}

			// App icon URL
			textNodes = [rootElem nodesForXPath:[NSString stringWithFormat:@"//itunes:GotoURL[@draggingName='%@']//itunes:PictureView[@alt='%@ artwork']", self.appName, self.appName] namespaceMappings:xmlnsDict error:&error];
			if (textNodes && [textNodes count] > 0)
			{
				CXMLElement *iconNode = [textNodes objectAtIndex:0];
				self.appIconURL = [[iconNode attributeForName:@"url"] stringValue];
			}

			// Rating counts for CURRENT version.
			textNodes = [rootElem nodesForXPath:@"//itunes:View[@viewName='RatingsFrame']//itunes:Test[@id='1234']//itunes:SetFontStyle[@normalStyle='descriptionTextColor']" namespaceMappings:xmlnsDict error:&error];
			if (textNodes && [textNodes count] >= 6)
			{
				int currentIndex = 0;

				// Total ratings count.
				CXMLElement *ratingsValue = [textNodes objectAtIndex:currentIndex];
				NSString *valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountCurrent = [valueString integerValue];
				currentIndex++;

				// Do we need to skip a row?
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				NSArray *parts = [valueString componentsSeparatedByString:@" "];
				if ([parts count] > 1)
					currentIndex++;

				// 5-star ratings count.
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountCurrent5Stars = [valueString integerValue];
				currentIndex++;
				// 4-star ratings count.
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountCurrent4Stars = [valueString integerValue];
				currentIndex++;
				// 3-star ratings count.
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountCurrent3Stars = [valueString integerValue];
				currentIndex++;
				// 2-star ratings count.
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountCurrent2Stars = [valueString integerValue];
				currentIndex++;
				// 1-star ratings count.
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountCurrent1Star = [valueString integerValue];
				currentIndex++;
			}

			// Rating counts for ALL versions.
			textNodes = [rootElem nodesForXPath:@"//itunes:View[@viewName='RatingsFrame']//itunes:Test[@id='5678']//itunes:SetFontStyle[@normalStyle='descriptionTextColor']" namespaceMappings:xmlnsDict error:&error];
			if (textNodes && [textNodes count] >= 6)
			{
				int currentIndex = 0;

				// Total ratings count.
				CXMLElement *ratingsValue = [textNodes objectAtIndex:currentIndex];
				NSString *valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountAll = [valueString integerValue];
				currentIndex++;

				// Do we need to skip a row?
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				NSArray *parts = [valueString componentsSeparatedByString:@" "];
				if ([parts count] > 1)
					currentIndex++;

				// 5-star ratings count.
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountAll5Stars = [valueString integerValue];
				currentIndex++;
				// 4-star ratings count.
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountAll4Stars = [valueString integerValue];
				currentIndex++;
				// 3-star ratings count.
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountAll3Stars = [valueString integerValue];
				currentIndex++;
				// 2-star ratings count.
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountAll2Stars = [valueString integerValue];
				currentIndex++;
				// 1-star ratings count.
				ratingsValue = [textNodes objectAtIndex:currentIndex];
				valueString = [[ratingsValue stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				self.ratingCountAll1Star = [valueString integerValue];
				currentIndex++;
			}

			// Average rating for CURRENT version.
			textNodes = [rootElem nodesForXPath:@"//itunes:View[@viewName='RatingsFrame']//itunes:Test[@id='1234']//itunes:HBoxView//itunes:VBoxView//itunes:HBoxView" namespaceMappings:xmlnsDict error:&error];
			if (textNodes && [textNodes count] > 0)
			{
				CXMLElement *ratingNode = [textNodes objectAtIndex:0];
				NSString *rating = [[[ratingNode attributeForName:@"alt"] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				GTMRegex *ratingRegex = [GTMRegex regexWithPattern:@"^([0-9])( and a half)? star[s]?"];
				NSArray *subPatterns = [ratingRegex subPatternsOfString:rating];
				if (subPatterns)
				{
					float ratingFloat = (float)[[subPatterns objectAtIndex:1] integerValue];
					if ([subPatterns objectAtIndex:2] != [NSNull null])
					{
						ratingFloat += 0.5;
					}
					self.ratingCurrent = ratingFloat;
				}
				else
				{
					// Didn't match regex.
					self.ratingCurrent = 0.0;
				}
			}

			// Average rating for ALL versions.
			textNodes = [rootElem nodesForXPath:@"//itunes:View[@viewName='RatingsFrame']//itunes:Test[@id='5678']//itunes:HBoxView//itunes:VBoxView//itunes:HBoxView" namespaceMappings:xmlnsDict error:&error];
			if (textNodes && [textNodes count] > 0)
			{
				CXMLElement *ratingNode = [textNodes objectAtIndex:0];
				NSString *rating = [[[ratingNode attributeForName:@"alt"] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				GTMRegex *ratingRegex = [GTMRegex regexWithPattern:@"^([0-9])( and a half)? star[s]?"];
				NSArray *subPatterns = [ratingRegex subPatternsOfString:rating];
				if (subPatterns)
				{
					float ratingFloat = (float)[[subPatterns objectAtIndex:1] integerValue];
					if ([subPatterns objectAtIndex:2] != [NSNull null])
					{
						ratingFloat += 0.5;
					}
					self.ratingAll = ratingFloat;
				}
				else
				{
					// Didn't match regex.
					self.ratingAll = 0.0;
				}
			}

			// Review counts.
			textNodes = [rootElem nodesForXPath:@"//itunes:GotoURL/itunes:TextView/itunes:SetFontStyle[@normalStyle='textColor']/itunes:b" namespaceMappings:xmlnsDict error:&error];
			if (textNodes && [textNodes count] >= 3)
			{
				GTMRegex *regex = [GTMRegex regexWithPattern:@"^([0-9]+)[^0-9].*"];

				// Review counts for CURRENT version.
				CXMLElement *textNode = [textNodes objectAtIndex:[textNodes count]-2];
				NSString *textValue = [[textNode stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				NSArray *substrings = [regex subPatternsOfString:textValue];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
				{
					NSString *count = [substrings objectAtIndex:1];
					self.reviewCountCurrent = [count integerValue];
				}
				else if ([textValue hasPrefix:@"Reviews"])
				{
					// We have >0 current reviews, but no number given, which seems to mean 1 only.
					self.reviewCountCurrent = 1;
				}
				else
				{
					PSLogWarning(@"Unrecognised CURRENT review count: %@", textValue);
				}

				// Review counts for ALL versions.
				textNode = [textNodes lastObject];
				textValue = [[textNode stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				substrings = [regex subPatternsOfString:textValue];
				if (([substrings count] > 0) && ([substrings objectAtIndex:0] != [NSNull null]) && ([substrings objectAtIndex:1] != [NSNull null]))
				{
					NSString *count = [substrings objectAtIndex:1];
					self.reviewCountAll = [count integerValue];
				}
				else if ([textValue hasPrefix:@"See All"])
				{
					// We have >0 reviews, but no number given, which seems to mean 1 only.
					self.reviewCountAll = 1;
				}
				else
				{
					PSLogWarning(@"Unrecognised ALL review count: %@", textValue);
				}
			}

			self.importState = ([self validateDetails] ? DetailsImportStateComplete : DetailsImportStateParseFailed);
		}
		else
			self.importState = DetailsImportStateParseFailed;

		[xmlDocument release], xmlDocument = nil;
	}
	else
		self.importState = DetailsImportStateParseFailed;

	// Did we successfully extract the details?
	if (self.importState == DetailsImportStateComplete)
	{
		PSLog(@"Successfully parsed XML document");
		self.lastUpdated = [NSDate date];
		self.lastSortOrder = (ARReviewsSortOrder) [[NSUserDefaults standardUserDefaults] integerForKey:@"sortOrder"];
	}
	else
	{
		PSLog(@"Failed to parse XML document");
	}

	// Download app icon if necessary.
	if ((self.importState == DetailsImportStateComplete) && (self.appIconURL) && ([self.appIconURL length] > 0))
	{
		// We successfully found the app icon URL, see if we need to download it.

		// Only download icon if fetchAppIcon is YES _OR_ the icon file is missing from the cache.
		NSString *appIconPath = [self appIconPath];
		if (self.fetchAppIcon || ![[NSFileManager defaultManager] fileExistsAtPath:appIconPath])
		{
			// Download icon.
			[self fetchApplicationIcon];
		}
	}

	[pool release];
}

- (void)copyDetailsTo:(ARAppStoreApplicationDetails *)receiver
{
	receiver.appIdentifier = self.appIdentifier;
	receiver.storeIdentifier = self.storeIdentifier;
	receiver.category = self.category;
	receiver.categoryIdentifier = self.categoryIdentifier;
	receiver.ratingCountAll = self.ratingCountAll;
	receiver.ratingCountAll5Stars = self.ratingCountAll5Stars;
	receiver.ratingCountAll4Stars = self.ratingCountAll4Stars;
	receiver.ratingCountAll3Stars = self.ratingCountAll3Stars;
	receiver.ratingCountAll2Stars = self.ratingCountAll2Stars;
	receiver.ratingCountAll1Star = self.ratingCountAll1Star;
	receiver.ratingCountCurrent = self.ratingCountCurrent;
	receiver.ratingCountCurrent5Stars = self.ratingCountCurrent5Stars;
	receiver.ratingCountCurrent4Stars = self.ratingCountCurrent4Stars;
	receiver.ratingCountCurrent3Stars = self.ratingCountCurrent3Stars;
	receiver.ratingCountCurrent2Stars = self.ratingCountCurrent2Stars;
	receiver.ratingCountCurrent1Star = self.ratingCountCurrent1Star;
	receiver.ratingAll = self.ratingAll;
	receiver.ratingCurrent = self.ratingCurrent;
	receiver.reviewCountAll = self.reviewCountAll;
	receiver.reviewCountCurrent = self.reviewCountCurrent;
	receiver.lastSortOrder = self.lastSortOrder;
	receiver.lastUpdated = self.lastUpdated;
	receiver.released = self.released;
	receiver.appVersion = self.appVersion;
	receiver.appSize = self.appSize;
	receiver.localPrice = self.localPrice;
	receiver.appName = self.appName;
	receiver.appCompany = self.appCompany;
	receiver.companyURL = self.companyURL;
	receiver.companyURLTitle = self.companyURLTitle;
	receiver.supportURL = self.supportURL;
	receiver.supportURLTitle = self.supportURLTitle;
	receiver.appIconURL = self.appIconURL;
}


#pragma mark -
#pragma mark Application icon

- (void)fetchApplicationIcon
{
	NSURL *url = [NSURL URLWithString:self.appIconURL];

	// Download icon data.
	NSData *iconData = [self dataFromURL:url];
	if (iconData)
	{
		UIImage *originalIcon = [[UIImage alloc] initWithData:iconData];
		PSLog(@"Original icon size: %@", NSStringFromCGSize(originalIcon.size));

		CGFloat scale = [UIScreen instancesRespondToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0;
		NSAssert1(lrint(scale)==1 || lrint(scale)==2, @"Unsupported scale factor: %f", scale);
		CGSize size = CGSizeMake(kARAppIconSize * scale, kARAppIconSize * scale);
		CGRect rect = CGRectMake(0, 0, kARAppIconSize * scale, kARAppIconSize * scale);
		UIGraphicsBeginImageContext(size);
		CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, [[self class] iconMask]);
		[originalIcon drawInRect:rect];
		[[[self class] iconOutline] drawInRect:rect];
		UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[originalIcon release], originalIcon = nil;
		PSLog(@"Created icon size: %@", NSStringFromCGSize(result.size));

		// Get a PNG representation of the final image.
		NSData *png = UIImagePNGRepresentation(result);
		if (png)
		{
			// Save resized image to file.
			NSString *iconFilePath = [self appIconPath];
			if (iconFilePath)
			{
				// Write image to file.
				[png writeToFile:iconFilePath atomically:YES];
				PSLog(@"App icon saved successfully for %@", self.appName);
				ARAppStoreApplication *app = [[ARAppReviewsStore sharedInstance] applicationForIdentifier:self.appIdentifier];
				[app resetAppIcon];
			}
		}
		else
		{
			PSLogError(@"Failed to save app icon for %@", self.appName);
		}
	}
	else
	{
		PSLogError(@"Failed to download app icon for %@", self.appName);
	}
}

- (NSData *)dataFromURL:(NSURL *)url
{
	PSLogDebug(@"url=%@", url);
	NSData *result = nil;
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:10.0];
	[theRequest setValue:@"iTunes/4.2 (Macintosh; U; PPC Mac OS X 10.2" forHTTPHeaderField:@"User-Agent"];
	[theRequest setValue:[NSString stringWithFormat:@" %@-1", self.storeIdentifier] forHTTPHeaderField:@"X-Apple-Store-Front"];

#ifdef DEBUG
	NSDictionary *headerFields = [theRequest allHTTPHeaderFields];
	PSLogDebug(@"%@", [headerFields descriptionWithLocale:nil indent:2]);
#endif

	AppReviewsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate performSelectorOnMainThread:@selector(increaseNetworkUsageCount) withObject:nil waitUntilDone:YES];
	result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	[appDelegate performSelectorOnMainThread:@selector(decreaseNetworkUsageCount) withObject:nil waitUntilDone:YES];
	if (result==nil && error)
	{
		PSLogError(@"URL request failed with error: %@", error);
	}
	return result;
}

+ (CGImageRef)iconMask
{
	static CGImageRef _iconMask = NULL;

	@synchronized(self)
	{
		if (!_iconMask)
		{
			UIImage *maskImage = [UIImage imageNamed:@"iconmask"];				// iOS 4 requires no extension and handles Retina display support.
			if (maskImage == nil)
				maskImage = [UIImage imageNamed:@"iconmask.png"];						// iOS 3 requires extension.

			CGImageRef maskImageRef = [maskImage CGImage];
			_iconMask = CGImageMaskCreate(CGImageGetWidth(maskImageRef),
										  CGImageGetHeight(maskImageRef),
										  CGImageGetBitsPerComponent(maskImageRef),
										  CGImageGetBitsPerPixel(maskImageRef),
										  CGImageGetBytesPerRow(maskImageRef),
										  CGImageGetDataProvider(maskImageRef),
										  NULL,
										  false);
		}
	}

	return _iconMask;
}

+ (UIImage *)iconOutline
{
	static UIImage *_iconOutline = nil;

	@synchronized(self)
	{
		if (!_iconOutline)
		{
			_iconOutline = [[UIImage imageNamed:@"iconoutline"] retain];					// iOS 4 requires no extension and handles Retina display support.
			if (_iconOutline == nil)
				_iconOutline = [[UIImage imageNamed:@"iconoutline.png"] retain];		// iOS 3 requires extension.
		}
	}

	return _iconOutline;
}

- (NSString *)appIconPath
{
	NSMutableArray *scales = [NSMutableArray arrayWithObject:@""];
	CGFloat scale = [UIScreen instancesRespondToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0;
	if (lrint(scale) == 2)
	{
		[scales insertObject:@"@2x" atIndex:0];
	}

	NSArray *filenames = [self.appIdentifier preferredIconFilenamesWithSizeModifiers:[NSArray arrayWithObject:@""]
																	  scaleModifiers:scales
																	 deviceModifiers:[NSArray arrayWithObject:@""]];
	return [[ARAppStoreApplication appIconCachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [filenames objectAtIndex:0]]];
}

@end


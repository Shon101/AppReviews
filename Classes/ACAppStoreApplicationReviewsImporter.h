//
//	Copyright (c) 2008-2009, AppCritics
//	http://github.com/gambcl/AppCritics
//	http://www.perculasoft.com/appcritics
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
//	* Neither the name of AppCritics nor the names of its contributors may be used
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

#import <UIKit/UIKit.h>
#import "ACAppReviewsStore.h"
#import "AppCriticsAppDelegate.h"


//@class ACAppStoreApplication;
//@class ACAppStore;


typedef enum
{
	ReviewsImportStateEmpty,
	ReviewsImportStateDownloading,
	ReviewsImportStateDownloadFailed,
	ReviewsImportStateParsing,
	ReviewsImportStateParseFailed,
	ReviewsImportStateComplete
} ReviewsImportState;


typedef enum
{
	ReviewsSeekingSortByPopup,
	ReviewsSeekingSummary,
	ReviewsSeekingRating,
	ReviewsSeekingReportConcern,
	ReviewsSeekingBy,
	ReviewsSeekingReview,
	ReviewsSeekingHelpful,
	ReviewsSeekingYes,
	ReviewsSeekingYesNoSeparator,
	ReviewsSeekingNo,
	ReviewsReadingSortByPopup,
	ReviewsReadingSummary,
	ReviewsReadingReportConcern,
	ReviewsReadingBy,
	ReviewsReadingReviewer,
	ReviewsReadingReviewVersionDate,
	ReviewsReadingReview,
	ReviewsReadingHelpful,
	ReviewsReadingYes,
	ReviewsReadingYesNoSeparator,
	ReviewsReadingNo,
	ReviewsParsingComplete
} ReviewsXMLState;


@interface ACAppStoreApplicationReviewsImporter : NSObject
{
	NSString *appIdentifier;
	NSString *storeIdentifier;

	ReviewsImportState importState;

	// Members used during XML parsing.
	ReviewsXMLState xmlState;
	NSMutableString *currentString;
	NSString *currentReviewSummary;
	double currentReviewRating;
	NSString *currentReviewer;
	NSString *currentReviewVersion;
	NSString *currentReviewDate;
	NSString *currentReviewDetail;
	NSUInteger currentReviewIndex;
	NSMutableArray *reviews;
}

@property (nonatomic, copy) NSString *appIdentifier;
@property (nonatomic, copy) NSString *storeIdentifier;
@property (nonatomic, assign) ReviewsImportState importState;

- (id)initWithAppIdentifier:(NSString *)inAppIdentifier storeIdentifier:(NSString *)inStoreIdentifier;
- (NSURL *)reviewsURL;
- (void)processReviews:(NSData *)data;
- (NSArray *)reviews;

@end
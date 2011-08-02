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

#import "ARAppStoreReviewsHeaderTableCell.h"
#import "ARAppReviewsStore.h"
#import "ARAppStoreApplicationDetails.h"
#import "ARAppStoreApplication.h"
#import "UIColor+MoreColors.h"
#import "AppReviewsAppDelegate.h"


static UIColor *sLabelColor = nil;
static CGGradientRef sGradient = NULL;


@implementation ARAppStoreReviewsHeaderTableCell

@synthesize appDetails, appCompany, versionLabel, versionValue, sizeLabel, sizeValue, dateLabel, dateValue;
@synthesize priceLabel, priceValue;

+ (void)initialize
{
	sLabelColor = [[UIColor tableCellTextBlue] retain];

	// Create the gradient.
	CGColorSpaceRef myColorspace;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { 235.0/255.0, 238.0/255.0, 245.0/255.0, 1.0,	// Start color
							  159.0/255.0, 158.0/255.0, 163.0/255.0, 1.0 };	// End color
	myColorspace = CGColorSpaceCreateDeviceRGB();
	sGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	CGColorSpaceRelease(myColorspace);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
#define TITLE_FONT_SIZE 24.0
#define DETAIL_FONT_SIZE 14.0
    if (self = [super initWithStyle:style reuseIdentifier:(NSString *)reuseIdentifier])
	{
        // Initialization code
		self.clearsContextBeforeDrawing = YES;
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		appName = [[UILabel alloc] initWithFrame:CGRectZero];
		appName.backgroundColor = [UIColor clearColor];
		appName.opaque = NO;
		appName.textColor = [UIColor blackColor];
		appName.highlightedTextColor = [UIColor whiteColor];
		appName.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
		appName.textAlignment = UITextAlignmentLeft;
		appName.lineBreakMode = UILineBreakModeTailTruncation;
		appName.adjustsFontSizeToFitWidth = YES;
		appName.minimumFontSize = 10.0;
		appName.numberOfLines = 1;
		[self.contentView addSubview:appName];

		appCompany = [[UILabel alloc] initWithFrame:CGRectZero];
		appCompany.backgroundColor = [UIColor clearColor];
		appCompany.opaque = NO;
		appCompany.textColor = [UIColor blackColor];
		appCompany.highlightedTextColor = [UIColor whiteColor];
		appCompany.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		appCompany.textAlignment = UITextAlignmentLeft;
		appCompany.lineBreakMode = UILineBreakModeTailTruncation;
		appCompany.adjustsFontSizeToFitWidth = YES;
		appCompany.minimumFontSize = 10.0;
		appCompany.numberOfLines = 1;
		[self.contentView addSubview:appCompany];

		priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		priceLabel.backgroundColor = [UIColor clearColor];
		priceLabel.opaque = NO;
		priceLabel.textColor = sLabelColor;
		priceLabel.highlightedTextColor = [UIColor whiteColor];
		priceLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		priceLabel.textAlignment = UITextAlignmentLeft;
		priceLabel.lineBreakMode = UILineBreakModeTailTruncation;
		priceLabel.numberOfLines = 1;
		priceLabel.text = @"Price:";
		[self.contentView addSubview:priceLabel];

		priceValue = [[UILabel alloc] initWithFrame:CGRectZero];
		priceValue.backgroundColor = [UIColor clearColor];
		priceValue.opaque = NO;
		priceValue.textColor = [UIColor blackColor];
		priceValue.highlightedTextColor = [UIColor whiteColor];
		priceValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		priceValue.textAlignment = UITextAlignmentLeft;
		priceValue.lineBreakMode = UILineBreakModeTailTruncation;
		priceValue.numberOfLines = 1;
		[self.contentView addSubview:priceValue];

		dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.opaque = NO;
		dateLabel.textColor = sLabelColor;
		dateLabel.highlightedTextColor = [UIColor whiteColor];
		dateLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		dateLabel.textAlignment = UITextAlignmentLeft;
		dateLabel.lineBreakMode = UILineBreakModeTailTruncation;
		dateLabel.numberOfLines = 1;
		dateLabel.text = @"Released:";
		[self.contentView addSubview:dateLabel];

		dateValue = [[UILabel alloc] initWithFrame:CGRectZero];
		dateValue.backgroundColor = [UIColor clearColor];
		dateValue.opaque = NO;
		dateValue.textColor = [UIColor blackColor];
		dateValue.highlightedTextColor = [UIColor whiteColor];
		dateValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		dateValue.textAlignment = UITextAlignmentLeft;
		dateValue.lineBreakMode = UILineBreakModeTailTruncation;
		dateValue.numberOfLines = 1;
		[self.contentView addSubview:dateValue];

		versionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		versionLabel.backgroundColor = [UIColor clearColor];
		versionLabel.opaque = NO;
		versionLabel.textColor = sLabelColor;
		versionLabel.highlightedTextColor = [UIColor whiteColor];
		versionLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		versionLabel.textAlignment = UITextAlignmentRight;
		versionLabel.lineBreakMode = UILineBreakModeTailTruncation;
		versionLabel.numberOfLines = 1;
		versionLabel.text = @"Version:";
		[self.contentView addSubview:versionLabel];

		versionValue = [[UILabel alloc] initWithFrame:CGRectZero];
		versionValue.backgroundColor = [UIColor clearColor];
		versionValue.opaque = NO;
		versionValue.textColor = [UIColor blackColor];
		versionValue.highlightedTextColor = [UIColor whiteColor];
		versionValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		versionValue.textAlignment = UITextAlignmentRight;
		versionValue.lineBreakMode = UILineBreakModeTailTruncation;
		versionValue.numberOfLines = 1;
		[self.contentView addSubview:versionValue];

		sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		sizeLabel.backgroundColor = [UIColor clearColor];
		sizeLabel.opaque = NO;
		sizeLabel.textColor = sLabelColor;
		sizeLabel.highlightedTextColor = [UIColor whiteColor];
		sizeLabel.font = [UIFont boldSystemFontOfSize:DETAIL_FONT_SIZE];
		sizeLabel.textAlignment = UITextAlignmentRight;
		sizeLabel.lineBreakMode = UILineBreakModeTailTruncation;
		sizeLabel.numberOfLines = 1;
		sizeLabel.text = @"Size:";
		[self.contentView addSubview:sizeLabel];

		sizeValue = [[UILabel alloc] initWithFrame:CGRectZero];
		sizeValue.backgroundColor = [UIColor clearColor];
		sizeValue.opaque = NO;
		sizeValue.textColor = [UIColor blackColor];
		sizeValue.highlightedTextColor = [UIColor whiteColor];
		sizeValue.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		sizeValue.textAlignment = UITextAlignmentRight;
		sizeValue.lineBreakMode = UILineBreakModeTailTruncation;
		sizeValue.numberOfLines = 1;
		[self.contentView addSubview:sizeValue];

		self.appDetails = nil;
    }
    return self;
}

- (void)dealloc
{
	[appName release];
	[appCompany release];
	[versionLabel release];
	[versionValue release];
	[sizeLabel release];
	[sizeValue release];
	[dateLabel release];
	[dateValue release];
	[priceLabel release];
	[priceValue release];
	[appDetails release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = 0.0;
	myStartPoint.y = 0.0;
	myEndPoint.x = 0.0;
	myEndPoint.y = self.bounds.size.height - 1.0;
	CGContextDrawLinearGradient (context, sGradient, myStartPoint, myEndPoint, 0);
}

- (void)layoutSubviews
{
#define MARGIN_X	7
#define MARGIN_Y	1
#define INNER_MARGIN_X	4
#define INNER_MARGIN_Y	0
    [super layoutSubviews];

    CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGFloat boundsY = contentRect.origin.y;
	CGRect frame;
	CGFloat posX;
	CGFloat posY;

	// App name label.
	posX = boundsX + MARGIN_X;
	posY = boundsY + MARGIN_Y;
	CGFloat maxHeight = appName.font.pointSize + MARGIN_Y;
	CGSize itemSize = [appName.text sizeWithFont:appName.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),maxHeight) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, contentRect.size.width-(2*MARGIN_X), itemSize.height);
	appName.frame = frame;

	// App company label.
	posY += (itemSize.height + INNER_MARGIN_Y);
	maxHeight = appCompany.font.pointSize + INNER_MARGIN_Y;
	itemSize = [appCompany.text sizeWithFont:appCompany.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),maxHeight) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, contentRect.size.width-(2*MARGIN_X), itemSize.height);
	appCompany.frame = frame;

	// Price label.
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = [priceLabel.text sizeWithFont:priceLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	priceLabel.frame = frame;
	// Price value.
	posX += (itemSize.width + INNER_MARGIN_X);
	itemSize = [priceValue.text sizeWithFont:priceValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	priceValue.frame = frame;
	// Version value.
	itemSize = [versionValue.text sizeWithFont:versionValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	posX = boundsX + contentRect.size.width - (MARGIN_X + itemSize.width);
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	versionValue.frame = frame;
	// Version label.
	itemSize = [versionLabel.text sizeWithFont:versionLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	posX -= (itemSize.width + INNER_MARGIN_X);
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	versionLabel.frame = frame;

	// Date label.
	posX = boundsX + MARGIN_X;
	posY += (itemSize.height + INNER_MARGIN_Y);
	itemSize = [dateLabel.text sizeWithFont:dateLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	dateLabel.frame = frame;
	// Date value.
	posX += (itemSize.width + INNER_MARGIN_X);
	itemSize = [dateValue.text sizeWithFont:dateValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	dateValue.frame = frame;
	// Size value.
	itemSize = [sizeValue.text sizeWithFont:sizeValue.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	posX = boundsX + contentRect.size.width - (MARGIN_X + itemSize.width);
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	sizeValue.frame = frame;
	// Size label.
	itemSize = [sizeLabel.text sizeWithFont:sizeLabel.font constrainedToSize:CGSizeMake(contentRect.size.width-(2*MARGIN_X),CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
	posX -= (itemSize.width + INNER_MARGIN_X);
	frame = CGRectMake(posX, posY, itemSize.width, itemSize.height);
	sizeLabel.frame = frame;
}

- (void)setAppDetails:(ARAppStoreApplicationDetails *)inDetails
{
	[inDetails retain];
	[appDetails release];
	appDetails = inDetails;

	if (appDetails)
	{
		ARAppStoreApplication *theApp = [[ARAppReviewsStore sharedInstance] applicationForIdentifier:appDetails.appIdentifier];
		if (theApp.name)
			appName.text = theApp.name;
		else
			appName.text = theApp.appIdentifier;
		if (theApp.company)
			appCompany.text = theApp.company;
		else
			appCompany.text = @"Waiting for first update";
		priceValue.text = (appDetails.localPrice ? appDetails.localPrice : @"Unknown");
		dateValue.text = (appDetails.released ? appDetails.released : @"Unknown");
		versionValue.text = (appDetails.appVersion ? appDetails.appVersion : @"Unknown");
		sizeValue.text = (appDetails.appSize ? appDetails.appSize : @"Unknown");
	}
	else
	{
		appName.text = @"";
		appCompany.text = @"";
		priceValue.text = @"";
		dateValue.text = @"";
		versionValue.text = @"";
		sizeValue.text = @"";
	}

	[self setNeedsLayout];
	[self setNeedsDisplay];
}

@end

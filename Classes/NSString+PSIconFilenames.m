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

#import "NSString+PSIconFilenames.h"


@implementation NSString (PSIconFilenames)

- (NSArray *)preferredIconFilenames
{
	NSMutableArray *sizes = [NSMutableArray arrayWithObject:@""];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		[sizes insertObject:@"-72" atIndex:0];
	}

	return [self preferredIconFilenamesWithSizeModifiers:sizes];
}

- (NSArray *)preferredIconFilenamesWithSizeModifiers:(NSArray *)sizes
{
	NSMutableArray *scales = [NSMutableArray arrayWithObject:@""];
	CGFloat scale = [UIScreen instancesRespondToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0;
	if (lrint(scale) == 2)
	{
		[scales insertObject:@"@2x" atIndex:0];
	}

	NSMutableArray *devices = [NSMutableArray arrayWithObject:@""];
	switch (UI_USER_INTERFACE_IDIOM())
	{
		case UIUserInterfaceIdiomPad:
			[devices insertObject:@"~ipad" atIndex:0];
			break;
		case UIUserInterfaceIdiomPhone:
			[devices insertObject:@"~iphone" atIndex:0];
			break;
	}

	return [self preferredIconFilenamesWithSizeModifiers:sizes scaleModifiers:scales deviceModifiers:devices];
}

- (NSArray *)preferredIconFilenamesWithSizeModifiers:(NSArray *)sizes scaleModifiers:(NSArray *)scales deviceModifiers:(NSArray *)devices
{
	NSMutableArray *results = [NSMutableArray array];

	// Ensure we have at least an empty string in each array.
	NSArray *allSizes = (sizes && [sizes count] > 0 ? sizes : [NSArray arrayWithObject:@""]);
	NSArray *allScales = (scales && [scales count] > 0 ? scales : [NSArray arrayWithObject:@""]);
	NSArray *allDevices = (devices && [devices count] > 0 ? devices : [NSArray arrayWithObject:@""]);

	for (NSString *sizeModifier in allSizes)
	{
		for (NSString *scaleModifier in allScales)
		{
			for (NSString *deviceModifier in allDevices)
			{
				[results addObject:[NSString stringWithFormat:@"%@%@%@%@", self, sizeModifier, scaleModifier, deviceModifier]];
			}
		}
	}

	return [NSArray arrayWithArray:results];
}

@end

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

#import "ARAppStore.h"


@implementation ARAppStore

@synthesize name, storeIdentifier, enabled;

- (id)init
{
	return [self initWithName:nil storeIdentifier:nil];
}

// Designated initialiser.
- (id)initWithName:(NSString *)inName storeIdentifier:(NSString *)inStoreIdentifier
{
	if (self = [super init])
	{
		self.name = inName;
		self.storeIdentifier = inStoreIdentifier;
		enabled = NO;
		if (storeIdentifier && [storeIdentifier length] > 0)
		{
			// Set the enabled flag from the app preferences.
			[self refreshEnabled];
		}
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[storeIdentifier release];
	[super dealloc];
}

- (NSComparisonResult)compare:(ARAppStore *)other
{
	return [self.name compare:other.name];
}

- (void)refreshEnabled
{
	enabled = [[NSUserDefaults standardUserDefaults] boolForKey:storeIdentifier];
}

@end

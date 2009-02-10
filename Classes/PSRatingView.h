//
//  PSRatingView.h
//  AppCritics
//
//  Created by Charles Gamble on 16/11/2008.
//  Copyright 2008 Charles Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kStarWidth		(16)
#define kStarMargin		(2)
#define kRatingWidth	((5*kStarWidth)+(4*kStarMargin))
#define kRatingHeight	(kStarWidth)


@interface PSRatingView : UIView
{
	float rating;
}

@property (nonatomic, assign) float rating;

@end
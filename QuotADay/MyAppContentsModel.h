//
//  MyAppContentsModel.h
//  MyApp
//
//  Created by Varsha Godbole on 12/21/13.
//  Copyright (c) 2013 Varsha Godbole. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyAppContentsModel : NSObject

@property(strong, nonatomic) UIImage *backgroundImage;
//@property(strong, nonatomic) NSURL *imageURL;

-(void)photosFromWebsite;
-(NSString *)quoteOfTheDay;

@end

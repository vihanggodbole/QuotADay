//
//  MyAppContentsModel.m
//  MyApp
//
//  Created by Varsha Godbole on 12/21/13.
//  Copyright (c) 2013 Varsha Godbole. All rights reserved.
//

#import "MyAppContentsModel.h"
#import <PXAPI/PXAPI.h>
#import <PXRequest+Creation.h>
#import <PXAPI/PXRequest.h>
#define SMALL_PHOTO_SIZE 3
#define LARGE_PHOTO_SIZE 4

@interface MyAppContentsModel()
@property (strong, nonatomic) NSArray *quotes;
@end

@implementation MyAppContentsModel

#pragma mark model

-(NSString *)quoteOfTheDay{
    
    //get quotes from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"myData" ofType:@"plist"];
    NSMutableDictionary *dataFromPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    self.quotes = [dataFromPlist objectForKey:@"quoteArray"];
    
    //compare date
    NSDate *date = [NSDate date];
    NSDate *dateFromPlist = [dataFromPlist objectForKey:@"todayDate"];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateInFile = [dateformatter stringFromDate:dateFromPlist];    //get the dates in strings
    NSString *today = [dateformatter stringFromDate:date];

    NSNumber *dayNumber = [dataFromPlist objectForKey:@"dayNumber"];
    int temp = [dayNumber intValue];
    //change the value of index and date in the plist the next day
    if(![today isEqualToString:dateInFile]){
        temp++;
        NSNumber *newdayNumber = [[NSNumber alloc] initWithInt:temp];
        [dataFromPlist setValue:date forKey:@"todayDate"];  //write today's date to the plist
        [dataFromPlist setValue:newdayNumber forKey:@"dayNumber"];
        [dataFromPlist writeToFile:path atomically:YES];    //write back to plist
    }
    NSString *quoteOfTheDay = [NSString stringWithFormat:@"%@",[self.quotes objectAtIndex:temp]];
    return quoteOfTheDay;
}

-(UIImage *)backgroundImage{
    NSLog(@"getter called");
    return _backgroundImage;
}

-(void)photosFromWebsite{
    self.backgroundImage = nil;
    [PXRequest requestForPhotoFeature:PXAPIHelperPhotoFeatureEditors resultsPerPage:1 page:1 photoSizes:PXPhotoModelSizeLarge sortOrder:PXAPIHelperSortOrderRating except:PXPhotoModelCategoryNude only:PXPhotoModelCategoryNature completion:^(NSDictionary *results, NSError *error) {
            NSString *string = [self imageURLfromDictionary:results forSize:SMALL_PHOTO_SIZE];
            [self downloadImageWithString:string];
    }];

}

-(NSString *)imageURLfromDictionary:(NSDictionary *)dictionary forSize:(NSUInteger)size {
    
    NSArray *myArray = [dictionary valueForKeyPath:@"photos.image_url"];
    NSMutableString *myString = [[NSMutableString alloc] init];
    if(myArray)
        [myString setString:[NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]]];
    //Removing the quotation marks and other punctuations from the url
    [myString replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@"(" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@")" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [myString length])];
    [myString replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [myString length])];
    
    NSLog(@"%lu", (unsigned long)[myArray count]);
    
    //separating into large and small versions
    NSArray *array = [myString componentsSeparatedByString:@","];
    if(size == LARGE_PHOTO_SIZE)
        myString = [array objectAtIndex:1];
    else
        myString = [array objectAtIndex:0];

    NSLog(@"%@",myString);
    NSLog(@"%lu",(unsigned long)[myString length]);
    return myString;

}

-(void)downloadImageWithString:(NSString *)string{
    
    //Begin downloading
    NSURL *url = [NSURL URLWithString:string];    //url from the dictionary
    //self.imageURL = [NSURL URLWithString:string];   //temp
    
    NSLog(@"%@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
        UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
        dispatch_async(dispatch_get_main_queue(), ^{    self.backgroundImage = downloadedImage;
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"image stored" object:nil];
        });
        NSLog(@"Stored image");
    }];
    [task resume];
}
@end

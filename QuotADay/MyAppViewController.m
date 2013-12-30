//
//  MyAppViewController.m
//  MyApp
//
//  Created by Varsha Godbole on 12/21/13.
//  Copyright (c) 2013 Varsha Godbole. All rights reserved.
//

#import "MyAppViewController.h"
#import "MyAppContentsModel.h"
#import <PXAPI.h>
#import <PXRequest.h>
#import <PXRequest+Creation.h>
#import <QuartzCore/QuartzCore.h>

@interface MyAppViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) MyAppContentsModel *model;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *todayDate;
@property (weak, nonatomic) IBOutlet UILabel *quote;
@property (strong, nonatomic) UIImage *image;
@end

@implementation MyAppViewController

#pragma mark custom methods
#pragma mark lazy instantiation
-(UIImageView *)imageView{
    if(!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    return _imageView;
}

-(MyAppContentsModel *)model{
    if(!_model) _model = [[MyAppContentsModel alloc] init];
    return _model;
}

-(UIImage *)image{
    if(!_image) _image = [UIImage imageNamed:@"background"];
    return _image;
}

#pragma mark private methods

-(void)formatDate{
    self.todayDate.layer.cornerRadius = 10;
    [self.todayDate sizeToFit];
    self.todayDate.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
}

-(void)formateQuote{
    self.quote.layer.cornerRadius = 10;
    [self.quote sizeToFit];
    self.quote.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
}

//display system date
-(void)displayDate{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *today = [dateFormatter stringFromDate:date];
    self.todayDate.text = [NSString stringWithFormat:@"%@", today];
    
    //format the font and background
    [self formatDate];
}

//display quote
-(void)displayQuote{
    NSString *qotd = [self.model quoteOfTheDay];
    NSLog(@"qotd = %@", qotd);
    self.quote.text = [NSString stringWithFormat:@"%@", qotd];
    [self formateQuote];
}

-(void)receivedNotification:(NSNotification *)notification{
    if([[notification name] isEqualToString:@"image stored"]){
        [self updateUI];
    }
}

-(void)updateUI{
    [self setTheBackgroundImage];
    [self displayDate];
    [self displayQuote];
    [self.view bringSubviewToFront:self.todayDate];
    [self.view bringSubviewToFront:self.quote];
    [self.spinner stopAnimating];

}

-(void)setTheBackgroundImage{
    self.image = [self.model backgroundImage];
    self.imageView.image = self.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

#pragma mark built in methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.imageView];
    [self.spinner startAnimating];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.model photosFromWebsite];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"image stored"
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"image stored" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

//
//  TheCatDetailViewController.m
//  TheCat
//
//  Created by Roger Yong on 03/05/2016.
//  Copyright © 2016 rycbn. All rights reserved.
//

#import "TheCatDetailViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "NSDictionary+TheCatPackage.h"

@interface TheCatDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *catImageView;

@end

@implementation TheCatDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"The Cat";
    
    NSURL *url = [NSURL URLWithString:self.theCat.imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"cat_placeholder"];
    
    __weak UIImageView *weakImageView = self.catImageView;
    
    [self.catImageView setImageWithURLRequest:request
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                       weakImageView.image = image;
                                       [weakImageView setNeedsDisplay];
                                       [weakImageView setNeedsLayout];
                                   } failure:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

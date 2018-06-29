//
//  DetailViewController.m
//  Flix
//
//  Created by Omar Rasheed on 6/27/18.
//  Copyright © 2018 Omar Rasheed. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *movieImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backdropImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *imageURLString = self.movie[@"poster_path"];
    NSString *fullURLString = [baseURLString stringByAppendingString:imageURLString];
    
    NSURL *imageURL = [NSURL URLWithString:fullURLString];
    [self.movieImageView setImageWithURL:imageURL];
    
    NSString *backdropImageURLString = self.movie[@"backdrop_path"];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropImageURLString];
    
    NSURL *backdropImageURL = [NSURL URLWithString:fullBackdropURLString];
    [self.backdropImageView setImageWithURL:backdropImageURL];
    
    self.titleLabel.text = self.movie[@"title"];
    self.descriptionLabel.text = self.movie[@"overview"];
    
    //[self.titleLabel sizeToFit];
    [self.descriptionLabel sizeToFit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

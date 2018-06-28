//
//  MoviesViewController.m
//  Flix
//
//  Created by Omar Rasheed on 6/27/18.
//  Copyright © 2018 Omar Rasheed. All rights reserved.
//

#import "MoviesViewController.h"
#import "MoviesTableViewCell.h"
#import "DetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UITableView *moviesTableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.moviesTableView.delegate = self;
    self.moviesTableView.dataSource = self;
    
    // Start the activity indicator
    [self.loadingIndicator startAnimating];
    
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    NSLog(@"%@", self.moviesTableView.subviews);
    [self.moviesTableView insertSubview:self.refreshControl atIndex:0];
    NSLog(@"%@", self.moviesTableView.subviews);
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSLog(@"%@", dataDictionary);
            
            self.movies = dataDictionary[@"results"];
            
            for (NSDictionary *movie in self.movies) {
                NSLog(@"%@", movie[@"title"]);
                
            }
            // Stop the activity indicator
            // Hides automatically if "Hides When Stopped" is enabled
            [self.loadingIndicator stopAnimating];
            [self.moviesTableView reloadData];
            
        }
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     MoviesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rowCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.movies[indexPath.row];
    cell.movieTitle.text = movie[@"title"];
    cell.movieDescription.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *imageURLString = movie[@"poster_path"];
    NSString *fullURLString = [baseURLString stringByAppendingString:imageURLString];
    
    NSURL *imageURL = [NSURL URLWithString:fullURLString];
    
    cell.movieImage.image = nil;
    [cell.movieImage setImageWithURL:imageURL];
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.moviesTableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailViewController *detailViewController = [segue destinationViewController];
    detailViewController.movie = movie;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
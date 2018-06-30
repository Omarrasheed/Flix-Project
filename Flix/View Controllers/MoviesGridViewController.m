//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Omar Rasheed on 6/28/18.
//  Copyright © 2018 Omar Rasheed. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailViewController.h"
#import "HeaderCollectionReusableView.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *worstMovies;
@property (nonatomic, strong) NSArray *searchedMovies;
@property (strong, nonatomic) NSArray *groups;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *filteredData;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *collectionRefreshControl;
@property NSInteger *sectionCount;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.sectionCount = (NSInteger *)2;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = self.collectionView.frame.size.width / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    
    self.collectionRefreshControl = [[UIRefreshControl alloc] init];
    [self.collectionRefreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    
    [self.collectionView insertSubview:self.collectionRefreshControl atIndex:0];
    
    [self fetchBestMovies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredData[indexPath.row];
    
    DetailViewController *detailViewController = [segue destinationViewController];
    detailViewController.movie = movie;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (void)fetchBestMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.movies = dataDictionary[@"results"];
            self.filteredData = self.movies;
            self.searchedMovies = self.filteredData;
            [self fetchWorstMovies];
        }
        [self.collectionRefreshControl endRefreshing];
    }];
    [task resume];
}

- (void)fetchWorstMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/discover/movie?sort_by=popularity.asc&api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.worstMovies = dataDictionary[@"results"];
            
            
            [self.collectionView reloadData];
        }
        [self.collectionRefreshControl endRefreshing];
    }];
    [task resume];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    if (indexPath.section == (NSInteger *)0) {
    
        NSDictionary *movie = self.filteredData[indexPath.item];
        
        NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
        NSString *imageURLString = movie[@"poster_path"];
        if (![movie[@"poster_path"] isEqual:[NSNull null]]) {
            NSString *fullURLString = [baseURLString stringByAppendingString:imageURLString];
            NSURL *imageURL = [NSURL URLWithString:fullURLString];
            cell.posterView.image = nil;
            [cell.posterView setImageWithURL:imageURL];
        }
    } else {
        NSDictionary *movie = self.worstMovies[indexPath.item];
        
        NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
        NSString *imageURLString = movie[@"poster_path"];
        if (![movie[@"poster_path"] isEqual:[NSNull null]]) {
            NSString *fullURLString = [baseURLString stringByAppendingString:imageURLString];
            NSURL *imageURL = [NSURL URLWithString:fullURLString];
            cell.posterView.image = nil;
            [cell.posterView setImageWithURL:imageURL];
        }
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.filteredData.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionCount;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        if (searchText == @"") {
            self.filteredData = self.movies;
        } else {
            self.sectionCount = (NSInteger *)1;
            NSString *beginningOfAPI = [NSString stringWithFormat:(@"https://api.themoviedb.org/3/search/movie?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&query=")];
            
            NSString *firstSearchFilter = [searchText stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            NSString *middleOfAPI = [beginningOfAPI stringByAppendingString:(firstSearchFilter)];
            
            NSURL *searchAPIString =[NSURL URLWithString:middleOfAPI];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:searchAPIString cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error != nil) {
                    NSLog(@"%@", [error localizedDescription]);
                }
                else {
                    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    
                    self.searchedMovies = dataDictionary[@"results"];

                    self.filteredData = self.searchedMovies;
                    
                    NSLog(@"%@", self.filteredData);
                    
                    [self.collectionView reloadData];
                }
                [self.collectionRefreshControl endRefreshing];
            }];
            [task resume];
            NSLog(@"%@", self.filteredData);
        }
    }
    else {
        self.sectionCount = (NSInteger *)2;
        self.filteredData = self.movies;
        self.searchedMovies = self.movies;
        [self.collectionView reloadData];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.filteredData = self.movies;
    [self.collectionView reloadData];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    self.groups = @[[NSString stringWithFormat:@"Most Popular"], [NSString stringWithFormat:@"Least Popular"]];
    
    if (kind == UICollectionElementKindSectionHeader) {
        HeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
        
        NSString *title = [[NSString alloc]initWithFormat: @"%@", self.groups[indexPath.section]];
        headerView.sectionLabel.text = title;
        
        reusableview = headerView;
    }
    
    return reusableview;
}

@end

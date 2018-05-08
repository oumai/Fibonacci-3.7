//
//  MeViewController.h
//  Fibonacci
//
//  Created by woaiqiu947 on 16/10/8.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeViewController : KMUIViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    UITableView *myTableView;
    UIView *headerView;
    UIImageView *avatarView;
    NSArray *cellTitleArray;
    NSArray *cellIconArray;
    UIImage *defaultImage;
    UILabel *nameLabel;
    CALayer *bgLayer;
    BOOL isDowmArrowAnimate;
    BOOL isGoLogin;
    BOOL isMyZone;
}
@end

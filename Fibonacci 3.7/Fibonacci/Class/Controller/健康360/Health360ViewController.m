//
//  Health360ViewController.m
//  Fibonacci
//
//  Created by Apple on 2018/3/1.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import "Health360ViewController.h"
#import "BATHealthThreeSecondsController.h"
#import "PsychTestViewController.h"
#import "HealthRecordViewController.h"
#import "HTMLViewController.h"

@interface Health360ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *myTableView;
@end

@implementation Health360ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的健康360";
    titleArray = @[@"我的记录", @"每日健康", @"中医体质", @"健康档案"];
    detailArray = @[@"随时查看指标趋势", @"随时查看指标趋势", @"中医九中体脂辨识与养生", @""];
    imageArray = @[@"record_kangcell_icon",@"every_kangcell_icon",@"psych_kangcell_icon",@"archives_kangcell_icon"];
    [self initHealth360ViewPageLayout];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    if (@available(iOS 11.0, *))
    {
        [_myTableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)initHealth360ViewPageLayout
{
    if (_myTableView) {
        return;
    }
    WEAK_SELF(self);
    [self.view addSubview: self.myTableView];
    [_myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF(self);
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *))
    {
        [_myTableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        UILabel *textLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 120, OtherLabelWidth)];
//        textLabel.font = [UIFont fontWithName:AppFontHelvetica size: 15];
//        textLabel.textAlignment = NSTextAlignmentLeft;
//        textLabel.textColor = RGB(51, 51, 51);
//        textLabel.text = titleArray[indexPath.row];
//        [cell.contentView addSubview:textLabel];
        cell.textLabel.font = [UIFont fontWithName:AppFontHelvetica size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:AppFontHelvetica size:14];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    cell.textLabel.text = titleArray[indexPath.row];
    cell.detailTextLabel.text = detailArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed: imageArray[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            {
                HTMLViewController *healthDataVC = [[HTMLViewController alloc]init];
                healthDataVC.hidesBottomBarWhenPushed = YES;
                healthDataVC.webType = 0;
                [self.navigationController pushViewController:healthDataVC animated:YES];
            }
            break;
        case 1:
        {

            BATHealthThreeSecondsController *healthDataVC = [[BATHealthThreeSecondsController alloc]init];
            healthDataVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:healthDataVC animated:YES];
        }
            break;
        case 2:
        {
            UIStoryboard *sboard = [KMTools getStoryboardInstance];
            PsychTestViewController *psychTestViewController = [sboard instantiateViewControllerWithIdentifier:@"PsychTestViewController"];
            psychTestViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:psychTestViewController animated:YES];
        }
            break;
        case 3:
        {
            HTMLViewController *healthDataVC = [[HTMLViewController alloc]init];
            healthDataVC.hidesBottomBarWhenPushed = YES;
            healthDataVC.webType = 1;
            [self.navigationController pushViewController:healthDataVC animated:YES];
        }
            break;
            
        default:
            break;
    }

}

#pragma mark -
-(UITableView *)myTableView
{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight-kStatusAndNavHeight) style:UITableViewStyleGrouped];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.rowHeight = 80;
        _myTableView.showsHorizontalScrollIndicator = YES;
        //        _myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //        _myTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _myTableView;
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

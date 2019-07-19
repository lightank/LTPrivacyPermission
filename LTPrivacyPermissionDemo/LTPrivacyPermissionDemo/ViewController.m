//
//  ViewController.m
//  LTPrivacyPermissionDemo
//
//  Created by huanyu.li on 2018/9/7.
//  Copyright © 2018年 lightank. All rights reserved.
//

#import "ViewController.h"

#import "LTPrivacyPermission.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *titleArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
}
#pragma mark - UI
- (void)initUI
{
    _titleArray = @[
                    NSLocalizedString(@"Permission.Photo", nil),
                    NSLocalizedString(@"Permission.Camera", nil),
                    NSLocalizedString(@"Permission.Microphone", nil),
                    NSLocalizedString(@"Permission.LocationWhenInUse", nil),
                    NSLocalizedString(@"Permission.LocationAlways", nil),
                    NSLocalizedString(@"Permission.LocationAlwaysAndWhenInUse", nil),
                    NSLocalizedString(@"Permission.Contacts", nil),
                    NSLocalizedString(@"Permission.PushNotification", nil),
                    NSLocalizedString(@"Permission.AppleMusic", nil),
                    NSLocalizedString(@"Permission.Speech", nil),
                    NSLocalizedString(@"Permission.CalendarEvent", nil),
                    NSLocalizedString(@"Permission.Reminder", nil),
                    NSLocalizedString(@"Permission.Network", nil),
                    ];
    
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = YES;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
}

#pragma mark - <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const identifier = @"identifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.textLabel.textAlignment = 0;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12.f];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取权限
    LTPrivacyPermissionType type = indexPath.row;
    [LTPrivacyPermission.sharedPermission accessPrivacyPermissionWithType:type completion:^(BOOL authorized, LTPrivacyPermissionType type, LTPrivacyPermissionAuthorizationStatus status) {
        if (!authorized)
        {
            [LTPrivacyPermission showOpenApplicationSettingsAlertWithTitle:NSLocalizedString(@"Permission.ErrorTitle", nil) message:NSLocalizedString(@"Permission.ErrorTitleInfo", nil) cancelActionTitle:NSLocalizedString(@"Permission.ErrorCancel", nil) settingActionTitle:NSLocalizedString(@"Permission.ErrorOpenSetting", nil)];
        }
    }];
    
    // 检测权限
//    [LTPrivacyPermission.sharedPermission checkPrivacyPermissionWithType:indexPath.row completion:^(BOOL authorized, LTPrivacyPermissionType type, LTPrivacyPermissionAuthorizationStatus status) {
//        if (!authorized)
//        {
//            [LTPrivacyPermission showOpenApplicationSettingsAlertWithTitle:NSLocalizedString(@"Permission.ErrorTitle", nil) message:NSLocalizedString(@"Permission.ErrorTitleInfo", nil) cancelActionTitle:NSLocalizedString(@"Permission.ErrorCancel", nil) settingActionTitle:NSLocalizedString(@"Permission.ErrorOpenSetting", nil)];
//        }
//    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

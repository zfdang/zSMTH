//
//  ExtendedTableViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-13.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "ExtendedTableViewController.h"
#import "LeftMenuViewController.h"
// iOS 7 滑动返回那些事儿: http://weizhe.me/ios-7-back-gesture-sample/
#import "UINavigationController+MethodSwizzling.h"
#import "UIViewController+MethodSwizzling.h"


@interface ExtendedTableViewController () <UIGestureRecognizerDelegate>
{
    MBProgressHUD *progressBar;
    BOOL asyncTaskResult;
    NSDictionary *resultParams;
}
@end



@implementation ExtendedTableViewController

@synthesize progressTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    helper = [SMTHHelper sharedManager];
    setting = [ZSMTHSetting sharedManager];
    self.progressTitle = @"加载中...";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    当我们的返回按钮上需要显示不同的文字时，就不能使用 backIndicatorImage 了，
//    我们要自定义一个 UIButton 来生成 UIBarButtonItem，再设置 navigationBar
//    的 leftBarButtonItem。而如果设置了 leftBarButtonItem 的话，会使系统的滑
//    动返回失效。我们需要在 UIViewController 中加入这行代码
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)startAsyncTask:(NSMutableDictionary*) params
{
    [helper.smth reset_status];
    
    progressBar = [[MBProgressHUD alloc] initWithView:self.view];
    progressBar.mode = MBProgressHUDModeIndeterminate;
    progressBar.delegate = self;
    progressBar.labelText = self.progressTitle;
    
    [self.view addSubview:progressBar];
    [progressBar showWhileExecuting:@selector(asyncTask:) onTarget:self withObject:params animated:YES];
}


- (void)asyncTask:(NSMutableDictionary*) params
{
    NSLog(@"asyncTask");

    //得到词典中所有Value值
    NSEnumerator * enumeratorValue = [params objectEnumerator];
    
    //快速枚举遍历所有Value的值
    for (NSObject *object in enumeratorValue) {
        NSLog(@"遍历Value的值: %@",object);
    }
}

- (void)finishAsyncTask::(NSDictionary*) resultParams
{
    
}

#pragma mark MBProgressHUD Delegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    [self finishAsyncTask:resultParams];
}

#pragma mark virtual method for all child views to show left menu
- (IBAction)showLeftMenu:(id)sender {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    LeftMenuViewController *menuController = (LeftMenuViewController*)self.frostedViewController.menuViewController;
    [menuController refreshTableHeadView];
    [self.frostedViewController presentMenuViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// remove leading space of separator in tableview
// http://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working/25788003#25788003
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Private Method

- (BOOL)isRootViewController
{
    return (self == self.navigationController.viewControllers.firstObject);
}

#pragma mark - UIGestureRecognizerDelegate

//当在 UINavigationController 的 rootViewController 中做一个会触发滑动返回的操作后，
//再点击某个会 pushViewController 的按钮时， UINavigationController 没有任何反应，
//而如果使用 home键 返回主屏，再进入应用的话，会发现已经 push 进刚才应该进入的
//ViewController 了，这是因为在 UINavigationController 的 rootViewController
//中触发了滑动返回导致的，我们只要判断一下当前 ViewController 是否是 rootViewController,
//然后在 - gestureRecognizerShouldBegin: 中返回就可以了。
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self isRootViewController]) {
        return NO;
    } else {
        return YES;
    }
}

//虽然滑动返回恢复了，但是它却有点“残疾”，具体表现为两点：
//手指滑动的角度必须要几乎水平，而正常的效果可以接受差不多30度的偏差，这在实际使用
//过程中的体验差别是非常巨大的。
//如果 UIViewController 中是一个 UITableView 或者其他可滚动的 UIScrollView，
//那么在 UIScrollView 滚动的时候，是不能触发滑动返回的，而正常的效果是可以触发的。
//那么，我们该怎样解决这两个问题呢？
//
//我们差不多能猜到是因为手势冲突导致的，那我们就先让 ViewController 同时接受多
//个手势吧。加上代码：
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//运行试一试，两个问题同时解决，不过又发现了新问题，手指在滑动的时候，
//被 pop 的 ViewController 中的 UIScrollView 会跟着一起滚动，
//这个效果看起来就很怪（知乎日报现在就是这样的效果），而且也不是原始
//的滑动返回应有的效果，那么就让我们继续用代码来解决吧
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}


@end

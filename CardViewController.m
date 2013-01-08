//
//  CardViewController.m
//  AppJoin
//
//  Created by Mars on 13-1-6.
//  Copyright (c) 2013年 Mars. All rights reserved.
//

#import "CardViewController.h"
#import "MBProgressHUD.h"
#import "QRCodeGenerator.h"
#import <QuartzCore/QuartzCore.h>

@interface CardViewController ()

@end

@implementation CardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"个人名片";
        _cardArray = [[NSArray alloc] init];
        
        _cardArr = [[NSMutableArray alloc] initWithCapacity:0];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Card" ofType:@"plist"];
        ///获取项目的根路径
        NSDictionary *cardDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        _cardArray = [cardDictionary objectForKey:@"Card"];
    }
    return self;
}

///界面一出现时就从plist文件中获取数据
-(void)viewWillAppear:(BOOL)animated
{
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        self.cardArr = [dictionary objectForKey:@"UserInfo"];
        
        NSLog(@"%@",self.cardArr);
    }
}

-(NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    return [documentPath stringByAppendingFormat:@"card.plist"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cardTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT - 49 - 44) style:UITableViewStyleGrouped];
    _cardTableView.delegate   = self;
    _cardTableView.dataSource = self;
    _cardTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_cardTableView];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveCardByQrcode:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    [rightBtn release];
}

-(void)saveCardByQrcode:(id)sender
{
    CATransition *animation =[CATransition animation];
    animation.delegate = self;
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.type = @"cube";
    animation.subtype = @"fromRight";
    animation.removedOnCompletion = NO;
    
   _qrView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    
    _qrImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, WIDTH , HEIGHT - 20)];
    
    NSString *appStr = [[NSString alloc] init];
    
    ///获取名片的内容
    for (int i = 0; i < self.cardArr.count; i++) {
        
        ///采用字符串拼接的方法
        appStr = [appStr stringByAppendingFormat:@"%@ \n",[self.cardArr objectAtIndex:i]];
       
    }
    
    NSString *filePath = [self dataFilePath];
    NSMutableDictionary *dictinoary = [[NSMutableDictionary alloc] init];
    [dictinoary setObject:self.cardArr forKey:@"UserInfo"];
    [dictinoary writeToFile:filePath atomically:YES];
    
     _qrImage.image = [QRCodeGenerator qrImageForString:appStr imageSize:self.qrImage.bounds.size.width];
    
    ///保存图片到相册
    UIImageWriteToSavedPhotosAlbum(self.qrImage.image, self, @selector(image:didFinishSaving:andContextInfo:), nil);
    
    UILabel *qrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 50)];
    qrLabel.text = @"该图片为个人二维码名片";
    qrLabel.font = [UIFont systemFontOfSize:20.0f];
    qrLabel.textColor = [UIColor redColor];
    qrLabel.backgroundColor = [UIColor clearColor];
    qrLabel.textAlignment = NSTextAlignmentCenter;
    
    [_cardTableView removeFromSuperview];
    [_qrView addSubview:qrLabel];
    [_qrView addSubview:_qrImage];
    [self.view addSubview:_qrView];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(scanCard:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    [self.view.layer addAnimation:animation forKey:@"animation"];
    
    [rightBtn release];
    [qrLabel  release];

}

-(void)image:(UIImage *)image didFinishSaving:(NSError *)error andContextInfo:(void*)contextInfo
{
    if (error == nil) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDAnimationZoomIn;
        hud.delegate = self;
        hud.labelText = @"二维码已生成，并保存到相册";
        hud.margin = 10.0f;
        hud.yOffset = 180.0f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1];
    }
}

-(void)scanCard:(id)sender
{
    CATransition *animation =[CATransition animation];
    animation.delegate = self;
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.type = @"cube";
    animation.subtype = @"fromLeft";
    animation.removedOnCompletion = NO;
    
    ///要从界面上移除
    [_qrImage removeFromSuperview];
    
    ///返回到个人名片设置界面
    [self.view addSubview:_cardTableView];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveCardByQrcode:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    [rightBtn release];
    
    ///这个是动画必不可少的一步
    [self.view.layer addAnimation:animation forKey:@"animation"];
}

-(void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    hud = nil;
}

#pragma mark - UITableView Delegate And Datasoure Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cardArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifer = @"cellIndetifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifer];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indentifer] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(95, 11, 260, 30)];
        textField.delegate = self;
        textField.tag = indexPath.row;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.font = [UIFont systemFontOfSize:18.0f];
        textField.textColor = [UIColor grayColor];
        [cell.contentView addSubview:textField];
        
    }
    cell.textLabel.text = [_cardArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    if (textField.tag >= 3) {
       
        CGRect rect = CGRectMake(0, -140,WIDTH,HEIGHT);//上移80个单位，按实际情况设置
        self.view.frame = rect;
   }
    
    [UIView commitAnimations];

    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0, 0,WIDTH,HEIGHT);//上移80个单位，按实际情况设置
    
    self.view.frame = rect;
   [UIView commitAnimations];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.cardArr addObject:textField.text];
    return YES;
};

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    [_cardArr release];
    [_cardArray release];
    [_cardTableView release];
    [_qrImage release];
    [_qrView release];
    [super dealloc];
}

@end

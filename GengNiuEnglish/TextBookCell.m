//
//  TextBookCell.m
//  GengNiuEnglish
//
//  Created by luzegeng on 16/1/18.
//  Copyright © 2016年 luzegeng. All rights reserved.
//

#import "TextBookCell.h"


@implementation TextBookCell
{
    LyricViewController *lyricViewController;
    PracticeViewController *practiceViewController;
    ReaderViewController *readerViewController;
}
-(id)init
{
    if ((self = [super init])) {
        
    }
    return self;
}
-(void)setBook:(DataForCell *)book
{
    _book=book;
    if (!_book)
    {
        NSLog(@"your book is nil");
    }
    [self.cellImage sd_cancelCurrentImageLoad];
    [self.cellImage setImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    __weak __typeof__(self) weakSelf = self;
    //需要判断正在下载的图片跟当前要下载的图片是否相同
    [NetworkingManager downloadImage:[NSURL URLWithString:_book.cover_url] block:^(UIImage *image) {
        [weakSelf.cellImage setImage:image];
    }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openBook)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.cancelsTouchesInView=NO;
    [self.cellImage addGestureRecognizer:singleTap];
    [self.cellImage setUserInteractionEnabled:YES];
    
    IphoneType type=[CommonMethod checkIphoneType];
    switch (type) {
        case Iphone5s:
            self.labelTopConstraint.constant=110;
            self.xiuLianWidth.constant=40;
            self.moErDuoWidth.constant=40;
            self.chuangGuanWidth.constant=40;
            self.moErDuo.titleLabel.font=[UIFont italicSystemFontOfSize:11.0f];
            self.xiuLian.titleLabel.font=[UIFont italicSystemFontOfSize:12.0f];
            self.chuangGuan.titleLabel.font=[UIFont italicSystemFontOfSize:12.0f];
            break;
        case Iphone6:
            self.labelTopConstraint.constant=120;
            break;
        case Iphone6p:
            self.labelTopConstraint.constant=140;
            self.xiuLianLeftConstraint.constant=8;
            self.chuangGuanRightConstraint.constant=8;
            break;
        default:
            break;
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}
-(void)dismissView
{
    lyricViewController=nil;
}
- (IBAction)xiulianClick:(id)sender {
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
        [self.delegate clickCellButton:self.index];
        return;
    }
    [self openBook];
}
- (IBAction)moErDuoClick:(id)sender {
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
        [self.delegate clickCellButton:self.index];
        return;
    }
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    lyricViewController=[storyboard instantiateViewControllerWithIdentifier:@"LyricViewController"];
    [lyricViewController initWithBook:self.book];
    lyricViewController.delegate=self;
    lyricViewController.imageURL=self.book.cover_url;
    UINavigationController *navigationController=(UINavigationController*)self.window.rootViewController;
    [navigationController pushViewController:lyricViewController animated:YES];
}
- (IBAction)chuangGuanClick:(id)sender {
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
        [self.delegate clickCellButton:self.index];
        return;
    }
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    practiceViewController=[storyboard instantiateViewControllerWithIdentifier:@"PracticeViewController"];
    [practiceViewController initWithBook:self.book];
    practiceViewController.delegate=self;
    UINavigationController *navigationController=(UINavigationController*)self.window.rootViewController;
    [navigationController pushViewController:practiceViewController animated:YES];
}
-(void)openBook
{
    if (![self.book checkDatabase])
    {
        NSLog(@"the book is nil");
        [self.delegate clickCellButton:self.index];
        return;
    }
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isReaderView=true;
    UIViewController *currentVC=[CommonMethod getCurrentVC];
    NSString *doctName=[self.book getFileName:FTDocument];
    NSString *pdfName=[self.book getFileName:FTPDF];
    NSString *pdfPath=[[self.book getDocumentPath] stringByAppendingPathComponent:pdfName];
    ReaderDocument *document=[ReaderDocument withDocumentFilePath:pdfPath password:nil];
    if (doctName!=nil)
    {
        readerViewController=[[ReaderViewController alloc]initWithReaderDocument:document];
        readerViewController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle=UIModalPresentationFullScreen;
        readerViewController.delegate=self;
        [currentVC presentViewController:readerViewController animated:YES
                              completion:nil];
    }
}
-(void)dismissReaderViewController:(ReaderViewController *)viewController
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.isReaderView=false;
    [[CommonMethod getCurrentVC] dismissViewControllerAnimated:NO completion:NULL];
    readerViewController=nil;
}
@end

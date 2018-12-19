//
//  SearchViewController.m
//  BigImageSearch
//
//  Created by chenchao on 2018/7/23.
//  Copyright © 2018年 g.10086.cn. All rights reserved.
//

#import "SearchViewController.h"
#import <Automator/Automator.h>
#import "RSTLCopyOperation.h"
#import "FileObject.h"

@interface SearchViewController ()<NSTableViewDelegate,NSTableViewDataSource,RSTLCopyOperationDelegate>
@property (weak) IBOutlet NSTextField *pathLabel;
@property (weak) IBOutlet NSButton *jpgRadio;
@property (weak) IBOutlet NSButton *pngRadio;
@property (weak) IBOutlet NSButton *gifRadio;
@property (weak) IBOutlet NSButton *mp4Radio;
@property (weak) IBOutlet NSButton *otherRadio;
@property (weak) IBOutlet NSTextField *fileNumberLabel;

@property (weak) IBOutlet NSTextField *fileLimmitTextField;

@property (nonatomic, assign)BOOL shouldJpg;
@property (nonatomic, assign)BOOL shouldPng;
@property (nonatomic, assign)BOOL shouldGif;
@property (nonatomic, assign)BOOL shouldMp4;
@property (nonatomic, assign)BOOL shouldOthers;

@property (nonatomic, assign)BOOL copyCount;


@property (nonatomic, assign)CGFloat fileLimmitValue;

@property (nonatomic, strong)NSMutableArray * resultArr;
@property (weak) IBOutlet NSTableColumn *nameCol;
@property (weak) IBOutlet NSTableColumn *sizeCol;
@property (weak) IBOutlet NSTableColumn *pathCol;

@property (weak) IBOutlet NSTableView *resultTableView;
@property (weak) IBOutlet NSTextField *imageExportPathLabel;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    _jpgRadio.state = NSControlStateValueOn;
    _shouldJpg = YES;
    
    _pngRadio.state = NSControlStateValueOn;
    _shouldPng = YES;
    
    _resultArr = [[NSMutableArray alloc]init];
    
    self.resultTableView.delegate =  self;
    self.resultTableView.dataSource = self;
    
}
- (IBAction)selectedDirectory:(id)sender {
    
    NSInteger tag = [(NSView *)sender tag];
    NSOpenPanel *pannel = [NSOpenPanel openPanel];
    typeof(self) weakSelf = self;
    
    pannel.canCreateDirectories = YES;
    pannel.canChooseDirectories = YES;
    pannel.canChooseFiles = NO;
    [pannel setAllowsMultipleSelection:NO];
    
    [pannel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSString *pathString = [[pannel.URLs firstObject] path];
            NSLog(@"选择路径......%@",pathString);
            if (tag == 0) {
                weakSelf.pathLabel.stringValue = pathString;
            }
            
            if (tag == 1) {
                weakSelf.imageExportPathLabel.stringValue = pathString;
            }
        }
    }];
}

- (IBAction)jpgAction:(id)sender {
    _shouldJpg = !_shouldJpg;
    _jpgRadio.state  = _shouldJpg ? NSControlStateValueOn : NSControlStateValueOff;
}
- (IBAction)pngAction:(id)sender {
    _shouldPng = !_shouldPng;
    _pngRadio.state  = _shouldPng ? NSControlStateValueOn : NSControlStateValueOff;
}
- (IBAction)gifAction:(id)sender {
    _shouldGif = !_shouldGif;
    _gifRadio.state  = _shouldGif ? NSControlStateValueOn : NSControlStateValueOff;
    
}
- (IBAction)mp4Action:(id)sender {
    _shouldMp4 = !_shouldMp4;
    _mp4Radio.state  = _shouldMp4 ? NSControlStateValueOn : NSControlStateValueOff;
}
- (IBAction)otherAction:(id)sender {
    _shouldOthers = !_shouldOthers;
    _otherRadio.state  = _shouldOthers ? NSControlStateValueOn : NSControlStateValueOff;
}


- (IBAction)searchAction:(id)sender {
    NSString * searchPath = self.pathLabel.stringValue;
    _fileLimmitValue = [self.fileLimmitTextField.stringValue floatValue];
    [_resultArr removeAllObjects];
    [self.resultTableView reloadData];
    [self findAllFileWithPath:searchPath];
}

-(void)judgeFileContent:(NSString *)filePath{
    NSFileManager *file  = [NSFileManager defaultManager];
    NSDictionary *dict = [file attributesOfItemAtPath:filePath error:nil];
    unsigned long long size = [dict fileSize];
    
    float kbSize =size/1000.f;
    if (kbSize > self.fileLimmitValue) {
        
        NSLog(@"filePath :: %@ ",filePath);
        NSLog(@"fileSize::%.2f KB",size/1000.f);
        
        FileObject *fileObj = [[FileObject alloc]init];
        fileObj.filePath = filePath;
        fileObj.fileName = [filePath lastPathComponent];
        fileObj.fileSize = kbSize;
        [_resultArr addObject:fileObj];
        
        [_resultTableView reloadData];
        
        _fileNumberLabel.stringValue = [NSString stringWithFormat:@" %li 个文件",_resultArr.count];
    }
    
}

-(void)findAllFileWithPath:(NSString *)filePath{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArr = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
            NSString *subPath = nil;
            for (NSString * str in dirArr) {
                subPath = [filePath stringByAppendingPathComponent:str];
                BOOL isSubDir = NO;
                [fileManager fileExistsAtPath:subPath isDirectory:&isSubDir];
                [self findAllFileWithPath:subPath];
            }
        }else{
            if ([self isSearchFileWithFilePath:filePath]) {//符合需要寻找的文件类型
                [self judgeFileContent:filePath];
            }
        }
    }else{
        NSLog(@"this path is not exist!");
    }
}

-(BOOL)isSearchFileWithFilePath:(NSString *)filePath{
    NSMutableArray *extensions = [[NSMutableArray alloc]init];
    NSMutableArray *unExtensions = [[NSMutableArray alloc]init];
    NSString * extension = [filePath pathExtension];
    if (_shouldJpg) {
        [extensions addObject:@"jpg"];
        [extensions addObject:@"jpeg"];
    }else{
        [unExtensions addObject:@"jpg"];
        [unExtensions addObject:@"jpeg"];
    }
    if (_shouldPng) {
        [extensions addObject:@"png"];
    }else{
        [unExtensions addObject:@"png"];
    }
    if (_shouldGif) {
        [extensions addObject:@"gif"];
    }else{
        [unExtensions addObject:@"gif"];
    }
    if (_shouldMp4) {
        [extensions addObject:@"mp4"];
    }else{
        [unExtensions addObject:@"png"];
    }
    
    if ([extensions containsObject:extension]) {
        return YES;
    }
    
    if (_shouldOthers) {
        if (![unExtensions containsObject:extension]) {
            return YES;
        }
    }
    return NO;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _resultArr.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    FileObject *fileObject = _resultArr[row];
    if (tableColumn == _nameCol) {
        return fileObject.fileName;
    }
    
    if (tableColumn == _sizeCol) {
        return [NSString stringWithFormat:@"%.2f KB", fileObject.fileSize];
    }
    
    return fileObject.filePath;

}
- (IBAction)exportAction:(id)sender {
    _copyCount = 3;
    [self copyFileInArr:_resultArr];
}

-(void)copyFileInArr:(NSArray *)dataArr{
    NSString *destination = self.imageExportPathLabel.stringValue;
    NSMutableArray *failArr = [[NSMutableArray alloc]init];
    if (dataArr.count > 0) {
        for (FileObject * fileObject in dataArr) {
            RSTLCopyOperation *copyOperation = [[RSTLCopyOperation alloc] initWithFromPath:fileObject.filePath   toPath:[[destination stringByAppendingString:@"/"] stringByAppendingString:fileObject.fileName]];
            copyOperation.delegate = self;
            NSOperationQueue *queue = [NSOperationQueue new];
            [queue addOperation:copyOperation];
            [queue waitUntilAllOperationsAreFinished];
            RSTLCopyState isCopy = copyOperation.state;
            if (isCopy == RSTLCopyFinished) {
                NSLog(@"拷贝成功");
            } else if(isCopy == RSTLCopyFailed) {
                NSLog(@"拷贝失败");
                [failArr addObject:fileObject];
            }
        }
        if (failArr.count > 0) {
            if (_copyCount > 0) {
                _copyCount = _copyCount-1;
                [self copyFileInArr:failArr];
            }else{
                NSLog(@" %li 个文件copy失败",failArr.count);
            }
        }
    }else{
        NSLog(@"拷贝完成");
    }
}


@end

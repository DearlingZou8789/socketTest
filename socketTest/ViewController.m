//
//  ViewController.m
//  socketTest
//
//  Created by Damon on 15/10/28.
//  Copyright © 2015年 zhangle.in.iMac. All rights reserved.
//

#import "ViewController.h"
#import "GlobalInfo.h"
#import "CocoaAsyncSocket.h"
#import "GZIP.h"
#import "NSString+RandomString.h"
#import "NSData+Base64.h"
#import "NSData+Encrypt.h"
#import "NSString+Encrypt.h"
#import "NSString+Base64.h"
#import "DESUtils.h"
#import "Encode.h"


@interface ViewController ()<AsyncSocketDelegate, UITextFieldDelegate>
{
    __weak IBOutlet UITextField *ipTf;
    __weak IBOutlet UITextField *portTf;
    __weak IBOutlet UITextView *textView;
    __weak IBOutlet UITextField *userTf;
    __weak IBOutlet UITextField *passTf;
    __weak IBOutlet UITextField *countTf;
    NSString *ipStr;
    NSString *portStr;
    AsyncSocket *socket;
    BOOL isChangeValue;
    NSMutableData *mutableData;
    NSData *item;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([GlobalInfo getUserDefaults:@"ip"])
    {
        ipTf.text = [GlobalInfo getUserDefaults:@"ip"];
    }
    if ([GlobalInfo getUserDefaults:@"port"])
    {
        portTf.text = [GlobalInfo getUserDefaults:@"port"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"str = %@", [NSString randomStringWithLength:8]);
    mutableData = [NSMutableData data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:ipTf])
    {
        [ipTf resignFirstResponder];
        [portTf becomeFirstResponder];
    }
    else if([textField isEqual:portTf])
    {
        [portTf resignFirstResponder];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectAction:nil];
        });
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:ipTf])
    {
        if (!ipStr)
        {
            ipStr = ipTf.text;
        }
    }
    else if([textField isEqual:portTf])
    {
        if (!portStr)
        {
            portStr = portTf.text;
        }
    }
}

- (BOOL)isRightString:(UITextField *)tf alertString:(NSString *)str
{
    BOOL flag = YES;
    if ([tf.text isEqualToString:@""])
    {
        [GlobalInfo alertViewShow:str delegate:nil];
        flag = NO;
    }
    return flag;
}

- (IBAction)connectAction:(UIButton *)sender {
    if (![self isRightString:ipTf alertString:@"请输入IP地址"] || ![self isRightString:portTf alertString:@"请输入端口号"] || ![self isRightString:userTf alertString:@"请输入用户名"] || ![self isRightString:passTf alertString:@"请输入密码"])
    {
        return;
    }
    if ((ipStr && [ipStr isEqualToString:ipTf.text]) || (portStr && [portStr isEqualToString:portTf.text]))
    {
        isChangeValue = NO;
    }
    else
    {
        isChangeValue = YES;
        ipStr = ipTf.text;
        portStr = portTf.text;
    }
    [self connetToAsyncSocket];
}

- (void)connetToAsyncSocket
{
    if (!isChangeValue && [socket isConnected])
    {
        [GlobalInfo alertViewShow:@"已经连接服务器端口" delegate:nil];
        return;
    }
    textView.text = @"";
    socket = [[AsyncSocket alloc] initWithDelegate:self];
    mutableData.length = 0;
    NSError *error = nil;
    [socket connectToHost:ipTf.text onPort:[portTf.text intValue]  error:&error];
    if (error)
    {
        NSLog(@"error = %@", error);
        textView.text = [textView.text stringByAppendingString:error.localizedDescription];
    }
    [GlobalInfo setUserDefaults:ipStr name:@"ip"];
    [GlobalInfo setUserDefaults:portStr name:@"port"];
    [socket readDataWithTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSString *remoteAddress = [NSString stringWithFormat:@"host = %@, port = %d", host, port];
    NSString *localAddress = [NSString stringWithFormat:@"localhost = %@, port = %d", sock.localHost, sock.localPort];
    textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"%@\n%@\n", remoteAddress, localAddress]];
    if (port == 30753)
    {
        [self loginTest];
    }
    else if(port == 30743)
    {
        [self getHistory];
    }
    item = [NSData dataWithBytes:"\x00\x00" length:2];
    [sock readDataToData:item withTimeout:-1 tag:1000];
}

//登录验证
- (void)loginTest
{
    NSUInteger algthome = 1;
    //发送字符串给服务器进行通讯交互,3145
    NSString *userName = userTf.text;                       //userName
    NSString *password = passTf.text;                       //password
    NSString *companyName = @"上海涨乐互联网科技有限公司";      //account
    NSString *userEnabled = @"1";                        //enabled
    //    NSString *token = [NSString randomStringWithLength:32]; //token
    NSString *token = @"abcdewojeroijewoqjriejw";
    //传入参数
    NSString *userArgument = [NSString stringWithFormat:@"action=validate|userName=%@|password=%@|token=%@|account=%@|enabled=%@", userName, password, token, companyName, userEnabled];
    NSLog(@"原始数据 = %@", userArgument);
    //最终上传的字符串
    NSString *lastPostData = nil;
    //DES Key
    NSString *desKey = [NSString randomStringWithLength:8];
    NSData *desData = [desKey dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"desData.length = %ld", desData.length);
    if (algthome == 1)
    {
        //DES加密后的参数
        userArgument = [userArgument DESEnCodeCrptionWithKey:desKey];
        NSLog(@"DES/AES加密后的数据 = %@", userArgument);
        //拼装最后的参数,打空格时不需要使用全角中文
        lastPostData = [NSString stringWithFormat:@"client %@$%@\r\n", desKey, userArgument];
        //    lastPostData = [lastPostData stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        //    lastPostData = [lastPostData stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    }
    else if(algthome == 2)
    {
        //转换成64位字符串
        //3DES加密
        userArgument = [userArgument decryptedWith3DESUsingKey:desKey andIV:[iv dataUsingEncoding:NSUTF8StringEncoding]];
        //AES加密后的参数
        //    userArgument = [userArgument encryptedWithAESUsingKey:desKey andIV:[userArgument dataUsingEncoding:NSASCIIStringEncoding]];
        //瓶装最后的参数
        lastPostData = [NSString stringWithFormat:@"client %@$%@\r\n", desKey, userArgument];
    }
    else if(algthome == 3)
    {
        userArgument = [DESUtils encryptUseDES:userArgument key:desKey];
        lastPostData = [NSString stringWithFormat:@"client %@$%@\r\n", desKey, userArgument];
    }
    NSData *data = [lastPostData dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"desKey = %@,\n lastPostData = %@", desKey, lastPostData);
    [socket writeData:data withTimeout:100 tag:1];
    //后台进行解压
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self afterDecode:data decodeKey:desKey type:algthome];
    });
}

- (void)getHistory
{
    //商品代码
    NSString *goodCode = @"COPPER";
    //行情列表的类型
    NSString *interval = @"M1";
    //数据条数
    NSString *count = countTf.text;
    //DES Key
    NSString *desKey = [NSString randomStringWithLength:8];
    NSString *userArgument = [NSString stringWithFormat:@"action=gethistory|code=%@|interval=%@|count=%@", goodCode, interval, count];
    //DES加密
    userArgument = [userArgument DESEnCodeCrptionWithKey:desKey];
    //请求发送的数据
    NSString *postData = [NSString stringWithFormat:@"client %@$%@\r\n", desKey, userArgument];
    NSLog(@"postData = %@\ndesKey = %@", postData, desKey);
    NSData *data = [postData dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:data withTimeout:100 tag:-1];
}

- (void)afterDecode:(NSData *)dataStr decodeKey:(NSString *)key type:(NSUInteger)type
{
    NSString *encodeAllStr = [[NSString alloc] initWithData:dataStr encoding:NSUTF8StringEncoding];
    NSString *encodeStr = [[encodeAllStr componentsSeparatedByString:@"$"] lastObject];
    NSString *decodeStr = nil;
    if(type == 1)
    {
        decodeStr = [encodeStr DESDeCodeCrptionWithKey:key];
    }else if (type == 2)
    {
        decodeStr = [encodeStr encryptedWith3DESUsingKey:key andIV:[iv dataUsingEncoding:NSUTF8StringEncoding]];
        decodeStr = [decodeStr base64DecodedString];
    }
    else if (type == 3)
    {
        decodeStr = [DESUtils decryptUseDES:encodeStr key:key];
    }
    NSLog(@"解密后 = %@", decodeStr);
}

- (void)decodeString:(NSString *)str key:(NSString *)key
{
    NSLog(@"直接调用解密后的数据 = %@", [DESUtils decryptUseDES:str key:key]);
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1)
    {
        NSLog(@"sock = %@", sock.description);
    }
}

//socket连接不成功时,需要切换ip地址
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    if (err)
    {
        NSString *errorStr = [err localizedFailureReason];
        textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"错误连接信息:%@", errorStr]];
    }
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"%@", sock.debugDescription);
    textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"连接断开"]];
}


- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"分段读取:%ld, tag = %ld", partialLength, tag]];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //取到最后两个字节，跟item是否一致
    NSData *lastTwoData = [data subdataWithRange:NSMakeRange(data.length - 2, 2)];
    [mutableData appendData:data];
    if (![lastTwoData isEqualToData:item])
    {
        //当最后两个字节不一样时，判断最后一个字节是否为\x00，如果是就说明到头了
        NSData *compareZeroData = [NSData dataWithBytes:"\x00" length:1];
        NSData *lastData = [data subdataWithRange:NSMakeRange(data.length - 1, 1)];
        if (![lastData isEqualToData:compareZeroData])
        {
            return;
        }
    }
    //调用gzip库进行解压
    NSData *uncompressData = [mutableData gunzippedData];
    NSLog(@"解压前bytes=%p,length=%ld,解压后bytes=%p,length=%ld",data.bytes, data.length, uncompressData.bytes, uncompressData.length);
    NSString *str = [[NSString alloc] initWithData:uncompressData encoding:NSUTF8StringEncoding];
    NSString *typeStr = [[str componentsSeparatedByString:@":"] firstObject];
    if ([typeStr isEqualToString:@"Intime"])
    {
        textView.text = [textView.text stringByAppendingString:@"实时数据:"];
    }
    else if([typeStr isEqualToString:@"History"])
    {
        textView.text = [textView.text stringByAppendingString:@"历史数据:"];
    }
    textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"\n\ndata = %@\n", str]];
    //跳转到最新的数据
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length - str.length, str.length)];
    if (sock.connectedPort == 30743)
    {
//        if ([lastData isEqualToData:item])
//        {
            [sock disconnectAfterReadingAndWriting];
//        }
    }
    else if(sock.connectedPort == 30753)
    {
        [sock readDataWithTimeout:-1 tag:100];
    }
}

- (IBAction)closeAction:(UIButton *)sender {
    [socket disconnect];
    [socket disconnectAfterReadingAndWriting];
}



@end

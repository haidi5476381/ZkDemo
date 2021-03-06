//
//  ImageAveragingAlgorithmVC.m
//  ZkDemo
//
//  Created by kui on 2020/10/9.
//

#import "ImageAveragingAlgorithmVC.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface ImageAveragingAlgorithmVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation ImageAveragingAlgorithmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"图像平均算法";
    
}
  
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
   CGImageRef cgimage = [[UIImage imageNamed:@"SamplePictureZK0"] CGImage];

   size_t width = CGImageGetWidth(cgimage); // 图片宽度

   size_t height = CGImageGetHeight(cgimage); // 图片高度

   unsigned char *data = calloc(width * height * 4, sizeof(unsigned char)); // 取图片首地址

   size_t bitsPerComponent = 8; // r g b a 每个component bits数目

   size_t bytesPerRow = width * 4; // 一张图片每行字节数目 (每个像素点包含r g b a 四个字节)

   CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB(); // 创建rgb颜色空间

   CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

   CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);

   NSMutableArray <NSData *>*dataArr = [NSMutableArray array];
   
   for (int i = 1; i <= 10; i++) {
       
//        UIImage *mg = [UIImage imageNamed:[NSString stringWithFormat:@"SamplePictureZK%d",i]];
       UIImage *mg = [UIImage imageNamed:[NSString stringWithFormat:@"SamplePicture%d",i]];
       
       if (mg) {
           const char *bytes = [self getImgPixelMatrixWithImage:mg];
           [dataArr addObject:[NSData dataWithBytes:bytes length:strlen(bytes)]];
       }
       
       NSLog(@"i=%d",i);
        
   }
   
   unsigned char *imgPixel = calloc(width * height * 4, sizeof(unsigned char)); // 取图片首地址
   
   for (size_t i = 0; i < height; i++)  {

       for (size_t j = 0; j < width; j++) {

           size_t row = i * width * 4;

           size_t pixelIndex = row + (j * 4);

           int red = 0,green = 0,blue = 0,alpha = 0;

           for (size_t k = 0; k < dataArr.count; k++) {

               unsigned const char *bytes = [dataArr[k] bytes];

               alpha += bytes[pixelIndex];
               red += bytes[pixelIndex + 1];
               green += bytes[pixelIndex + 2];
               blue += bytes[pixelIndex + 3];
           }

           int a = alpha / dataArr.count;
           int r = red / dataArr.count;
           int g = green / dataArr.count;
           int b = blue / dataArr.count;

           // 赋值rgb通道
           imgPixel[pixelIndex+ 0] = a;
           imgPixel[pixelIndex + 1] = r;
           imgPixel[pixelIndex + 2] = g;
           imgPixel[pixelIndex + 3] = b;
       }
   }
 
//    cgimage = CGBitmapContextCreateImage(context);
//
//    UIImage *img = [UIImage imageWithCGImage:cgimage];

   //输出图片
  CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, imgPixel, bytesPerRow * height, ProviderReleaseData);
  CGImageRef imageRef = CGImageCreate(width, height, 8, 32, bytesPerRow, space,
                                      kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                      NULL, true, kCGRenderingIntentDefault);

  CGDataProviderRelease(dataProvider);
   UIImage *img = [UIImage imageWithCGImage:imageRef];
   //保存图片
   if (img) {
       [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
           
           PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:img];
        
       } completionHandler:^(BOOL success, NSError * _Nullable error) {
           NSLog(@"success = %d, error = %@", success, error);
       }];
   }
   NSLog(@"清理空间");
  // end：清理空间
  CGImageRelease(imageRef);
  CGContextRelease(context);
  CGColorSpaceRelease(space);

   UIImageView *imgView = [[UIImageView alloc]initWithImage:img];
   imgView.frame = self.view.bounds;
   [self.view insertSubview:imgView atIndex:0];
}
  
- (char *)getImgPixelMatrixWithImage:(UIImage*)image {
    
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t    bytesPerRow = imageWidth * 4;
    
    char *rgbImageBuf = calloc(imageWidth * imageHeight * 4, sizeof(unsigned char)); // 取图片首地址
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    /**
     data 指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
     bitsPerComponent 内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
     bitmap的每一行在内存所占的比特数
     CGColorSpaceRef上下文使用的颜色空间。
     指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
     */
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
     
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
   
    return rgbImageBuf;
}

//** 颜色变化 */
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

#pragma mark --打印相册路径
- (IBAction)clickBtn:(UIButton *)sender {
    
    NSLog(@"根据自己路径拼接:/Users/kui/Library/Developer/CoreSimulator/Devices/2DF8E272-96C6-4EB7-AE27-7D212EBC2279/data/Media/DCIM");
}
 
 
@end

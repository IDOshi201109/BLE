/*!
 *  \author         Ole A. Torvmark <o.a.torvmark@ti.com , torvmark@stalliance.no>
 *  \brief          SensorTag Movement Service for SensorTag2-Example iOS application
 *  \copyright      Copyright (c) 2015 Texas Instruments Incorporated
 *  \file           sensorTagMovementService.m
 */

/*
 * Copyright (c) 2015 Texas Instruments Incorporated
 *
 * All rights reserved not granted herein.
 * Limited License.
 *
 * Texas Instruments Incorporated grants a world-wide, royalty-free,
 * non-exclusive license under copyrights and patents it now or hereafter
 * owns or controls to make, have made, use, import, offer to sell and sell ("Utilize")
 * this software subject to the terms herein.  With respect to the foregoing patent
 *license, such license is granted  solely to the extent that any such patent is necessary
 * to Utilize the software alone.  The patent license shall not apply to any combinations which
 * include this software, other than combinations with devices manufactured by or for TI (“TI Devices”).
 * No hardware patent is licensed hereunder.
 *
 * Redistributions must preserve existing copyright notices and reproduce this license (including the
 * above copyright notice and the disclaimer and (if applicable) source code license limitations below)
 * in the documentation and/or other materials provided with the distribution
 *
 * Redistribution and use in binary form, without modification, are permitted provided that the following
 * conditions are met:
 *
 *   * No reverse engineering, decompilation, or disassembly of this software is permitted with respect to any
 *     software provided in binary form.
 *   * any redistribution and use are licensed by TI for use only with TI Devices.
 *   * Nothing shall obligate TI to provide you with source code for the software licensed and provided to you in object code.
 *
 * If software source code is provided to you, modification and redistribution of the source code are permitted
 * provided that the following conditions are met:
 *
 *   * any redistribution and use of the source code, including any resulting derivative works, are licensed by
 *     TI for use only with TI Devices.
 *   * any redistribution and use of any object code compiled from the source code and any resulting derivative
 *     works, are licensed by TI for use only with TI Devices.
 *
 * Neither the name of Texas Instruments Incorporated nor the names of its suppliers may be used to endorse or
 * promote products derived from this software without specific prior written permission.
 *
 * DISCLAIMER.
 *
 * THIS SOFTWARE IS PROVIDED BY TI AND TI’S LICENSORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
 * BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL TI AND TI’S LICENSORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
#import "sensorTagMovementService.h"
#import "sensorFunctions.h"
#import "masterUUIDList.h"
#import "masterMQTTResourceList.h"

@implementation sensorTagMovementService

+(BOOL) isCorrectService:(CBService *)service {
    if ([service.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_MOVEMENT_SERVICE]) {
        return YES;
    }
    return NO;
}


-(instancetype) initWithService:(CBService *)service {
    self = [super initWithService:service];
    if (self) {
        self.btHandle = [bluetoothHandler sharedInstance];
        self.service = service;
        
        for (CBCharacteristic *c in service.characteristics) {
            if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_MOVEMENT_CONFIG]) {
                self.config = c;
            }
            else if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_MOVEMENT_DATA]) {
                self.data = c;
            }
            else if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_MOVEMENT_PERIOD]) {
                self.period = c;
            }
        }
        if (!(self.config && self.data && self.period)) {
            NSLog(@"Some characteristics are missing from this service, might not work correctly !");
        }
        
        self.tile.origin = CGPointMake(0, 5);
        self.tile.size = CGSizeMake(8, 2);
        self.tile.title.text = @"Movement (MPU-9250)";
        ((oneValueCell *)(self.tile)).value.numberOfLines = 3;
        ((oneValueCell *)(self.tile)).value.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}



-(BOOL) configureService {
    [super configureService];
    if (self.period) {
        [self.btHandle writeValue:[sensorFunctions dataForPeriod:100] toCharacteristic:self.period];
    }
    return YES;
}

-(BOOL) dataUpdate:(CBCharacteristic *)c {
    if ([self.data isEqual:c]) {
        NSLog(@"SXW______sensorTagMovementService: Recieved value : %@",c.value);
        oneValueCell *tile = (oneValueCell *)self.tile;
        tile.value.text = [NSString stringWithFormat:@"%@",[self calcValue:c.value]];
        return YES;
    }
    return NO;
}
#pragma mark 角速度、重力加速度等的赋值
-(NSArray *) getCloudData {
    NSArray *ar = [[NSArray alloc]initWithObjects:
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    //Value 1
                    [NSString stringWithFormat:@"%0.1f",self.acc.x],@"value",
                    //Name 1
                    MQTT_RESOURCE_NAME_ACCELERATION_X,@"name", nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    //Value 1
                    [NSString stringWithFormat:@"%0.1f",self.acc.y],@"value",
                    //Name 1
                    MQTT_RESOURCE_NAME_ACCELERATION_Y,@"name", nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    //Value 1
                    [NSString stringWithFormat:@"%0.1f",self.acc.z],@"value",
                    //Name 1
                    MQTT_RESOURCE_NAME_ACCELERATION_Z,@"name", nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    //Value 1
                    [NSString stringWithFormat:@"%0.1f",self.mag.x],@"value",
                    //Name 1
                    MQTT_RESOURCE_NAME_MAGNETOMETER_X,@"name", nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    //Value 1
                    [NSString stringWithFormat:@"%0.1f",self.mag.y],@"value",
                    //Name 1
                    MQTT_RESOURCE_NAME_MAGNETOMETER_Y,@"name", nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    //Value 1
                    [NSString stringWithFormat:@"%0.1f",self.mag.z],@"value",
                    //Name 1
                    MQTT_RESOURCE_NAME_MAGNETOMETER_Z,@"name", nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    //Value 1
                    [NSString stringWithFormat:@"%0.1f",self.gyro.x],@"value",
                    //Name 1
                    MQTT_RESOURCE_NAME_GYRO_X,@"name", nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    //Value 1
                    [NSString stringWithFormat:@"%0.1f",self.gyro.y],@"value",
                    //Name 1
                    MQTT_RESOURCE_NAME_GYRO_Y,@"name", nil],
                   [NSDictionary dictionaryWithObjectsAndKeys:
                    //Value 1
                    [NSString stringWithFormat:@"%0.1f",self.gyro.z],@"value",
                    //Name 1
                    MQTT_RESOURCE_NAME_GYRO_Z,@"name", nil],nil];
    return ar;
}

#pragma mark -拼接展示数据
-(NSString *) calcValue:(NSData *) value {
    
    char vals[value.length];
    [value getBytes:vals length:value.length];
    
    Point3D gyroPoint;

    gyroPoint.x = ((float)((int16_t)((vals[0] & 0xff) | (((int16_t)vals[1] << 8) & 0xff00)))/ (float) 32768) * 255 * 1;
    gyroPoint.y = ((float)((int16_t)((vals[2] & 0xff) | (((int16_t)vals[3] << 8) & 0xff00)))/ (float) 32768) * 255 * 1;
    gyroPoint.z = ((float)((int16_t)((vals[4] & 0xff) | (((int16_t)vals[5] << 8) & 0xff00)))/ (float) 32768) * 255 * 1;
    
    self.gyro = gyroPoint;
    
    Point3D accPoint;
    
    accPoint.x = (((float)((int16_t)((vals[6] & 0xff) | (((int16_t)vals[7] << 8) & 0xff00)))/ (float) 32768) * 8) * 1;
    accPoint.y = (((float)((int16_t)((vals[8] & 0xff) | (((int16_t)vals[9] << 8) & 0xff00))) / (float) 32768) * 8) * 1;
    accPoint.z = (((float)((int16_t)((vals[10] & 0xff) | (((int16_t)vals[11] << 8) & 0xff00)))/ (float) 32768) * 8) * 1;
    
    self.acc = accPoint;
    
    Point3D magPoint;
    magPoint.x = (((float)((int16_t)((vals[12] & 0xff) | (((int16_t)vals[13] << 8) & 0xff00))) / (float) 32768) * 4912);
    magPoint.y = (((float)((int16_t)((vals[14] & 0xff) | (((int16_t)vals[15] << 8) & 0xff00))) / (float) 32768) * 4912);
    magPoint.z = (((float)((int16_t)((vals[16] & 0xff) | (((int16_t)vals[17] << 8) & 0xff00))) / (float) 32768) * 4912);
    
    
    self.mag = magPoint;
    
    //获取当前时间 拼接文件存储名字
    NSDate * dateOfToday = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:dateOfToday];
    int year = [dateComponent year];
    int month = [dateComponent month];
    int day = [dateComponent day];
    NSString * stringOfToday = [NSString stringWithFormat:@"%d%02d%02d.txt",year,month,day];
    //拼接存储数据  当独一条字符串信息拼接。如2，3，4，5，6，7
    NSString * stringOfData = [NSString stringWithFormat:@"%.1f,%.1f,%.1f,%.1f,%.1f,%.1f，%02d:%02d:%02d\n",self.acc.x,self.acc.y,self.acc.z,self.gyro.x,self.gyro.y,self.gyro.z,[dateComponent hour],[dateComponent minute],[dateComponent second]];
    
    //调用方法存入本地

    [self saveToDocumentWithData:stringOfData NamedTo:stringOfToday];
    
    
    return [NSString stringWithFormat:@"ACC : X: %+6.1f, Y: %+6.1f, Z: %+6.1f\nMAG : X: %+6.1f, Y: %+6.1f, Z: %+6.1f\nGYR : X: %+6.1f, Y: %+6.1f, Z: %+6.1f",self.acc.x,self.acc.y,self.acc.z,self.mag.x,self.mag.y,self.mag.z,self.gyro.x,self.gyro.y,self.gyro.z];
}

#pragma mark -将数据村粗在本地Document路径下
-(void)saveToDocumentWithData:(NSString *)data NamedTo:(NSString *)name{

    //错误信息
    NSError *error;
    // 创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];

    //Documents: 最常用的目录，iTunes同步该应用时会同步此文件夹中的内容，适合存储重要数据。
    NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    //根据名字获取当前的文件  文件名字存储命名为：20160329.txt
    NSString * filePath= [path
                         stringByAppendingPathComponent:name];

    if (![fileManager fileExistsAtPath:filePath])
    {//如果不存在
        NSLog(@"%@ is not exist",name);
        //创建文件 方式一（创建之后，不能直接return，需要写内容，不然第一条数据没有存储）
//        [fileManager createFileAtPath:name contents:nil attributes:nil];
        //创建文件 方式二（写入文件），直接return出去
        [data writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return ;
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    //将节点跳到文件的末尾
    [fileHandle seekToEndOfFile];
    //追加显示数据
    [fileHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    //关闭文件
    [fileHandle closeFile];
    //显示文件目录下有哪些文件
    NSLog(@"Tjj显示文件目录下有哪些文件: %@",
          [fileManager contentsOfDirectoryAtPath:path error:&error]);
    
    //读取指定文件的内容（读取方式有两种）
    NSData *fileData = [fileManager contentsAtPath:filePath];//filePath是包含完整路径的文件名
//    或方式二直接用NSData 的类方法： dataWithContentOfPath
//    NSData *fileData2 = [NSData dataWithContentsOfFile:filePath]; //方式二
    NSString *aString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSLog(@"Tjj读取指定文件中的内容:%@",aString);
}

@end

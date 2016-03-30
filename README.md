# BLE
本项目SensorTagAndoson的原因：
  最近在做TI芯片关于计步器这块的研究，这边对对应官网的源码进行修改，将角速度、重力加速度等参数进行本地存储。
  这边修改源码中的文件主要是：sensorTagMovementService.m文件。
  一、修改的方法有：
  #pragma mark -拼接展示数据
-(NSString *) calcValue:(NSData *) value；
  这边需要将监测到的角速度，x、y、z，重力加速度x、y、z总共6个值进行存储。
1）存储文件txt命名用日期来存储。例如：20160330.txt。
2）每一个数据，存储一行，之间用“，”拼接。每条数据之后，再拼接一个日期“12：04：22”（时：分：秒）。
例如一条数据记录为：0.1,0.4,0.9,-0.7,-27.3,-5.4，11:17:34
3）SensorTag套件采集数据1S采集10次。 
  二、添加的新方法：
  #pragma mark -将数据村粗在本地Document路径下
-(void)saveToDocumentWithData:(NSString *)data NamedTo:(NSString *)name；
1）这个方法，将传入的数据追加存入name.txt文件中。
  

补充说明：
1）本项目最初的源码地址：
https://github.com/JarvisW/SensorTag-iOS

2）源码中，相关的FrameWork的地址以及相关介绍。
10/26/2015

This application needs the MQTTKit framework located at :

https://github.com/jmesnil/MQTTKit.git


Install steps :

1. Make directory SensorTag2-Example
2. Enter directory and unzip SensorTag2-Example.zip here
3. Make Directory MQTT and enter it.
4. Run : git clone https://github.com/jmesnil/MQTTKit.git
5. Open SensorTag-Example.xcodeproj in Xcode.
6. Compile.

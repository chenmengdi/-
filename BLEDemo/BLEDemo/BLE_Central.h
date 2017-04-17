//
//  BLE_Central.h
//  BLEDemo
//
//  Created by GUANG YU ZHU on 4/17/17.
//  Copyright © 2017 YKH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BLE_Central : NSObject

@property (nonatomic, strong)CBCentralManager *manager;
@property (nonatomic, strong)CBPeripheral *peripheral;
@property (nonatomic, strong)NSNumber *rssi;
@property (nonatomic, assign)NSMutableDictionary *characteristicDict;


+ (instancetype)bluetoothManager;

- (instancetype)init;
//扫描蓝牙
- (void)scan:(int)timer;
//停止扫描
- (void)stopScanTimer;
//连接蓝牙
- (void)connect:(CBPeripheral*)peripheral;
//断开蓝牙连接
- (void)disConnect:(CBPeripheral*)peripheral;
//获取已经连接过的设备
- (void)connected:(NSArray *)uuidArray;
//写入命令
- (void)writeValue:(NSData*)data Peripheral:(CBPeripheral*)peripheral;


@end

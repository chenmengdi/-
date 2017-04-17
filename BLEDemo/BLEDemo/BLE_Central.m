//
//  BLE_Central.m
//  BLEDemo
//
//  Created by GUANG YU ZHU on 4/17/17.
//  Copyright © 2017 YKH. All rights reserved.
//

#import "BLE_Central.h"

@interface BLE_Central ()<CBPeripheralDelegate,CBCentralManagerDelegate>

@end
@implementation BLE_Central

+ (instancetype)bluetoothManager{
    
    static BLE_Central *bluetoothManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bluetoothManager = [[BLE_Central alloc]init];
        
    });
    return bluetoothManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _characteristicDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)scan:(int)timer{

    [NSTimer scheduledTimerWithTimeInterval:timer target:self selector:@selector(stopScanTimer) userInfo:nil repeats:NO];
    [self.manager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScanTimer{

    [self.manager stopScan];
}

- (void)connect:(CBPeripheral*)peripheral{

    [self.manager connectPeripheral:peripheral options:nil];
}

- (void)disConnect:(CBPeripheral*)peripheral{

    [self.manager cancelPeripheralConnection:peripheral];
}

- (void)connected:(NSArray *)uuidArray{

    NSMutableArray *array = [NSMutableArray array];
    for (NSString *uuid in uuidArray) {
        NSUUID *identifier = [[NSUUID alloc] initWithUUIDString:uuid];
        [array addObject:identifier];
    }
    //获取所有已经连接过的设备
    NSArray *kownPeriphweral = [self.manager retrievePeripheralsWithIdentifiers:array];
    NSLog(@"kownPeriphweral:%@",kownPeriphweral);

}

- (void)writeValue:(NSData*)data Peripheral:(CBPeripheral*)peripheral{

     CBCharacteristic *character = [_characteristicDict objectForKey:peripheral.identifier.UUIDString];
    if (data!= nil) {
        [peripheral writeValue:data forCharacteristic:character type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark ------ CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"%ld",(long)central.state);
    if (central.state == CBCentralManagerStatePoweredOff) {
        NSLog(@"Bluetooth system is off, please turn on the Bluetooth");
    }else if (central.state == CBCentralManagerStateUnknown){
        NSLog(@"No Bluetooth devices found");
    }else if (central.state == CBCentralManagerStateResetting){
        NSLog(@"CBCentralManagerStateResetting");
    }else if (central.state == CBCentralManagerStateUnsupported){
        NSLog(@"CBCentralManagerStateUnsupported");
    }else if (central.state == CBCentralManagerStateUnauthorized){
        NSLog(@"CBCentralManagerStateUnauthorized");
    }else if (central.state == CBCentralManagerStatePoweredOn){
        NSLog(@"CBCentralManagerStatePoweredOn");
    [self.manager scanForPeripheralsWithServices:nil options:nil];
    }else{
        
        NSLog(@"Other status of Bluetooth devices ");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"scanUUIDString:%@", peripheral.identifier.UUIDString);
    NSLog(@"advertisementData:%@", advertisementData);
    _rssi = RSSI;
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"%s", __func__);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    NSLog(@"ConnectPeripheral:%@", peripheral);
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%s", __func__);
    NSLog(@"error：%@", error);
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"error：%@", error);
    NSLog(@"didFailToConnectPeripheral");
}

#pragma mark ------ CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error{
    NSLog(@"%s", __func__);
    NSLog(@"error：%@", error);
    NSLog(@"RSSI:%@", RSSI);
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"%s", __func__);
    NSLog(@"error：%@", error);
    for (CBService *service in peripheral.services) {
        [peripheral  discoverCharacteristics:nil forService:service];
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"%s", __func__);
    NSLog(@"error：%@", error);
    for (CBCharacteristic *c in service.characteristics) {
        [peripheral discoverDescriptorsForCharacteristic:c];
    }
    
    if ([service.UUID.UUIDString isEqualToString:@"1803"]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            if ([characteristic.UUID.UUIDString isEqualToString:@"2A06"]) {
                
                if (characteristic) {
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    
                    [_characteristicDict setObject:characteristic forKey:peripheral.identifier.UUIDString];
                    
                }
            }
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"%s", __func__);
    NSLog(@"error：%@", error);
    NSLog(@"=========%@", characteristic);
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"%s", __func__);
    NSLog(@"error：%@", error);
    NSLog(@"didUpdateValueForCharacteristic,%@",characteristic.value);
    NSData *data = characteristic.value;
    NSLog(@"characteristic.value:%@",data);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"%s", __func__);
    NSLog(@"error：%@", error);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"%s", __func__);
    NSLog(@"error：%@", error);
    
}
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

@end

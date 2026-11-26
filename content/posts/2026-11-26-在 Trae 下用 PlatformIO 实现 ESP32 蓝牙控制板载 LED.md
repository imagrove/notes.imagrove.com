---
title: "在 Trae 下用 PlatformIO 实现 ESP32 蓝牙控制板载 LED"
date: 2026-11-26  
weight: 6
draft: false
author: "吕绪帆"
description: "在 Trae 下用 PlatformIO 实现 ESP32 蓝牙控制板载 LED"
tags: ["Arduino", "在 Trae 下用 PlatformIO 实现 ESP32 蓝牙控制板载 LED"]
categories: ["日志"]
---

<!--
用法：复制本文件到 content/posts/ 下，文件名随意（建议英文小写短横线，URL 会用它）。

只要这七个字段别写错：
  title       标题，加引号
  date        日期，格式 2026-11-19
  draft       false 才会发布，true 只有你自己看得到
  author      写你的名字，这是署名权
  description 一句话摘要，列表页会显示
  tags        标签，用来串联同类文章
  categories  先统一写 日志

六个段不是八股，是为了让你下次回看时找得到东西。写不满的段可以直接删。
-->

## 今天要做什么

实现ESP32使用手机蓝牙微信小程序控制板载灯

## 实际做了什么

按时间顺序记，别美化。贴关键代码：

### 步骤 1：初始化 PlatformIO 工程

```powershell
New-Item -ItemType Directory -Force "d:\windows\PlatformIO\Projects\esp32-ble-led" | Out-Null
pio project init -d "d:\windows\PlatformIO\Projects\esp32-ble-led" -b esp32dev --ide vscode
```  
### 步骤 2：配置 platformio.ini

```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino

monitor_speed = 115200

; 这块板在高速率下复位握手容易失败（Wrong boot mode 0x13），固定 115200 最稳
upload_speed = 115200

; BLE 协议栈体积较大，默认 1.25 MB 应用分区接近上限，改用 3 MB 应用分区
board_build.partitions = huge_app.csv
```
  
### 步骤 3：编写 BLE 程序

核心结构与关键代码（完整代码见 `src/main.cpp`）：

```cpp
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define LED_PIN 2
#define DEVICE_NAME "ESP32-BLE-LED"

#define SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define RX_UUID      "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define TX_UUID      "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
```

初始化流程：

```cpp
BLEDevice::init(DEVICE_NAME);                 // 设置广播名称
BLEServer *server = BLEDevice::createServer();
server->setCallbacks(new ServerCallbacks());  // 连接/断开回调

BLEService *service = server->createService(SERVICE_UUID);

// 手机写入 RX：设备接收命令，手机往这里写 on / off
BLECharacteristic *rxChar = service->createCharacteristic(
    RX_UUID, BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR);
rxChar->setCallbacks(new RxCallbacks());

// 设备通知 TX：设备发送状态，通过通知回传 LED:ON
s_txChar = service->createCharacteristic(
    TX_UUID, BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ);
s_txChar->addDescriptor(new BLE2902());       // 通知描述符，手机端才能开启 Notify

service->start();
BLEDevice::getAdvertising()->addServiceUUID(SERVICE_UUID);
BLEDevice::startAdvertising();
```

命令处理：

```cpp
void onWrite(BLECharacteristic *characteristic) override {
  String cmd = characteristic->getValue();
  cmd.trim();
  cmd.toLowerCase();

  if (cmd == "on" || cmd == "1") {
    s_ledOn = true;  applyLed();  notifyState("LED:ON");
  } else if (cmd == "off" || cmd == "0") {
    s_ledOn = false; applyLed();  notifyState("LED:OFF");
  } else if (cmd == "toggle") {
    s_ledOn = !s_ledOn; applyLed(); notifyState(s_ledOn ? "LED:ON" : "LED:OFF");
  } else if (cmd == "status") {
    notifyState(s_ledOn ? "LED:ON" : "LED:OFF");
  } else {
    notifyState("UNKNOWN:" + cmd);
  }
}
```

## 遇到的问题 & 怎么解决的

问题:当ESP32上的按键损坏时，如何使其进入下载模式  
解决方式:解决方式：按键损坏时，改为「自动复位 + 重试」烧录。设置 upload_speed = 115200，用 esptool 以 --before default_reset 直接写入，失败就自动重试；本项目第 2 次成功，日志出现 `Hash of data verified` 和 `Hard resetting via RTS pin` 即完成，全程未按 BOOT/EN。(### 不建议！！！)  

#### 方法 A：插线时按住 BOOT（最稳，推荐）

1. 拔掉 USB 线，让板子完全断电；
2. 按住板上的 **BOOT** 键（部分板印 **IO0**）不松手；
3. 保持按住，把 USB 线插回电脑；
4. 约 2 秒后松开 BOOT。

此时芯片上电时 GPIO0 为低电平，直接停在下载模式，不运行原有程序。

#### 方法 B：BOOT + EN 按键组合

1. 按住 **BOOT** 不放；
2. 点一下 **EN**（或 RST），松开 EN；
3. 再松开 **BOOT**。

顺序必须是「先按 BOOT、后按 EN、先松 EN、后松 BOOT」，顺序反了会正常启动而不是进入下载模式。

#### 方法 C：IO0 接 GND（BOOT 按键损坏时）

1. 断电，用杜邦线把 **IO0（GPIO0）** 与 **GND** 短接；
2. 插上 USB，芯片强制进入下载模式；
3. 烧录完成后**务必拔掉这根线**，再插拔一次 USB 复位，程序才会正常运行。  

### 步骤 9：手机端操作

| 步骤 | 操作 |
| --- | --- |
| 1 | 手机打开蓝牙并找手机微信小程序：BLE蓝牙调试小助手 |
| 2 | 找到并连接 `ESP32-BLE-LED` |
| 3 | 连接成功后输入1是打开LED灯，0是关闭LED灯 |


## 我理解的关键概念    

 BLE ：低功耗蓝牙，手机与 ESP32 的通信方式 ， 设备名 `ESP32-BLE-LED` 
 Write ：手机向设备写数据 ， 手机往 RX 写 `on` / `off` 
 Notify ： 设备主动向手机推送数据 ， 设备通过 TX 回传 `LED:ON`



## 最佳实践

1. **烧录优先手动进下载模式**：本板自动复位不稳定，插线按住 BOOT 最省时间。
2. **手动模式必须配 `--before no_reset`**：否则烧录工具一复位，芯片就退回正常运行。
3. **BOOT 坏了用 IO0 接 GND**：上电即进下载模式，烧完记得拔线。
4. **命令用文本协议**：`on` / `off` / `toggle` 可读性强，手机 App 手动输入即可测试。
5. **Notify 要加描述符**：`BLE2902` 不能省，否则部分手机无法开启通知。
6. **断开后重新广播**：在 `onDisconnect` 回调里调用 `startAdvertising()`，避免断线后设备消失。
7. **BLE 工程用大分区**：默认 1.25 MB 余量太小，`huge_app.csv` 更稳妥。
8. **用串口日志判断状态**：认 `蓝牙名称`、`设备地址`、`手机已连接` 三行输出。

## 总结
这是一个 ESP32 蓝牙控制 LED 的小项目：板子上电后以 `ESP32-BLE-LED` 名称广播，手机用 BLE微信小程序 调试 App 连接，往 RX 特征写入 `on` / `off` / `toggle` / `status`，程序据此控制 GPIO2 板载灯的亮灭，并通过 TX 特征把当前状态通知回手机。工程用 PlatformIO 搭建。设备已实测能正常广播并响应命令。








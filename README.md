# 香港/内地节假日日历应用

这是一个用Swift开发的iOS应用，用于展示和管理香港和内地的节假日信息。

## 功能特点

- 日历视图：直观展示香港和内地的节假日
- 节假日列表：按时间顺序展示所有节假日
- 地区筛选：可分别查看香港或内地的节假日
- 节假日详情：查看节假日的详细信息
- 提醒功能：设置节假日提醒
- 主题定制：支持自定义主题颜色

## 技术栈

- SwiftUI：用于构建现代化的用户界面
- Swift：主要开发语言
- JSON：节假日数据存储格式

## 项目结构

```
├── Views/              # 视图组件
│   ├── CalendarView.swift
│   ├── HolidayListView.swift
│   ├── HolidayDetailView.swift
│   └── SettingsView.swift
├── Models/             # 数据模型
│   └── Holiday.swift
├── Services/           # 业务逻辑
│   └── HolidayService.swift
└── Data/               # 节假日数据
    ├── hongkong_holidays.json
    └── mainland_holidays.json
```

## 开发环境要求

- Xcode 14.0+
- iOS 15.0+
- Swift 5.0+

## 安装和运行

1. 克隆项目到本地
2. 使用Xcode打开项目
3. 选择目标设备或模拟器
4. 点击运行按钮开始调试

## 贡献

欢迎提交Issue和Pull Request来帮助改进这个项目。

## 许可证

MIT License
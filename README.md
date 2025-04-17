# AI Calendar

一个智能的节假日日历应用，支持显示香港和内地节假日。

## 最新更新

### 2024-04-16
- 修复了香港节假日数据加载问题
- 优化了节假日日期显示格式
- 添加了节假日起止日期显示
- 改进了地区选择器的用户体验

## 功能特点

- 显示香港和内地节假日
- 支持按地区筛选节假日
- 显示节假日详细信息，包括：
  - 节假日名称
  - 地区信息
  - 起止日期
  - 星期几
- 支持月份切换
- 支持日期选择

## 技术栈

- SwiftUI
- Swift
- iOS 15+

## 安装说明

1. 克隆项目到本地：
```bash
git clone https://github.com/yourusername/ai_calendar.git
```

2. 打开项目：
```bash
cd ai_calendar
open ai_calendar.xcodeproj
```

3. 在 Xcode 中运行项目

## 项目结构

```
ai_calendar/
├── Models/
│   └── Holiday.swift
├── Services/
│   └── HolidayService.swift
├── Views/
│   └── Calendar/
│       ├── CalendarView.swift
│       └── Components/
│           ├── CalendarHeaderView.swift
│           ├── CalendarGridView.swift
│           ├── HolidayInfoCard.swift
│           └── MonthlyHolidaysView.swift
└── Data/
    └── hk_holiday/
        ├── cal_hk_holiday.json
        └── 1823_cal_dictionary.pdf
```

## 贡献指南

欢迎提交 Pull Request 或创建 Issue。

## 许可证

MIT License
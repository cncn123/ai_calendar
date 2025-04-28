# AI Calendar

一个智能的日历应用，支持节假日显示和主题切换功能。

## 最新更新

### 2024-04-21
- 新增精美开屏动画，使用系统日历图标结合渐变背景
- 优化日历视图，首次进入时自动滚动至当天节假日
- 改进了年份选择器布局，现在可铺满整行显示
- 优化了无假期月份的显示效果，添加了图标提示
- 完善了多地区假日显示逻辑，现在在选择特定地区时只显示该地区假日

### 2024-04-20
- 新增节假日一览页面，按月份顺序列出所有节假日
- 优化多地区节假日卡片布局，香港和内地节假日信息并排显示
- 改进节假日卡片选中状态的渐变虚线效果
- 优化节假日信息卡片，仅显示开始日期和持续天数

### 2024-04-16
- 修复了香港节假日数据加载问题
- 优化了节假日日期显示格式
- 添加了节假日起止日期显示
- 改进了地区选择器的用户体验

## 功能特点

- 📅 日历视图展示
- 🎉 节假日显示
- 🌙 深色/浅色主题切换
- 📱 支持跟随系统主题
- 显示香港和内地节假日
- 支持按地区筛选节假日
- 节假日一览页面，按月份顺序展示全年节假日
- 显示节假日详细信息，包括：
  - 节假日名称
  - 地区信息
  - 起始日期和持续天数
  - 星期几
- 支持月份切换
- 支持日期选择
- 精美开屏动画
- 自动定位到当天节假日

## 技术栈

- SwiftUI
- Swift
- iOS 15+

## 安装

1. 克隆仓库：
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
│   ├── HolidayListView.swift
│   ├── SplashScreenView.swift
│   └── Calendar/
│       ├── CalendarView.swift
│       └── Components/
│           ├── CalendarHeaderView.swift
│           ├── CalendarGridView.swift
│           ├── HolidayInfoCard.swift
│           ├── MultiRegionHolidayCard.swift
│           └── MonthlyHolidaysView.swift
└── Data/
    ├── hk_holiday/
    │   ├── cal_hk_holiday.json
    │   ├── yearly/
    │   │   ├── hk_holidays_sc_2023.json
    │   │   ├── hk_holidays_sc_2024.json
    │   │   └── hk_holidays_sc_2025.json
    │   └── 1823_cal_dictionary.pdf
    └── mainland_holiday/
        ├── 2023.json
        ├── 2024.json
        ├── 2025.json
        └── schema.json
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License
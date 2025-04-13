# 香港/内地节假日日历应用

这是一个用Swift开发的iOS应用，用于展示和管理香港和内地的节假日信息。应用采用现代化的UI设计，提供直观的日历视图和详细的节假日管理功能，帮助用户轻松掌握两地的法定假期安排。

## 功能特点

- 日历视图：直观展示香港和内地的节假日分布
- 节假日列表：按时间顺序展示所有节假日信息
- 地区筛选：可分别查看香港或内地的节假日
- 节假日统计：通过角标直观显示当月香港和内地节假日数量
- 节假日详情：查看节假日的详细信息和历史背景
- 提醒功能：设置节假日提醒，不错过重要日期
- 主题定制：支持自定义主题颜色和显示偏好
- 小组件支持：提供iOS系统小组件，快速查看即将到来的节假日
- 离线使用：所有节假日数据本地存储，无需联网查询

## 技术栈

- SwiftUI：用于构建现代化的用户界面
- Swift：主要开发语言
- MVVM架构：采用Model-View-ViewModel设计模式
- Combine框架：用于处理异步事件和数据流
- JSON：节假日数据存储格式
- UserDefaults：用户偏好设置存储
- UserNotifications：实现节假日提醒功能

## 项目结构

```
├── Views/                  # 视图组件
│   ├── Calendar/           # 日历模块
│   │   ├── CalendarView.swift
│   │   ├── CalendarViewModel.swift
│   │   └── Components/     # 日历子组件
│   │       ├── CalendarGridView.swift
│   │       ├── CalendarHeaderView.swift
│   │       ├── DayCell.swift
│   │       ├── HolidayInfoCard.swift
│   │       ├── MonthSelectorView.swift
│   │       └── MonthlyHolidaysView.swift
│   ├── Components/         # 通用组件
│   │   └── TabBarButton.swift
│   ├── HolidayListView.swift
│   ├── HolidayDetailView.swift
│   └── SettingsView.swift
├── Models/                 # 数据模型
│   └── Holiday.swift
├── Services/               # 业务逻辑
│   └── HolidayService.swift
└── Data/                   # 节假日数据
    ├── hongkong_holidays.json
    └── mainland_holidays.json
```

## 开发环境要求

- Xcode 14.0+
- iOS 15.0+
- Swift 5.0+
- macOS Monterey或更高版本（用于开发）

## 安装和运行

1. 克隆项目到本地
   ```bash
   git clone https://github.com/yourusername/ai_calendar.git
   cd ai_calendar
   ```

2. 使用Xcode打开项目
   ```bash
   open ai_calendar.xcodeproj
   ```

3. 选择目标设备或模拟器

4. 点击运行按钮开始调试

## 使用指南

- **日历视图**：滑动切换月份，点击日期查看当天节假日详情
- **列表视图**：浏览所有节假日，使用顶部选项卡筛选地区
- **设置**：自定义应用主题、通知偏好和显示选项

## 贡献

欢迎提交Issue和Pull Request来帮助改进这个项目。贡献前请先查看现有问题或创建新的问题讨论。

## 许可证

MIT License
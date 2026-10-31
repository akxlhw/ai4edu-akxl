# 鸿蒙开发、运行与调试指南

> 适用环境：Windows开发机、鸿蒙原生应用、后续包含相机和云端AI接口  
> 整理日期：2026-10-25  
> 说明：具体菜单和支持能力随DevEco Studio版本变化，实施时以当前官方文档和实际IDE为准

## 1. 工具链

- **DevEco Studio**：工程、SDK、构建、预览、调试、性能分析和设备管理。
- **ArkTS**：主要业务语言。
- **ArkUI**：声明式UI。
- **Stage模型**：应用组件和生命周期。
- **真机**：相机、权限、大图性能、兼容性和完整端到端验证。

官方入口：

- [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/)
- [HarmonyOS快速入门](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/start-overview)

## 2. 新建工程建议

1. 使用官方Release稳定版DevEco Studio。
2. 按首次启动向导安装匹配的SDK和工具链。
3. 选择HarmonyOS官方空应用模板，例如Empty Ability类模板。
4. 使用ArkTS、ArkUI和Stage模型。
5. 首发设备先选手机。
6. Bundle Name确定后不要随意修改。
7. 团队统一IDE、SDK和API版本，不混用早期FA模型教程。

工程中优先理解：

- `pages/`：页面。
- `entryability/`：入口和生命周期。
- `resources/`：资源。
- `module.json5`：模块、Ability和权限配置。
- `oh-package.json5`：依赖。

实际目录以新建模板为准。

## 3. 三种运行方式

| 方式 | 适合验证 | 主要边界 |
|---|---|---|
| Previewer | UI布局、文字、颜色、组件状态和简单交互 | 不代表所有系统API可运行，不能替代真机 |
| 模拟器 | 页面跳转、账号流程、普通网络请求和业务逻辑 | 相机、真实大图性能和设备兼容仍需真机 |
| 真机 | 相机、相册、权限、大图、上传、后台恢复和性能 | 需要设备连接与调试签名 |

建议节奏：页面用Previewer，普通业务用模拟器，每个功能完成后立即真机回归。

官方[模拟器文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-emulator-use)。

## 4. 真机运行步骤

1. 手机开启开发者模式和USB调试。
2. 使用支持数据传输的USB线连接，并在手机上授权。
3. 确认DevEco Studio设备列表识别到手机。
4. 打开`File > Project Structure > Project > Signing Configs`。
5. 登录华为账号，按是否已关联AGC应用配置自动签名。
6. 选择`entry`模块和目标手机。
7. 使用Run安装运行，使用Debug启动断点调试。
8. 检查首次相机、相册等权限授权。

具体签名步骤以官方[自动签名文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing-auto)为准。调试配置不等于正式发布配置。

## 5. 调试方法

### 5.1 ArkTS断点

在代码行左侧设置断点，以Debug启动。可检查变量、调用栈、异步返回和页面状态，并执行单步进入、跳过、跳出和继续运行。已运行应用可按官方支持方式Attach调试。

官方[ArkTS代码调试](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-debug-arkts)。

### 5.2 HiLog

在关键节点使用`hilog.debug/info/error`，在DevEco Studio的`Log > HiLog`窗口过滤。

建议记录：

- 拍照和相册选择结果。
- 图片尺寸和处理阶段。
- 上传任务的`taskId/requestId`。
- 接口状态码、错误码和耗时。
- OCR、切题、判题和讲解阶段状态。
- 页面退出、任务取消和恢复。

不得记录作业原图、孩子姓名、完整OCR文本、密钥或令牌。

官方[日志分析](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-setup-hilog)。

### 5.3 UI与性能

使用Previewer／Inspector检查布局和组件状态，使用性能分析工具检查CPU、内存和卡顿。重点关注大图解码、连续拍摄、多页处理和结果页图片释放。

## 6. 本地后端联调

鸿蒙客户端只要求后端提供网络接口，后端可使用Java、Python、Node.js等技术。

注意事项：

- 真机中的`127.0.0.1`和`localhost`指手机自身，不是电脑。
- 真机访问电脑本地服务时，通常使用电脑局域网地址，并检查同一网络、服务监听地址和Windows防火墙。
- 模拟器访问电脑按当前鸿蒙模拟器文档配置，不直接套用Android模拟器规则。
- 正式环境统一HTTPS。
- 客户端与服务端使用同一个`requestId`串联日志。
- 初期先提供固定OCR和判题结果的模拟后端，将客户端流程与真实AI服务解耦。

## 7. 作业应用专项测试

### 7.1 相机和权限

- 权限允许、拒绝、取消和重新授权。
- 预览方向和照片方向。
- 拍照与相册两条输入路径。
- 页面退出和重新进入。
- 连续拍摄与重复点击。

### 7.2 图片和内存

- 不同分辨率的大图。
- 旋转、裁切和压缩。
- 上传中断和重试。
- 后台再回来。
- PixelMap及临时图片资源释放。

### 7.3 原图标注

如果红框偏移，检查：

1. 旋转后是否仍使用原坐标。
2. 图片是否被缩放。
3. 裁切偏移是否遗漏。
4. 图片控件留白是否计入。
5. OCR返回坐标对应哪一张处理图。

### 7.4 云端AI链路

- 模拟结果与真实结果的接口契约一致。
- 每个处理阶段有独立错误状态。
- 第三方超时不会导致无限等待或重复任务。
- 判题完成但讲解失败时，可靠判题结果仍可展示。
- 日志中可以通过`requestId`还原处理链路，同时不泄露儿童信息。

## 8. 常见问题排查

| 现象 | 优先检查 |
|---|---|
| 找不到手机 | USB调试、手机授权、数据线、驱动、设备选择 |
| 无法安装 | Bundle Name、调试签名、设备Profile、旧包签名冲突 |
| Previewer正常但真机失败 | API支持范围、系统版本、运行时权限、HiLog |
| 拍照无反应 | 相机权限、生命周期、异步异常、设备日志 |
| 手机访问不了电脑接口 | localhost误用、防火墙、监听地址、网络配置 |
| 拍照后闪退或卡顿 | 大图内存、资源释放、重复解码、后台线程 |
| 批改框偏移 | 旋转、裁切、缩放和显示坐标转换 |

## 9. 建议的首个工程闭环

在不接真实AI的情况下，先完成：

> 首页 → 拍照／相册 → 裁切 → 模拟识别结果 → 原图画框 → 错题详情

该闭环真机稳定后，再接入真实OCR、判题和辅导服务。

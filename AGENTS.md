# AGENTS.md — ai4edu-akxl 工作区说明

## 项目概述

鸿蒙原生应用（bundleName `com.ai4edu.akxl`）：儿童学习辅导与作业检查工具，首选小学 3~4 年级数学。技术栈为 ArkTS + ArkUI + Stage 模型，构建用 Hvigor + OHPM（不是 npm，没有 package.json）。

当前阶段：**V0.1 模拟数据闭环**。设计已定稿（见下方文档），但 `entry` 模块仍是 DevEco 空模板（Hello World），实现尚未开始。

## 目录结构

- `entry/` — 唯一 HAP 模块。`src/main/ets/`（pages、entryability）；`src/test/` 本地单测；`src/ohosTest/` 仪器测试；`src/mock/` mock 配置
- `AppScope/` — 应用级配置（bundleName、版本、全局资源）
- `docs/` — 全部为中文文档，是本项目的"单一事实来源"（见下方阅读指引）
- `hvigor/`、`hvigorfile.ts`、`build-profile.json5`、`oh-package.json5` — 构建配置

## 必读文档（改代码前）

| 场景 | 文档 |
|---|---|
| V0.1 实施蓝图（页面流、模块分层、数据模型、验收标准） | `docs/superpowers/specs/2026-10-31-v0.1-mock-loop-design.md` |
| V0.1 UX 修正依据（P0/P1） | `docs/superpowers/specs/2026-10-31-v0.1-ux-review.md` |
| 总体技术设计 | `docs/superpowers/specs/2026-10-25-harmonyos-homework-tutor-design.md` |
| 开发/调试/真机指南 | `docs/development/01-harmonyos-development-and-debugging.md` |
| 团队协作规范（硬性规则来源） | `docs/team/01-ai-digital-team-workflow.md` |
| 产品范围 / 路线图 | `docs/product/`、`docs/plans/01-version-roadmap.md` |

文档口径三分法：**已确认 / 当前建议 / 待决策**。不得把"当前建议"当作已确认事实写入代码注释、对外说明或不可变约束。

## 构建与验证

- 本机 PATH 上没有 `hvigorw` / `devecocli` / `codelinter`，工程根目录也没有 hvigorw 包装脚本 —— 构建和真机运行通过 **DevEco Studio** 完成。设计文档中提到的 `devecocli check arkts`、`devecocli build` 是验收门槛命令，依赖前先用 `which` 确认可用。
- 依赖管理：OHPM（`oh-package.json5` → `oh_modules/`）；测试框架 hypium + hamock。
- Lint 规则：`code-linter.json5`（`@performance/recommended` + `@typescript-eslint/recommended` + 安全规则，只查 `*.ets`，排除 test/mock/build）。
- SDK：targetSdkVersion 26.0.0，compatibleSdkVersion 6.1.1(24)，runtimeOS HarmonyOS。
- **真机硬门槛**：涉及相机、相册、权限、大图、上传、后台恢复的功能，必须真机验证（当前设备：HUAWEI MatePad Air，HarmonyOS 7.0）。编译通过或 Previewer 正常不能代替真机验证。

## 架构约束（V0.1 设计定稿，实施时必须遵守）

- 模块分层：`pages/` → 只调用 `service/`，不在页面内拼 mock 数据；`components/`（CropOverlay、AnnotationOverlay、StatusBadge、ProgressStageBar）；`model/`（Question、QuestionStatus、Explanation、HomeworkSession）；`service/mock/` 与未来 `service/remote/` 实现同一组接口签名，接真实后端时只替换实现层；`utils/CoordinateUtil`。
- 导航：Navigation + 系统路由表 `resources/base/profile/router_map.json`，目的地页面根节点为 `NavDestination`；任务态经 `NavPathStack` 参数 + 内存单例 `HomeworkSessionStore` 传递。
- 四态判题枚举：`CORRECT / INCORRECT / UNREADABLE / UNSUPPORTED`。识别不清不得判错，暂不支持不得强行给结论；UNREADABLE 文案用"没拍清楚"类措辞，不用"识别失败"。
- 坐标一致性（防标注框偏移的核心）：题目区域一律用相对最终处理图的**归一化坐标 0..1**（`RectF`），渲染时经 `CoordinateUtil` 做 `ImageFit.Contain` 留白补偿；此逻辑必须有单元测试。
- 渐进披露：错题详情默认只显示错因 + 思路提示，完整解析主动展开并埋点。
- 埋点：`EventLogger` 基于 hilog，tag `homework_events`，事件名常量化；不记录图片内容和识别文本。

## 硬性规则（来自 docs/team/01）

- **隐私红线**：日志、提示词、代码中禁止出现作业原图、孩子姓名、完整 OCR 文本、密钥或令牌。
- **人工闸门**：真实儿童图片使用、云/模型服务商选择、签名发布凭证、对外承诺（题型/准确率/上线日期）不得由 Agent 自行决定。
- 不直接推送主分支；小任务、小变更；只改任务范围内内容，不做无关重构；不引入未确认的依赖、API 或服务。
- 不从记忆推断鸿蒙 API 能力，以已安装 SDK 和编译/真机结果为准。
- 功能"完成"定义包含：需求审查 + 代码审查 + 测试与构建通过 + （设备相关功能）真机验证 + 文档更新。

## 仓库注意

- 全新 git 仓库，**尚无任何 commit**，所有文件未跟踪；当前分支 `master`。
- `local.properties`、`.hvigor/`、`oh_modules/`、`build/`、`.idea/` 为机器本地或生成内容，已 gitignore，勿提交、勿手改。
- 开发机为 Windows（Git Bash shell）。

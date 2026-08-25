---
name: specialization-qml
description: >-
  【QML 特化】消费 ImageRead 报告，落到 Qt Quick/QML。不负责识图。
  当宿主 SOP 从仓库推断 GUI 为 QML 且本轮要写码时调度。
disable-model-invocation: true
---

# Specialization · QML

## 定位

```text
image-read 报告  →  本包写 QML  →  项目 bindings（路径/主题/翻译）
```

**不是 ImageRead 必经步骤。** 宿主 SOP 已从仓库推断 **GUI=QML**（如存在 `qml/`、`*.qml`）且本轮要写码时才 Read 本目录。

**前置（硬门控）**：对话中已有 ImageRead 报告，且至少含 `【像素参数表】` 与 `【ImageRead完成，等待宿主消费报告；本阶段不写代码】`。  
无图且用户只改已知几何/文案时可跳过。  

**禁止**：在本包内重新测图、跳过报告猜间距、以「尽快可见效果」先改 QML。

进入 `implement` 前若缺少【像素参数表】，只输出【流程回退】并停止，**不得**调用 Write/StrReplace 改 UI。

## 调度顺序

1. **报告门检**：确认【像素参数表】等关键区块已在对话中；通过后写 `【写码许可】…`  
2. 确认宿主已提供 **project-bindings**（目录、`Colors`/`qsTr`、组件映射）  
3. `./implement/SKILL.md` — 落码  
4. `./verify/SKILL.md` — qmllint、尺寸链、布局复校  

**落码结构跟分区树，不跟清单升格。** 清单单独一行 + 独立高宽 ≠ 新建 Card/列；用清单「从属」路径放进已有卡组。

## 报告字段 → QML（速查）

| 读图字段 | 典型落点 |
| --- | --- |
| 控件外框 | `width`/`height` 或 Layout min/preferred/max（经 bindings 的 `Metrics.dp`） |
| 距内容区边 | `anchors.*Margin` / `Layout.margins` |
| itemSpacing | 仅 `ListView.spacing` / 列表向 Column spacing |
| 列表外距 | 容器/父 Layout margin，禁止塞进 `ListView.spacing` |
| border / radius / 色 | `border.*` / `radius` / bindings 主题色 |
| discrete-repeat | 一条 delegate + model，禁止按条数复制 |
| dialog 面板外框 | Dialog/Popup 内容宽高，不含遮罩 |
| showcase 显示盒 | 按报告推导宽高与 topMargin；勿盲 centerIn |

细节见 `implement/`、`verify/`。

## 与本仓库

项目 bindings：`.cursor/skills/design-to-qml/project-bindings.md`  
由 `.cursor/skills/design-to-qml/SKILL.md` 调度本包。

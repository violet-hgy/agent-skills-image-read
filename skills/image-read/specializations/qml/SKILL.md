---
name: qml
description: >-
  ImageRead 可选语言特化：消费像素报告，落到 Qt Quick/QML。不负责识图。
  当宿主 SOP 从仓库推断 GUI 为 QML 且本轮要写码时 Read。需宿主 project-bindings。
disable-model-invocation: true
metadata:
  internal: "true"
---

# Specialization · QML（可选兼容项）

## 定位

```text
ImageRead 报告  →  本特化写 QML  →  宿主 project-bindings
```

**不是** ImageRead 必经步骤。宿主 SOP 已从仓库推断 **GUI=QML** 且本轮要写码时才 Read 本目录。  
**前置**：已有 ImageRead 输出（或无图且用户只改已知几何/文案）。  
**禁止**：在本包内重新测图、跳过报告猜间距。  
**不含**：任何业务仓库的 project-bindings。

## 调度顺序

1. 确认宿主已提供 **project-bindings**（目录、主题色 API、文案 API、组件映射）  
2. `./implement/SKILL.md` — 落码  
3. `./verify/SKILL.md` — 语法检查、尺寸链、布局复校  

## 报告字段 → QML（速查）

| 读图字段 | 典型落点 |
| --- | --- |
| 控件外框 | `width`/`height` 或 Layout min/preferred/max（经 bindings 的尺寸 API） |
| 距内容区边 | `anchors.*Margin` / `Layout.margins` |
| itemSpacing | 仅 `ListView.spacing` / 列表向 Column spacing |
| 列表外距 | 容器/父 Layout margin，禁止塞进 `ListView.spacing` |
| border / radius / 色 | `border.*` / `radius` / bindings 主题色 |
| discrete-repeat | 一条 delegate + model，禁止按条数复制 |
| dialog 面板外框 | Dialog/Popup 内容宽高，不含遮罩 |
| showcase 显示盒 | 按报告推导宽高与 topMargin；勿盲 centerIn |

细节见 `implement/`、`verify/`。

## 与宿主

由宿主 SOP 在 ImageRead 报告之后、**GUI 栈推断为 QML** 时 Read 本文件。路径：`specializations/qml/SKILL.md`。

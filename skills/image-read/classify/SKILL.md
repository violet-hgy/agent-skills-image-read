---
name: image-read-classify
description: UI 解析任务分流：分别确定来源、范围、深度、提取维度和 UI 场景。
disable-model-invocation: true
---

# Classify

先读取实际参考，再判断任务；不要求先具备 Python 或 Figma 连接。

## 四个独立维度

- 输入来源：截图 / 设计图片 / Figma 节点 / 混合参考 / 其它实际提供的 UI 证据。
- 解析范围：full-page 整页 / named-subtree 指定区域 / named-control 单控件 / named-extract 指定内容或属性。
- 解析深度：skeleton 布局骨架 / composition 控件组成 / style 视觉样式 / precise 精确测量。可组合。
- UI 场景：页面壳、表单、列表、表格、弹窗、导航、工作区、仪表盘、内容页、展示区等。允许多标签。

先按用户意图定范围和深度，再用参考形态辅助判断。
未指定深度的整体 UI 分析，默认骨架 + 控件组成 + 主要样式；不默认逐像素测量。
按图还原或像素对齐的前置解析，应覆盖范围内控件组成、样式与实现所需的关键几何。
精确测量只针对需要精度的字段，不自动扩张范围。

## 内置路由

布局见 [../references/layouts.md](../references/layouts.md)；控件见 [../references/controls.md](../references/controls.md)；组合场景见 [../references/scenarios.md](../references/scenarios.md)。
先查内置模式是否足以描述实际 UI。产品名字陌生、截图格式不同、配色变化都不构成外部检索理由。
只有未覆盖且无法由已知模式组合解释的布局或控件，才记录具体缺口并进入外部检索分支。

## 范围与展开

- 用户点名优先。祖先可作定位上下文，不展开范围外兄弟。
- 只看骨架：停在内容分区、列、卡组、卡片和必要行组；不列卡内全部按钮、文字和图标。
- 看控件组成：展开范围内语义控件，必要时描述图标、标签、输入区、指示器等组成。
- 看样式：纳入与请求有关的容器、控件及视觉子层；重复模式可以模板 + 差异描述。
- 指定提取：目标、属性维度、覆盖对象明确即可。只取文案不强制补字号；只取列表内容不强制测滚动条。
- 实现前置解析：覆盖影响布局与外观的展示内容、装饰和交互控件，不只列可点击项。

建议记录：

- 【解析任务】来源、范围、深度、场景。
- 【目标与维度】指定提取时填写。
- 【内置匹配】布局、控件、组合场景。
- 【待解析对象】范围内对象。
- 【规则缺口】无，或未覆盖模式及具体疑点。

仅当目标无法合理确定且会影响结果时询问。可先完成不依赖澄清的部分。

## 旧标识兼容

- layout-only → 原范围 + skeleton；未指定对象时可覆盖整页骨架。
- named-extract → 保留，按实际请求属性裁剪。
- page-layout / dialog-sheet / delegate-row / control-full / overlay-badge → 对应 UI 场景。
- visual-tweak → style 深度；measure-only → 按请求使用 precise。
- showcase-align / asset-compare → 资源展示或资源比较分支，不作为通用 UI 解析主线。

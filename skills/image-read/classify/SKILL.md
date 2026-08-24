---
name: image-read-classify
description: 读图·场景分流（由 image-read 调度）。多元素强制 page-layout + 元素清单。
disable-model-invocation: true
metadata:
  internal: true
---

# Classify

输出（原样标题）：

```text
【识图场景】<场景码> — <一句话依据>
【元素清单】N — <短名1>; <短名2>; …   （N≥1；单控件也至少 1 项）
```

用户点名优先；点名项**必须**出现在【元素清单】中。

## 场景表

| 场景码 | 特征 | 测量重点 |
| --- | --- | --- |
| `showcase-align` | 大块渲染常含透明边 | 透明 pad + 墨迹框 |
| `overlay-badge` | 角落浮层无遮罩 | 外框、border、页边距、内 padding |
| `dialog-sheet` | 遮罩 + 面板 | 遮罩与面板分列 |
| `asset-compare` | 新旧图比尺寸 | 固有尺寸、宽高比、显示框 |
| `control-full` | 孤立单控件切图 | 外框、padding、border |
| `delegate-row` | ≥2 同构近等距离散项 | itemSpacing + 首项外距 |
| `page-layout` | 整页 / 多区块 / 多卡片 | **先清单后逐项测**框 + gap + 距内容区边 |
| `visual-tweak` | 主要差色/字/圆角 | 视觉表 |
| `measure-only` | 只要报告 | 完整测量 + 清单 |
| `text-extract` | 只要文案 | 文案列表 |

## 强制 `page-layout`（多元素）

命中任一 → **必须** `page-layout`（或在已有主场景外叠加多区块测量纪律，清单仍强制）：

- 可独立成块的区域 ≥ 3（如主图区、卡片、底栏、侧栏）
- 整页截图 / 多卡片 + 底栏/顶栏
- 用户点名 ≥ 2 处几何对齐

判定速记：透明大主体→showcase；孤立单块→control-full；≥2 同构等距→delegate-row；遮罩+面板→dialog-sheet；角落胶囊→overlay-badge；**其余多块整页→page-layout**。

## 【元素清单】规则

- 在 **geometry 之前**列出全部要对齐的块（外框级）；块内子控件另起子行或写在必测字段里  
- 禁止只列“主内容”而漏底栏、角标、点名块  
- 默认用户提供的是**无损原图**：不得以“图有损/信息不足”为由少列清单项或要求开发二次确认

仅当测量目标**无法唯一框定**时停问（与写码落点无关）；可测几何不得标成需确认。

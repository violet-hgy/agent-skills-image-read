---
name: image-read-structure
description: 读图·结构（列表/弹层/浮层/透明资源/可交互叶子）（由 image-read 调度）。
disable-model-invocation: true
metadata:
  internal: true
---

# Structure

## discrete-repeat（`delegate-row`）

≥2 同构近等距不相连项 → `【列表模式】discrete-repeat — N`。  
测：第1/2项 → **itemSpacing** → 首项外距 → 模板行内。外距与内距分栏，禁止一个笼统 spacing。

## dialog-sheet

遮罩 vs 面板分列；面板外框不含遮罩。

## overlay-badge

外框、border、距内容区边、内 padding。

## showcase-align

资源透明 pad + 画面墨迹；报告推导显示盒 = 资源×scale_fit（不绑定框架 API）。

## asset-compare

固有尺寸/宽高比/显示框；比例同边长不同 → 【需确认】，不擅自选定。

## page-layout / 多元素（强制 · 受【测量范围】约束）

整页截图仍可能只测骨架或其中一块。以 classify 的【测量范围】为准。

- `layout-only`：清单只有容器行；**不要**补叶子行。  
- 其它范围：清单在范围内含第 2 层可交互叶子。

在测具体像素前，必须已有 classify 的【元素清单】。本步输出或补全：

```text
【元素清单表】
| # | 短名 | 层级 | 控件类 | 必测字段 | 状态 |
| --- | --- | --- | --- | --- | --- |
| 1 | 震动卡 | 容器 | card | 外框、距内容区边、与邻块 gap | 待测→已测 |
| 1.1 | 震动/关 | 叶子 | segment | 外框、粒宽、与邻粒 gap、选中态 | 待测→已测 |
```

`控件类` 用短标签即可（不必穷尽枚举），常用：`segment`（同排分段粒）、`list-row`、`combo`、`check`/`radio`、`toggle`、`slider`、`grid-btn`、`icon-btn`、`nav-row`、`card`/`bar`。

测量顺序（强制）：

1. 内容区边距（左/右/顶/底，按锚定边）  
2. 各**容器**外框与**块间 gap**  
3. **叶子**：仅当范围不是 `layout-only` 时，对范围内容器展开并测完叶子  
4. 若范围包含顶栏/底栏：`layout-only` 只测栏外框；控件级才测分段宽/Tab 槽位  
5. 用户点名项复核  

## 可交互叶子（控件级范围才强制 · 不限胶囊）

`layout-only`：**跳过本节**。

凡 classify 在非 `layout-only` 下列出的叶子，须在本步进【元素清单表】且最终「已测」。按类最低必测：

| 控件类 | 最低必测 |
| --- | --- |
| `segment` 同排分段粒 | 粒数 N、单粒外框（或等宽推导）、粒间 gap、选中/未选中差异；**禁止**只测整条轨道当一个控件 |
| `list-row` / `nav-row` | 行外框、行高、行内间距、与上下行 gap；可复用 `discrete-repeat` |
| `combo` 下拉触发器 | 触发器外框、与标签 gap；展开面板若不在图中 →【差异】记未覆盖态，触发器仍须已测 |
| `check` / `radio` | 盒外框、与文案间距、选中态 |
| `toggle` | 开关外框、开/关态（图中可见态） |
| `slider` | 轨道、拇指、两端 ± 按钮（若有）各自外框或间距 |
| `grid-btn` | 单格外框、网格 gap、行列数 |
| `icon-btn` | 图标热区外框、相对父行边距 |

同排 ≥2 等构叶子：套用 `discrete-repeat` 纪律（测第 1/2 项 → itemSpacing → 模板），即使整图场景是 `page-layout`。

硬规则：

- **范围内**任一行仍为「待测」→ **禁止**进入 output 宣称完成  
- 控件级范围（非 `layout-only`）：仅容器已测、叶子未进表 → 报告未完成  
- `layout-only`：容器外框/分栏/gap 已测即可；**禁止**因无叶子行判未完成  
- 未测范围外叶子 **不算** 未完成  
- 可测几何不得标「猜测」；默认图为无损原图  
- 控件级任务禁止只量卡片外框就交完整报告；`layout-only` 正是只要外框

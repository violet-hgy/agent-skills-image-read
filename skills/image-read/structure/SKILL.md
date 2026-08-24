---
name: image-read-structure
description: 读图·结构（列表/弹层/浮层/透明资源）（由 image-read 调度）。
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

## page-layout / 多元素（强制）

在测具体像素前，必须已有 classify 的【元素清单】。本步输出或补全：

```text
【元素清单表】
| # | 短名 | 必测字段 | 状态 |
| --- | --- | --- | --- |
| 1 | … | 外框、距内容区边、与邻块 gap、… | 待测→已测 |
```

测量顺序（强制）：

1. 内容区边距（左/右/顶/底，按锚定边）  
2. 各清单项**外框**  
3. **块间 gap** / 邻接关系  
4. 块内结构（行内 gap、子控件）  
5. 顶栏/底栏是否铺满、分段宽、分隔  
6. 用户点名项复核  

硬规则：

- 任一行状态仍为「待测」→ **禁止**进入 output 宣称完成  
- 可测几何不得标「猜测」；默认图为无损原图  
- 禁止只量中心一块就交完整报告

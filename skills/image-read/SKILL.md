---
name: image-read
description: >-
  像素级读图报告，防止 AI 幻觉。有附图/截图/切图（PNG/JPEG/WebP/GIF/BMP 等位图），或按图还原、
  像素对齐、设计评审、实现图内 UI、写码前量尺寸时自动适用。Python 仅为测量运行时；测图后端按准确可用选择（不绑定 cv2），
  失败先自动修，无可用后端则停止、禁止估算。
  Agent Skills 安装源（id: image-read）。纯 Figma（MCP 已给节点 px）不要用本 skill。不写代码。
disable-model-invocation: false
---

# ImageRead

## 定位

```text
ImageRead（本包）  →  结构化像素报告（可视参数表）  →  结束

写图（可选）      →  项目 specializations/<lang>/  +  bindings
                   由宿主 SOP 读仓库推断 GUI 栈后决定是否进入
```

**只读图、只出数。** 不实现 UI，不改 Figma，不落资源清单。

ImageRead **不负责推断项目 GUI 语言**（那是宿主 SOP 的事）。本包结束后：

- **只识图 / 评审** → 报告即交付。  
- **要写码** → 宿主读仓库（如 `qml/`、`*.tsx`）推断栈；匹配特化或 LLM 读参数表自行写码。

本仓库 QML 特化：`.cursor/portable-skills/specializations/qml/`（QML 栈且要写码时由 `design-to-qml` 调度）。

## 自动触发（Agent 自动挂载）

**位图** = 栅格图：PNG、JPEG/JPG、WebP、GIF、BMP、TIFF，以及截图/聊天附图（格式不论）。不含 SVG 矢量源、不含 Figma 节点树。

**位图默认 = 无损原图。** 禁止以“有损/信息不足/要二次精调”为由少测或要求开发口头二次确认。

**命中任一且像素来自位图时，必须先 Read 并执行本 skill 全流程，再写 UI 代码或报尺寸：**

- 用户附图、控件切图、整页截图（PNG/JPEG/WebP 等）
- 意图：按图还原、像素对齐、量尺寸、设计评审、**实现图内 UI**、对齐稿面（且源是图）
- 对话要求【识图场景】或对 **位图** 出像素表

**硬门控：** 有位图要写 UI / 报几何 → **禁止**跳过本 skill 直接写码或「大约」填数。

**不触发：**

- **纯 Figma**（仅链接/`node-id`，无用户位图）：用 Figma MCP 节点 px，**不要**对本 skill / 导出 PNG 再量
- 无图、仅改已知文案/色/逻辑、纯协议或后端任务

**与 project-bindings 无关：** 有无 `project-bindings.md` **不影响**本 skill；bindings 只在写码阶段需要。

**【识图场景】码（classify 产出）：** `dialog-sheet`、`delegate-row`、`control-full`、`page-layout`、`showcase-align`、`overlay-badge`、`visual-tweak`、`measure-only`、`text-extract`。细则见 `./classify/SKILL.md`。

## 嵌套结构

```text
image-read/
├── SKILL.md
├── classify/ gates/ geometry/ structure/ visual/ output/
```

## 调度顺序（强制 · 仅识图）

1. `./gates/SKILL.md` — **环境放行**。Python=测量运行时；测图用任一准确可用后端（不强制 cv2）。无可用后端 →【ImageRead环境未就绪】并结束。禁止估算填表、禁止写 UI。
2. `./classify/SKILL.md` → 【识图场景】+【元素清单】（多元素强制 `page-layout` 纪律）
3. `./structure/SKILL.md`（含 page-layout 清单表）→ 再 `./geometry/SKILL.md` 按清单逐项实测
4. `./visual/SKILL.md`
5. `./output/SKILL.md` → 完整报告（含【测量完备性】）

**gates 未 OK 时本包职责已终止**（修环境后再从头执行）。gates OK 后才出完整报告。

## 两阶段协议（强制）

### Phase 1：只产出识图报告

当本 skill 被触发时：先跑 **gates**（确保 Python + 至少一种测图后端可用）。环境 FAIL 时首次输出只能是【ImageRead环境未就绪】，**不是**完整参数表，也**不是** UI。

环境 OK 后，**本轮首次实质性输出必须是 ImageRead 报告**，且只允许：

- 执行 `classify → structure → geometry → visual → output`（多元素先清单后逐项测）
- 输出【识图场景】【元素清单】与完整报告区块
- 【测量完备性】达标；猜测仅限不可测单字段
- 标注【需确认】仅真缺信息（禁止无损原图借口）

**Phase 1 禁止：**

- 任何 UI 实现代码
- 任何“先给你一个可见界面/近似还原”的方案
- 任何绕过参数表的布局建议
- 把 SKILL 总说明、口头摘要、自然语言概述当作“已完成报告”

### Phase 2：宿主消费报告 + 一次对齐（同轮）

只有 Phase 1 完整报告（含清单完备、猜测占比门控通过）后，宿主才能写码。

**一次对齐（默认目标，针对图中可见态）：**

- 本轮内：落码 → **Agent 内部自校**（对照参数表算术 + 清单项）→ 容差内收敛  
- 容差建议：外框/关键间距 ±1px（设计 px）；字相关盒 ±2px  
- 未覆盖态（hover 等）写入【差异】，**不算**失败、**不要求**开发二次确认  
- 收尾由宿主写【一次对齐完成】或【对齐完成】（推荐前者）；**禁止**“可能要二次精调 / 请确认后再对齐一轮”

ImageRead **自身**止于完整报告；一次对齐的自校由宿主 SOP / verify 在同轮完成。

## 硬规则

- 禁止未读图写参数表；禁止「大约」当实测  
- 猜测必须【暂时猜测数值占用】；**可测几何禁止猜测**  
- 有图必须先有【识图场景】+【元素清单】  
- 多元素：清单未测完 / 猜测占比超标 → 报告未完成  
- 阴影只记不当描边  
- 设计 px + 注明 scale；用户口头 px 优先  
- **默认无损原图**；禁止据此要求开发二次确认  
- **禁止**本包识图流水线内写码  
- Python 未就绪，或无任何可用测图后端：**禁止**后续 SOP 与整表估算  
- 当前后端失败：先自动修，仍失败则换其它可用后端实测；禁止目测估算  
- **不强制 cv2**；【元数据】写明实际使用的测图后端  

## 报告完成门控（强制 · 写 UI 前）

如果你的目标包含“实现图内 UI / 写代码 / 报几何 / 修改布局”：

- **gates FAIL**：只输出【ImageRead环境未就绪】并停止  
- **gates OK**：须先有完整报告，且含【元素清单】【测量完备性】且门控通过  

报告必须至少包含下列区块标题（原样）：

- `【识图场景】`
- `【元素清单】`
- `【像素参数表】`
- `【视觉参数表】`
- `【结构专表】` 或 `不适用`
- `【测量完备性】`
- `【需确认】`
- `【差异 / 不确定】`
- `【暂时猜测数值占用】` 或 `无`

未包含任一项或完备性门控失败：

```text
【ImageRead未完成】缺少：<区块名列表或完备性原因>
请先补齐清单实测，再继续写 UI。
```

若在完整报告前已经输出过实现代码/方案，视为**流程失败**；回退 Phase 1。

禁止把“本 SKILL.md 的总说明”当作完成报告。

## 安装

`npx skills add <org>/agent-skills-image-read --skill image-read` 装入 `.cursor/skills/image-read/` 后即参与自动匹配。子 skill 用相对路径调度。

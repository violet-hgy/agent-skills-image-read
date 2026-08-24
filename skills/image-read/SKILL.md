---
name: image-read
description: >-
  像素级读图报告，防止 AI 幻觉。有附图/截图/切图（PNG/JPEG/WebP/GIF/BMP 等位图），或按图还原、
  像素对齐、设计评审、实现图内 UI、写码前量尺寸时自动适用。对位图实测几何与视觉并输出【识图场景】
  与可视参数表；禁止未读图写尺寸。纯 Figma（MCP 已给节点 px）不要用本 skill。不写代码、不依赖 project-bindings。
  Agent Skills 安装源（id: image-read）。
disable-model-invocation: false
---

# ImageRead

## 定位

```text
ImageRead（本包）  →  结构化像素报告（可视参数表）  →  结束

写图（可选）      →  ./specializations/<lang>/  +  宿主 project-bindings
                   由宿主 SOP 读仓库推断 GUI 栈；匹配且要写码时才进入
```

**只读图、只出数。** 不实现 UI，不改 Figma，不落资源清单，**不进入任何语言特化**。  
**不含**项目绑定；**不负责推断项目 GUI 语言**（属宿主 SOP）。

报告中的参数表供 LLM 直接消费。要写码时：宿主读仓库（`qml/`、`*.tsx` 等）推断栈 → 匹配特化则进 `specializations/`，否则 LLM 读表写码。**禁止**在本包识图流水线内写码。

## 自动触发（Agent 自动挂载）

**位图** = 栅格图：PNG、JPEG/JPG、WebP、GIF、BMP、TIFF，以及截图/聊天附图（格式不论）。不含 SVG 矢量源、不含 Figma 节点树。

**命中任一且像素来自位图时，必须先 Read 并执行本 skill 全流程，再写 UI 代码或报尺寸：**

- 用户附图、控件切图、整页截图（PNG/JPEG/WebP 等）
- 意图：按图还原、像素对齐、量尺寸、设计评审、**实现图内 UI**（且源是图）
- 对话要求对 **位图** 出【识图场景】或像素表

**硬门控：** 有位图要写 UI / 报几何 → **禁止**跳过本 skill 直接写码或「大约」填数。

**不触发：**

- **纯 Figma**（仅链接/`node-id`，无用户位图）：用 Figma 节点 px，不要对本 skill / 导出 PNG 再量
- 无图、仅改已知文案/色/逻辑

**与 project-bindings 无关：** 有无宿主 `project-bindings.md` **不影响** ImageRead；bindings 仅在写码阶段需要。

**【识图场景】码（classify 产出）：** `dialog-sheet`、`delegate-row`、`control-full`、`page-layout`、`showcase-align`、`overlay-badge`、`visual-tweak`、`measure-only`、`text-extract`。细则见 `./classify/SKILL.md`。

## 嵌套结构

```text
image-read/
├── SKILL.md
├── classify/ gates/ geometry/ structure/ visual/ output/
└── specializations/          ← 可选，非本流水线
    └── qml/
```

## 调度顺序（强制 · 仅识图）

1. `./gates/SKILL.md`
2. `./classify/SKILL.md` → 输出【识图场景】
3. `./geometry/SKILL.md`
4. `./structure/SKILL.md`（场景需要时）
5. `./visual/SKILL.md`
6. `./output/SKILL.md` → 完整报告

结束后输出完整报告；**本包职责终止**。

- **只识图 / 评审** → 报告即交付。  
- **要写码** → 由宿主 SOP 读仓库推断 GUI 栈；匹配 `./specializations/<lang>/` 再进入，否则 LLM 读参数表写码。

## 两阶段协议（强制）

### Phase 1：只产出识图报告

当本 skill 被触发时，**本轮首次实质性输出必须是 ImageRead 报告**，且只允许做下列事情：

- 执行 `gates → classify → geometry → structure → visual → output`
- 输出【识图场景】与完整报告区块
- 标注【需确认】、【差异 / 不确定】、【暂时猜测数值占用】

**Phase 1 禁止：**

- 任何 UI 实现代码
- 任何“先给你一个可见界面/近似还原”的方案
- 任何绕过参数表的布局建议
- 把 SKILL 总说明、口头摘要、自然语言概述当作“已完成报告”

### Phase 2：宿主消费报告

只有当 Phase 1 的完整报告已经产出后，宿主或后续 skill 才能消费该报告进入写码。

ImageRead **自身不进入 Phase 2**；本包职责止于完整报告。

## 硬规则

- 禁止未读图写参数表；禁止「大约」当实测  
- 猜测必须【暂时猜测数值占用】  
- 有图必须先有【识图场景】  
- 阴影只记不当描边  
- 设计 px + 注明 scale；用户口头 px 优先  
- **禁止**本包识图流水线内写码  

## 报告完成门控（强制 · 写 UI 前）

如果你的目标包含“实现图内 UI / 写代码 / 报几何 / 修改布局”，在任何代码、实现描述、布局方案之前，必须先输出完整 ImageRead 报告。

报告必须至少包含下列区块标题（原样）：

- `【识图场景】`
- `【像素参数表】`
- `【视觉参数表】`
- `【结构专表】` 或 `不适用`
- `【需确认】`
- `【差异 / 不确定】`
- `【暂时猜测数值占用】` 或 `无`

未包含任一项：视为“未执行完整 SOP（gates → classify → geometry → structure → visual → output）”，**必须停止**，并仅输出：

```text
【ImageRead未完成】缺少：<区块名列表>
请先补执行完整报告产出，再继续写 UI。
```

若在完整报告前已经输出过实现代码、实现方案、控件改法、布局改法，视为**流程失败**；不得继续补救式实现，必须回退到 Phase 1 重新产出完整报告。

禁止把“本 SKILL.md 的总说明”当作完成报告；禁止用近似摘要跳过参数表/场景码。

## 安装

```text
npx skills add <org>/agent-skills-image-read --skill image-read
```

装入各平台 `.cursor/skills/` / `.agents/skills/` 等后 **自动匹配** 识图场景。嵌套子 skill 仍 `metadata.internal: true`，仅本包自动挂载。

# agent-skills-image-read

**Agent Skills 安装源 · ImageRead**：**像素级读图报告**，可直接根据图片分析并输出 UI 结构，以及各元素之间的像素大小，用于 agent 根据图片生成或对齐对应 UI，防止 AI 幻觉导致的误差。**Python 为测量工具**；测图后端按准确可用选择（**不绑定 cv2**），失败先自动修，无后端则停止。**自动挂载于位图**。**有足够的 Figma MCP 额度，可不用本包**。

- **对外产品名：** ImageRead  
- **安装 id / 目录名：** `image-read`（Agent Skills 要求 `name` 与文件夹一致，仅小写+连字符）  
- **本包只识图**：输出结构化参数报告后职责结束。不写代码、不调度写码 skill、不含 `specializations/`。

本仓 **不含项目绑定**（无业务路径 / 主题色名 / 组件表），也 **不含写图语言特化**。写码由宿主 SOP / 独立语言 skill（如 `qt-quick-qml`）消费报告完成。

```text
agent-skills-image-read/
├── README.md
└── skills/
    └── image-read/                      ← 唯一可安装 skill（ImageRead）
        ├── SKILL.md
        ├── classify/ gates/ geometry/ structure/ visual/ output/
        └── scripts/                     ← 探测：Python + 任一可用测图后端
```

安装后落点因平台而异；skill 正文只按 **相对路径** 调度。

## 流水线

```text
ImageRead（默认/唯一必选）  →  结构化像素报告（可视参数表）
                              →  本包职责结束
                              →  下游 LLM / 人工 / 任意栈自行读表理解并写码
```

**只识图 / 评审**：ImageRead 报告即交付，参数表供 LLM 直接消费。

**要写码**：不在本仓。宿主 SOP 读仓库推断 GUI 栈，再进入独立写码 skill 或直接按参数表落码。

`npx skills add … --list` 应只看到 **`image-read`**。

## 一键安装

```bash
npx skills add <org>/agent-skills-image-read --list

npx skills add <org>/agent-skills-image-read --skill image-read -a claude-code -y
npx skills add <org>/agent-skills-image-read --skill image-read -a cursor -y
npx skills add <org>/agent-skills-image-read --skill image-read -a copilot -y
npx skills add <org>/agent-skills-image-read --skill image-read -a codex -y

npx skills add <org>/agent-skills-image-read --skill image-read -a claude-code -g -y
```

`-a` 见 [skills CLI agents](https://github.com/vercel-labs/skills)。未列出的平台：拷贝 `skills/image-read/` 到该平台 skills 根即可。


## 一次对齐与原图默认（硬约定）

- **默认**：开发提供的位图 = **无损原图**。禁止以有损/信息不足为由少测，或要求开发二次确认再对齐。
- **测量范围**：`layout-only`（只要整体布局，不拆内部控件）/ 点名子集 / 整页实现。**整页截图 ≠ 全展开叶子**。
- **任务合同「一次对齐」**：由**宿主 SOP**整链执行（参数→落码→自校）。ImageRead **只交识图前置报告**，不写码、不宣称对齐完成。
- **报告优先**：位图任务必须先对用户输出【像素参数表】；禁止以「尽快可见效果/先做 UI」跳过报告去写码。

## 宿主怎么接

1. `npx skills add … --skill image-read` → 装入 `.cursor/skills/` 等，**自动匹配**识图场景。  
2. **只识图 / 评审**：ImageRead 出报告即止。  
3. **要写码**：宿主 SOP 或独立语言 skill 消费参数表；可选 `project-bindings.md`（写码阶段，不在本仓）。  
4. Mojhon 等已有项目：`design-to-qml` 胶水 + bindings 仍负责 QML 落地与资源门控；写码用 `qt-quick-qml`（不嵌在本包内）。

## 刻意不做

- 不内嵌任何写图语言特化（已移除 `specializations/`）  
- ImageRead 不写代码、不调度写码 skill  
- 嵌套子 skill（classify/gates/…）仍 `internal`，仅顶层 `image-read` 自动挂载
- **测图临时 `.py` 同轮删除**：采像素优先不落盘；若写入 `.cursor/tmp_measure_*.py` 等，出数或失败后立刻删，禁止当工程文件留下/提交

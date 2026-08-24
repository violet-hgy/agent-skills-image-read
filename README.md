# agent-skills-image-read

**Agent Skills 安装源 · ImageRead**：**像素级读图报告**，防止 AI 幻觉。**Python 为测量运行时**；测图后端按准确可用选择（**不绑定 cv2**），失败先自动修，无后端则停止。**自动挂载于位图**。**纯 Figma 不用本包**。

- **对外产品名：** ImageRead  
- **安装 id / 目录名：** `image-read`（Agent Skills 要求 `name` 与文件夹一致，仅小写+连字符）  
- **语言写图：** 可选特化，不是本源必装能力。当前附带 `specializations/qml` 作为一种兼容项；宿主不写 QML 则不必 Read。

本仓 **不含项目绑定**（无业务路径 / 主题色名 / 组件表）。

```text
agent-skills-image-read/
├── README.md
└── skills/
    └── image-read/                      ← 唯一可安装 skill（ImageRead）
        ├── SKILL.md
        ├── classify/ gates/ geometry/ structure/ visual/ output/
        ├── scripts/                     ← 探测：Python + 任一可用测图后端
        └── specializations/             ← 可选 · 语言特化（非识图流水线）
            └── qml/                     ← 兼容项：消费报告 → QML
                ├── SKILL.md
                └── implement/ verify/
```

安装后落点因平台而异；skill 正文只按 **相对路径** 调度。

## 流水线

```text
ImageRead（默认/唯一必选）  →  结构化像素报告（可视参数表）
                              →  本包职责结束
                              →  下游 LLM / 人工 / 任意栈自行读表理解并写码

写图（可选）  →  specializations/<lang>/  +  宿主 project-bindings
                宿主 SOP 读仓库推断 GUI 栈；栈匹配且要写码时才进入
```

**只识图 / 评审**：ImageRead 报告即交付，参数表供 LLM 直接消费。

**要写码**：不必用户声明语言；宿主 SOP 读项目（`qml/`、`*.tsx`、`CMakeLists` 等）推断栈。匹配已附带特化则进入 `specializations/<lang>/`；否则 LLM 读参数表按项目代码写码。

`npx skills add … --list` 应只看到 **`image-read`**。QML 带子目录 `metadata.internal: true`，不当独立安装项。

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
- **多元素**：先【元素清单】再逐项实测；【测量完备性】含猜测占比门控。
- **一次对齐**：宿主写码同轮自校；推荐收尾语 `【一次对齐完成】`（也可用 `【对齐完成】`）。

## 宿主怎么接

1. `npx skills add … --skill image-read` → 装入 `.cursor/skills/` 等，**自动匹配**识图场景。  
2. **只识图 / 评审**：ImageRead 出报告即止。  
3. **要写码**：宿主 SOP 读仓库推断 GUI 栈；匹配 `specializations/<lang>/` 则进入；否则 LLM 读参数表写码。可选 `project-bindings.md`（写码阶段）。  
4. Mojhon 等已有项目：`design-to-qml` 胶水 + bindings 仍负责 QML 落地与资源门控。

## 刻意不做

- 不把任何一种写图语言当成安装源本体  
- ImageRead 不写代码；特化包不重新测像素  
- 嵌套子 skill（classify/gates/…）仍 `internal`，仅顶层 `image-read` 自动挂载

## 增加其它语言特化

在 `skills/image-read/specializations/<lang>/` 增加同结构（`SKILL.md` + `implement/` + `verify/`），契约：消费 ImageRead 报告 + 宿主 bindings。不要把新语言提升为仓名或顶层必装 skill。

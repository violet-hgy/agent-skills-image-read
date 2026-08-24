# Vision Skills（识图 + 写图）

符合 [Agent Skills](https://agentskills.io/specification) 与 [`npx skills`](https://github.com/vercel-labs/skills) 一键安装约定的能力仓。

**本仓只含可移植能力，不含任何项目绑定（无 `project-bindings` / 业务路径 / 主题色名）。**

```text
vision-sop-kit/
├── README.md
└── skills/                          ← CLI well-known 容器
    ├── image-read/                  ← 【识图】语言无关
    │   ├── SKILL.md
    │   ├── classify/ gates/ geometry/ structure/ visual/ output/
    └── write-qml/                   ← 【写图·QML】（未来可加 write-react 等）
        ├── SKILL.md
        ├── implement/
        └── verify/
```

## 流水线

```text
只识图  →  image-read → 结构化报告（可结束）

落 QML  →  宿主项目 SOP
           → image-read（有图时）
           → write-qml
           → 宿主自己的 project-bindings
```

## 一键安装（CLI）

在本机把本目录当成远程仓的本地克隆使用：

```bash
# 列出可装 skill
npx skills add "C:/Users/14403/Desktop/vision-sop-kit" --list

# 装到当前项目（写入 .agents/skills/）
npx skills add "C:/Users/14403/Desktop/vision-sop-kit" --skill image-read --skill write-qml -a cursor -y

# 或全局
npx skills add "C:/Users/14403/Desktop/vision-sop-kit" --skill image-read --skill write-qml -a cursor -g -y
```

推到 GitHub 后：

```bash
npx skills add your-org/vision-sop-kit --skill image-read --skill write-qml -a cursor
```

嵌套子目录（`classify/`、`implement/` 等）带 `metadata.internal: true`，避免被 CLI 当成独立可安装 skill。

## 宿主项目怎么接

1. 用 CLI 安装 `image-read` + `write-qml`，或拷贝到 `.cursor/portable-skills/` 由 SOP 显式 Read。  
2. 在**本仓库自己的** `.cursor/skills/` 写薄胶水 SOP + `project-bindings.md`（路径、主题、翻译、组件）。  
3. 胶水调度：有图 → Read `image-read` → 写码 → Read `write-qml` → 用本项目 bindings。

## 刻意不做

- 不包含 Mojhon / 其它业务的 `project-bindings`、intake、全量 measure  
- `image-read` 不写代码；`write-qml` 不重新测像素  
- 顶层 skill 均 `disable-model-invocation: true`，须由宿主 SOP 显式调度  

## 扩展其它语言写图

在 `skills/` 下新增 `write-<lang>/`（同结构：`SKILL.md` + `implement/` + `verify/`），保持与 `write-qml` 相同契约：消费 image-read 报告 + 宿主 bindings。

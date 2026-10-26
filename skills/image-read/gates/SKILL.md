---
name: image-read-gates
description: UI 解析的按需工具选择、调用条件、局部降级及证据校验。
disable-model-invocation: true
---

# Tools & Evidence Gates

这是工具层，不是 UI 解析的全局前置门槛。classify、结构观察和内置模式匹配可以先执行。
工具调用服务于布局分析：概览读取用于建立骨架；局部识别、节点细读和测量则依据骨架节点选择目标，并将结果回填原节点。
调用局部工具前明确所属区域、需要解决的字段和来源定位。骨架不清的部分先补结构证据，不盲目扩大叶子读取或测量范围。

## 何时使用工具

- 图片观察足以支持区域和控件识别时，直接解析。
- 需要精确截图尺寸、位置、间距、颜色或 alpha/墨迹框时，使用 Python 或其它准确可用的测量工具。
- 提供 Figma 链接/节点且有可用访问能力时，按来源适配读取节点；Figma 不要求 Python，也不要求先导出图片。
- 内置规则未覆盖布局或控件时，按 [../references/external-research.md](../references/external-research.md) 检索。
- 不为了工具齐全而安装依赖，不为了常见 UI 分类查询外部资料。

## Python 测量

保留真实 Python 3.10+ 及 Pillow / OpenCV 等后端的使用方式；不强制 cv2。
只在选择 Python 测量后探测环境，优先复用现有解释器和后端。

Windows：powershell -NoProfile -File "<skill-root>/scripts/probe-measure-env.ps1"

其它平台：python3 <skill-root>/scripts/probe-measure-env.py

默认探测不安装依赖。Python 可用且至少一个后端可用即可测量，不必修复未使用的可选后端。
确有测量需要且无可用后端时，在现有授权与环境规则允许下可用 -Repair（PowerShell）或 --repair（Python）尝试一次 Pillow 安装，然后重试。
不自动安装多套 OpenCV，不循环修复。需要其它专用后端时按具体任务选择。

探测成功只说明工具可用，仍需实际打开本轮输入并采样；不得拿探测结果当测量证据。
记录实际运行时、后端、输入及影响结果的缩放或阈值。一次性测量脚本优先 stdin 或命令行；落盘则放临时目录，结束后清理。

## 节点读取与局部降级

来源适配见 [../references/sources.md](../references/sources.md)。遵守当前环境相应工具及 skill 的调用要求。
节点无法访问时，说明读取缺口；如已有截图则继续截图解析。没有截图时不能声称看过界面。
测量工具失败时继续可支持的结构与样式分析，把依赖该工具的精确字段列为未完成。
若用户核心目标就是精确测量，报告应明确“精确测量未完成”，不能用结构分析宣称全部完成。

## 交付检查

精确字段有源属性、实测或可追溯推导；推断与未知已标注；关键来源冲突已保留。
完成度按范围、深度、请求字段及现有证据判断，不用统一猜测百分比或固定区块数替代检查。

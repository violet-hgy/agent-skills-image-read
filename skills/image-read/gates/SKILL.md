---
name: gates
description: 读图·环境与反幻觉（由 image-read 调度）。Python/Pillow 未就绪则整条 SOP 停止。
disable-model-invocation: true
metadata:
  internal: "true"
---

# Gates

**本步未放行，禁止进入 classify / geometry / structure / visual / output，禁止写 UI，禁止用估算填像素表。**

## 必需环境（测量栈）

| 项 | 要求 |
| --- | --- |
| Python | 3.10+ **真解释器**（绝对路径；禁止 `WindowsApps` 商店占位符） |
| Pillow | `from PIL import Image` 成功；用该解释器测图 |

**OpenCV (`cv2`) 不是必需项。** 默认用 Pillow 开图、量宽高、采样像素。

## 强制探测

宿主有 `env-detect` 时先跑其 `measure` profile。否则执行本包脚本：

```powershell
powershell -NoProfile -File "./scripts/probe-measure-env.ps1"
```

Unix：

```bash
python3 ./scripts/probe-measure-env.py
```

（先确保 `python3` 不是占位符；用脚本打印的绝对路径。）

输出须符合：

```text
OK|python|<abs>|...
OK|pillow|<ver>
FAIL|<tool>|<reason>
```

**全部必需项均为 OK 才放行。** 任一 `FAIL|python` 或 `FAIL|pillow` → **环境未就绪**。

## `cv2` 异常怎么处理

出现 `No module named cv2`、`DLL load failed`、`cv2` 崩溃等：

1. **不要**据此改用目测/估算填【像素参数表】  
2. **不要**把 cv2 失败当成可以跳过实测的理由  
3. 改用已 OK 的 **Pillow** 重测同一张图  
4. 仅当 Python 或 Pillow 也失败时，才判环境 FAIL 并停止  

禁止：Python/`cv2` 一报错 → 大部分数值标成猜测后继续写报告或写 UI。

## 环境 FAIL → 只修环境，不往下走

必须停止后续 SOP，并**只**输出：

```text
【ImageRead环境未就绪】
- FAIL：<python 和/或 pillow 的原因>
- 已尝试：<绝对路径 / pip install Pillow 一次 / 是否误用 WindowsApps>
- 下一步：先修好 Python+Pillow，再重新执行 ImageRead
- 本轮禁止：classify 及之后、估算填表、写 UI
```

允许的修复（修好后须重新探测为 OK，再从头执行 ImageRead）：

- 安装 Python 3.10+，或设置 `PYTHON_EXE` 为解释器全路径  
- 丢弃商店占位符，改用真实解释器  
- `python -m pip install Pillow` **一次**；仍失败则停止并报告  
- 不要为测图去修 `cv2`；测图路径切到 Pillow  

**禁止**在 FAIL 后：

- 继续 geometry/visual「先估个数」  
- 产出带大量【暂时猜测数值占用】的完整报告并宣称 Phase 1 完成  
- 写 UI / 近似还原  

【暂时猜测数值占用】仅用于**环境已 OK**、单字段采样不稳定，不得用于「Python 挂了所以整表估算」。

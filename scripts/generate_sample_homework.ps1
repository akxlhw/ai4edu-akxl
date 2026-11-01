# 示例作业图生成脚本（V0.1 mock 闭环）
# 产出：entry/src/main/resources/base/media/sample_homework.png
#
# ⚠️ 坐标同源约定（docs/superpowers/specs/2026-10-31-v0.1-mock-loop-design.md 第 6 节）：
#    本脚本的布局常量必须与 entry/src/main/ets/service/mock/MockData.ets 的 MockLayout
#    保持一致。修改任何一侧必须同步另一侧，否则示例图上的标注框将与内容错位。
#
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File scripts/generate_sample_homework.ps1

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

# ---- 布局常量（与 MockData.ets MockLayout 同源，勿单独修改） ----
$REGION_X  = 0.06   # 题行区域 x（归一化）
$REGION_W  = 0.88   # 题行区域宽（归一化）
$ROW_Y0    = 0.07   # 第一行 y（归一化）
$ROW_STEP  = 0.148  # 行距（归一化）
$ROW_H     = 0.115  # 行高（归一化）

# ---- 内容（与 MockHomeworkData.STEMS / STUDENT_ANSWERS 同源） ----
# 6 道三年级口算：1-4 正确，5 错误（74，应为 84），6 字迹潦草（UNREADABLE）
$stems   = @('23 + 45 =', '6 × 7 =', '81 − 19 =', '8 × 9 =', '56 + 28 =', '64 ÷ 8 =')
$answers = @('68', '42', '62', '72', '74', '8')

# ---- 画布 ----
$W = 800
$H = 1000
$bmp = [System.Drawing.Bitmap]::new($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::White)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# 标题（印刷体）
$fontTitle  = [System.Drawing.Font]::new('Microsoft YaHei', 22)
# 题干（印刷体，模拟试卷排版）
$fontStem   = [System.Drawing.Font]::new('SimSun', 34)
# 学生答案（楷体，模拟手写）
$fontAnswer = [System.Drawing.Font]::new('KaiTi', 36)
$brush = [System.Drawing.Brushes]::Black

$fmtLeft = [System.Drawing.StringFormat]::new()
$fmtLeft.Alignment = [System.Drawing.StringAlignment]::Near
$fmtLeft.LineAlignment = [System.Drawing.StringAlignment]::Center
$fmtCenter = [System.Drawing.StringFormat]::new()
$fmtCenter.Alignment = [System.Drawing.StringAlignment]::Center
$fmtCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

# 顶部标题（位于第一行区域 y0=70 之上，不与题行重叠）
$titleRect = [System.Drawing.RectangleF]::new(0, 12, $W, 48)
$g.DrawString('三年级数学 口算练习（示例）', $fontTitle, $brush, $titleRect, $fmtCenter)

for ($i = 0; $i -lt $stems.Count; $i++) {
    $rowX = [double]($REGION_X * $W)
    $rowY = [double](($ROW_Y0 + $i * $ROW_STEP) * $H)
    $rowW = [double]($REGION_W * $W)
    $rowH = [double]($ROW_H * $H)

    # 题干（含题号，占行左侧 65%）
    $stemRect = [System.Drawing.RectangleF]::new($rowX + 8, $rowY, [double]($rowW * 0.65), $rowH)
    $g.DrawString(("{0}. {1}" -f ($i + 1), $stems[$i]), $fontStem, $brush, $stemRect, $fmtLeft)

    # 学生答案（行右侧）
    $ansX = [double]($rowX + $rowW * 0.70)
    $ansRect = [System.Drawing.RectangleF]::new($ansX, $rowY, [double]($rowW * 0.28), $rowH)
    $g.DrawString($answers[$i], $fontAnswer, $brush, $ansRect, $fmtLeft)

    # 第 6 题：字迹潦草 —— 重描一遍（偏移）+ 两条涂改斜线，模拟 UNREADABLE
    if ($i -eq 5) {
        $scribbleRect = [System.Drawing.RectangleF]::new($ansX + 4, $rowY + 4, [double]($rowW * 0.28), $rowH)
        $g.DrawString($answers[$i], $fontAnswer, $brush, $scribbleRect, $fmtLeft)
        $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::Gray, 3)
        $cy = $rowY + $rowH / 2
        $g.DrawLine($pen, [float]($ansX - 6), [float]($cy - 18), [float]($ansX + 90), [float]($cy + 14))
        $g.DrawLine($pen, [float]($ansX + 2), [float]($cy + 22), [float]($ansX + 96), [float]($cy - 10))
        $pen.Dispose()
    }
}

$outDir = Join-Path $PSScriptRoot '..\entry\src\main\resources\base\media'
$outPath = Join-Path $outDir 'sample_homework.png'
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Host "saved: $outPath ($W x $H)"

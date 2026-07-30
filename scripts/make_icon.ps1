Add-Type -AssemblyName System.Drawing

$size = 1024
$primary = [System.Drawing.Color]::FromArgb(255, 0x26, 0x61, 0x9B)   # #26619B Azure Precision primary
$white = [System.Drawing.Color]::White

function New-RoundedRectPath {
    param($x, $y, $w, $h, $r)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function Draw-DocumentGlyph {
    param($g, $cx, $cy, $scale, $glyphColor, $foldColor)
    # Page dimensions before scale, centered around (0,0)
    $pw = 460; $ph = 620; $fold = 130; $r = 36
    $x0 = -$pw/2; $y0 = -$ph/2

    $m = New-Object System.Drawing.Drawing2D.Matrix
    $m.Translate($cx, $cy)
    $m.Scale($scale, $scale)
    $g.Transform = $m

    # Page body (rounded rect) with folded top-right corner cut off
    $page = New-RoundedRectPath -x $x0 -y $y0 -w $pw -h $ph -r $r
    $foldPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $foldPath.AddPolygon(@(
        (New-Object System.Drawing.PointF(($x0+$pw-$fold),$y0)),
        (New-Object System.Drawing.PointF(($x0+$pw),$y0)),
        (New-Object System.Drawing.PointF(($x0+$pw),($y0+$fold)))
    ))
    $region = New-Object System.Drawing.Region($page)
    $region.Exclude($foldPath)
    $brush = New-Object System.Drawing.SolidBrush($glyphColor)
    $g.FillRegion($brush, $region)

    # Folded corner triangle, in the background tint, plus its own diagonal edge
    $foldTri = New-Object System.Drawing.Drawing2D.GraphicsPath
    $foldTri.AddPolygon(@(
        (New-Object System.Drawing.PointF(($x0+$pw-$fold),$y0)),
        (New-Object System.Drawing.PointF(($x0+$pw),($y0+$fold))),
        (New-Object System.Drawing.PointF(($x0+$pw-$fold),($y0+$fold)))
    ))
    $foldBrush = New-Object System.Drawing.SolidBrush($foldColor)
    $g.FillPath($foldBrush, $foldTri)

    # Text lines inside the page
    $lineBrush = New-Object System.Drawing.SolidBrush($foldColor)
    $lineHeight = 34
    $gap = 78
    $lx = $x0 + 70
    $ly = $y0 + 200
    $widths = @(320, 320, 220, 320, 160)
    foreach ($w in $widths) {
        $g.FillRectangle($lineBrush, $lx, $ly, $w, $lineHeight)
        $ly += $gap
    }

    $g.ResetTransform()
    $page.Dispose(); $foldPath.Dispose(); $region.Dispose(); $brush.Dispose()
    $foldTri.Dispose(); $foldBrush.Dispose(); $lineBrush.Dispose()
}

# ---- 1. Legacy / main icon: full-bleed blue square, white glyph, no corner radius
#         (Android launcher applies its own mask; leaving it square avoids double-rounding) ----
$bmp1 = New-Object System.Drawing.Bitmap($size, $size)
$g1 = [System.Drawing.Graphics]::FromImage($bmp1)
$g1.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g1.Clear($primary)
Draw-DocumentGlyph -g $g1 -cx ($size/2) -cy ($size/2) -scale 1.0 -glyphColor $white -foldColor $primary
$g1.Dispose()
$bmp1.Save("assets/icon/icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp1.Dispose()

# ---- 2. Adaptive icon foreground: transparent bg, glyph shrunk into the ~66% safe zone ----
$bmp2 = New-Object System.Drawing.Bitmap($size, $size)
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g2.Clear([System.Drawing.Color]::Transparent)
Draw-DocumentGlyph -g $g2 -cx ($size/2) -cy ($size/2) -scale 0.62 -glyphColor $white -foldColor $primary
$g2.Dispose()
$bmp2.Save("assets/icon/icon_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp2.Dispose()

Write-Output "Icon assets written to assets/icon/"


# ----------------------------------------------
# wiiremoteサンプル
# ----------------------------------------------

require 'dxruby'
require 'wiiflashclient'


# サイズの増分と色の明度を計算
def convert(wx, wy, size, c)
  d     = wx * size / 2.5
  cl    = Marshal.load(Marshal.dump(c))   # 色配列の内容をコピー(cloneや dupでは浅いコピー)
  cr    = Marshal.load(Marshal.dump(c))   # 色配列の内容をコピー(cloneや dupでは浅いコピー)
  cl[0] = 128 + 64 * wy                   # 明度(明)
  cr[0] = 128 - 64 * wy                   # 明度(暗)
  return [d, cl, cr]
end


# WiiFlashClientの生成
wii = WiiFlashClient.new

# WiiRemoteを取得
wiiremote = wii.controller(0)

# 四角形の情報
colors = [C_RED, C_GREEN, C_BLUE, C_YELLOW]     # 色の変化順
c      = 2                                      # 最初の色(配列の添字)
size   = 100                                    # 四角形のサイズ

# ウィンドウの属性情報
Window.width   = 360                            # ウィンドウの幅
Window.height  = 240                            # ウィンドウの高さ
Window.bgcolor = C_WHITE                        # 背景色

Window.loop do

  # wiiリモートのステータス更新
  wiiremote.update

  # Wiiリモコンの状態に応じて左右の四角形の情報を算出
  d, cl, cr = convert(wiiremote.x, wiiremote.y, size, colors[c]);

  # 左右の四角形を描画
  xl = Window.width  / 2 - (size + d)           # 左側四角形の起点 x座標
  xr = Window.width  / 2 + d                    # 右側四角形の起点 x座標
  yl = Window.height / 2 - (size / 2 + d)
  yr = Window.height / 2 - (size / 2 - d)
  Window.drawBoxFill(xl, yl, xl + size + (d * 2), yl + size + (d * 2), cl)
  Window.drawBoxFill(xr, yr, xr + size - (d * 2), yr + size - (d * 2), cr)

  # [A]ボタンが押されたら色を変える
  if wiiremote.button_a and not wiiremote.last_a
    c += 1
    c = 0 if c == colors.size
  end

  # [B]ボタンまたは [ESC]キーが押されたら終了
  break if wiiremote.button_b
  break if Input.key_push?(K_ESCAPE)

end


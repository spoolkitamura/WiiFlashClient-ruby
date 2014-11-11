
require 'dxruby'
require 'wiiflashclient'

# wiifactory.rb 単体テスト用


# ステータス表示
def display(wiiremote)
  return if not wiiremote.alive?             # 有効でないデバイスの場合は何もしない

  id = wiiremote.device_id                   # デバイス番号

  font_size = 16
  font = Font.new(font_size, 'ＭＳ ゴシック')

  Window.draw_font( 10,  font_size * 10 * id + 10 + font_size * 0, "id:        #{wiiremote.device_id}",                    font)
  Window.draw_font( 10,  font_size * 10 * id + 10 + font_size * 1, "battery:   #{wiiremote.battery_level / 200.0 * 100}%", font)
  Window.draw_font( 10,  font_size * 10 * id + 10 + font_size * 2, "x:         #{wiiremote.x}",                            font)
  Window.draw_font( 10,  font_size * 10 * id + 10 + font_size * 3, "y:         #{wiiremote.y}",                            font)
  Window.draw_font( 10,  font_size * 10 * id + 10 + font_size * 4, "z:         #{wiiremote.z}",                            font)
  Window.draw_font( 10,  font_size * 10 * id + 10 + font_size * 5, "extention: #{wiiremote.extension_type}",               font)

  Window.draw_font( 10 + font_size / 2 *  0, font_size * 10 * id + 10 + font_size * 7, "1",       font) if wiiremote.button_1
  Window.draw_font( 10 + font_size / 2 *  1, font_size * 10 * id + 10 + font_size * 7, "2",       font) if wiiremote.button_2
  Window.draw_font( 10 + font_size / 2 *  2, font_size * 10 * id + 10 + font_size * 7, "A",       font) if wiiremote.button_a
  Window.draw_font( 10 + font_size / 2 *  3, font_size * 10 * id + 10 + font_size * 7, "B",       font) if wiiremote.button_b
  Window.draw_font( 10 + font_size / 2 *  4, font_size * 10 * id + 10 + font_size * 7, "+",       font) if wiiremote.button_plus
  Window.draw_font( 10 + font_size / 2 *  5, font_size * 10 * id + 10 + font_size * 7, "-",       font) if wiiremote.button_minus
  Window.draw_font( 10 + font_size / 2 *  6, font_size * 10 * id + 10 + font_size * 7, "H",       font) if wiiremote.button_home
  Window.draw_font( 10 + font_size / 2 *  7, font_size * 10 * id + 10 + font_size * 7, "U",       font) if wiiremote.button_up
  Window.draw_font( 10 + font_size / 2 *  8, font_size * 10 * id + 10 + font_size * 7, "D",       font) if wiiremote.button_down
  Window.draw_font( 10 + font_size / 2 *  9, font_size * 10 * id + 10 + font_size * 7, "R",       font) if wiiremote.button_right
  Window.draw_font( 10 + font_size / 2 * 10, font_size * 10 * id + 10 + font_size * 7, "L",       font) if wiiremote.button_left
end


# WiiFlashClientの生成
wii = WiiFlashClient.new

# WiiRemoteを取得
wiiremote0 = wii.controller(0)               # デバイス番号0
wiiremote1 = wii.controller(1)               # デバイス番号1
#wiiremote2 = wii.controller(2)               # デバイス番号2
#wiiremote3 = wii.controller(3)               # デバイス番号3

Window.height = 650
Window.loop do
  wii.update                                          # ステータス更新

  #puts "device(s): #{wiiremotefactory.count}"         # 接続されている WiiRemoteの本数
  wii.__status                                        # ステータス確認

  wiiremote0.vibrate_on  if     wiiremote0.button_b   # Bボタン押下でバイブレーションON  (デバイス0)
  wiiremote0.vibrate_off if not wiiremote0.button_b   # Bボタン解除でバイブレーションOFF (デバイス0)

  wiiremote1.vibrate_on  if     wiiremote1.button_b   # Bボタン押下でバイブレーションON  (デバイス1)
  wiiremote1.vibrate_off if not wiiremote1.button_b   # Bボタン解除でバイブレーションOFF (デバイス1)

  display(wiiremote0)
  display(wiiremote1)
  #display(wiiremote2)
  #display(wiiremote3)

  break if Input.key_push?(K_ESCAPE)
end


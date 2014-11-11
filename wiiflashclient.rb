=begin

  WiiFlashServer経由で WiiRemote(Wiiリモコン)を使うためのクラス

  Copyright (c) 2014 spoolkitamura

  Released under the MIT License.
  http://opensource.org/lisenses/mit-license.php

  Version :
    0.2.1 (2014/10/26)
    0.2.0 (2014/10/10)
    0.1.0 (2014/09/23)

  Synopsis :
    wii = WiiFlashClient.new
    wiiremote = wii.controller(0)
    wiiremote.update
    puts "x=#{wiiremote.x}  y=#{wiiremote.y}  z=#{wiiremote.z}"
    puts "[A]" if wiiremote.button_a

=end


require 'socket'
require 'thread'

# WiiRemoteクラス
class WiiRemote

  # アクセサ
  attr_reader :device_id,
              :battery_level,
             #:button_state,
              :x,
              :y,
              :z,
              :extension_type,
              :button_1,
              :button_2,
              :button_a,
              :button_b,
              :button_plus,
              :button_minus,
              :button_home,
              :button_up,
              :button_down,
              :button_right,
              :button_left,
              :last_1,
              :last_2,
              :last_a,
              :last_b,
              :last_plus,
              :last_minus,
              :last_home,
              :last_up,
              :last_down,
              :last_right,
              :last_left

  # コンストラクタ
  def initialize(device_id, buffer, queue)
    #
    #  引数 :
    #   id     ... デバイス番号(0～3)
    #   buffer ... 受信用バッファ(ハッシュ)
    #   queue  ... 送信用キュー
    #
    @device_id = device_id
    @buffer    = buffer
    @queue     = queue
    @rumble    = false              # バイブレーションOFF
  end

  # ステータスの更新
  def update
    return if @buffer[:data] == ''  # バッファが空の場合は何もしない

    # 前回のボタン押下状態の保持
    @last_1     = @button_1
    @last_2     = @button_2
    @last_a     = @button_a
    @last_b     = @button_b
    @last_plus  = @button_plus
    @last_minus = @button_minus
    @last_home  = @button_home
    @last_up    = @button_up
    @last_down  = @button_down
    @last_right = @button_right
    @last_left  = @button_left

    (
     id,                            # デバイス番号(0～3)
     @battery_level,                # バッテリーレベル
     @button_state,                 # ボタンステータス
     @x,                            # X
     @y,                            # Y
     @z,                            # Z
     @extension_type                # エクステンションタイプ
    ) = @buffer[:data].unpack("CCngggC")
    # C: 8bit 符号なし整数
    # n: ビッグエンディアンの 16bit 符号なし整数
    # g: ビッグエンディアンの 単精度浮動小数点数

    # 各ボタンの押下状況
    @button_1        = (((@button_state >> 15) & 1) == 1)     # [１]
    @button_2        = (((@button_state >> 14) & 1) == 1)     # [２]
    @button_a        = (((@button_state >> 13) & 1) == 1)     # [Ａ]
    @button_b        = (((@button_state >> 12) & 1) == 1)     # [Ｂ]
    @button_plus     = (((@button_state >> 11) & 1) == 1)     # [＋]
    @button_minus    = (((@button_state >> 10) & 1) == 1)     # [－]
    @button_home     = (((@button_state >>  9) & 1) == 1)     # [HOME]
    @button_up       = (((@button_state >>  8) & 1) == 1)     # [↑]
    @button_down     = (((@button_state >>  7) & 1) == 1)     # [↓]
    @button_right    = (((@button_state >>  6) & 1) == 1)     # [→]
    @button_left     = (((@button_state >>  5) & 1) == 1)     # [←]
  end

  # バイブレーション開始
  def vibrate_on
    return if @queue.size > 2                # キューに一定以上のリクエストを渡さない(振動しっぱなしへの暫定対処)
    return if @rumble == true
    @rumble = true
    h = ["%02X" % @device_id]                # デバイス番号を 16進数文字列に変換して配列に格納
    @queue.push(h.pack("H*") + "\x72\x31")
  end

  # バイブレーション終了
  def vibrate_off
    return if @rumble == false
    @rumble = false
    h = ["%02X" % @device_id]                # デバイス番号を 16進数文字列に変換して配列に格納
    @queue.push(h.pack("H*") + "\x72\x30")
  end

  # 活性/非活性チェック
  def alive?
    return false if @buffer[:data] == ''     # 非活性状態(未接続)
    return true  if @buffer[:data] != ''     # 活性状態  (接続ずみ)
  end

  # ステータス表示(debug)
  def __status
    if @buffer[:data] == ''
      printf "%2d ---- ------ ---------- ---------- ---------- --\n",
                                  @device_id
    else
      printf "%2d %4d %6d %+10.7f %+10.7f %+10.7f %2d\n", 
                                  @device_id,
                                  @battery_level,
                                  @button_state,
                                  @x,
                                  @y,
                                  @z,
                                  @extension_type
    end
  end
end


# WiiFlashClientクラス
class WiiFlashClient

  # コンストラクタ
  def initialize
    # リスト
    @wiiremotes = []                              # WiiRemote
    @buffers    = []                              # 受信用バッファ(ボタン押下状況など)
    @queue      = Queue.new                       # 送信用キュー  (バイブレーション制御)

    # TCPソケットのオープン
    @sock = TCPSocket.open('localhost', 0x4A54)   # IPv4の場合
   #@sock = TCPSocket.open('::1', 0x4A54)         # IPv6の場合

    4.times do
      id = @wiiremotes.size
      @buffers    << {:data => ''}   # WiiRemoteBuffer.new
      @wiiremotes << WiiRemote.new(id, @buffers[id], @queue)
    end

    # 受信用スレッドの開始
    #   デバイス番号ごとの受信用バッファにデータをセット
    #   (各デバイスの updateメソッドで参照される)
    thread_read = Thread.start do
      loop do
        data = @sock.read(80)
        id = data.unpack("C")[0]                  # WiiRemoteのデバイス番号(0～3)
        @buffers[id][:data] = data[0..19]         # 当該デバイスのバッファにデータをセット(先頭20バイト分[暫定])
      end
    end
    sleep 0.1                                     # ウェイト(必須)

    # 送信用スレッドの開始
    #   デバイスからセットされたキューの内容をサーバ(WiiFlashServer)に送信
    thread_write = Thread.start do
      loop do
        resource = @queue.pop
        @sock.write(resource)                     # バイブレーション制御
        sleep 0.125                               # ウェイト
                                                  #  (バイブレーション処理に 120ms程度かかるとの情報あり)
                                                  #  (ウェイトの多寡により、WiiRemoteが複数本の場合などで取りこぼしや反応遅延が生じる)
      end
    end
  end

  # 利用可能な WiiRemoteの本数を取得
  def count
    n = 0
    @wiiremotes.each do |wiiremote|
      n += 1 if wiiremote.alive?
    end
    return n
  end

  # 指定したデバイス番号の WiiRemoteを取得
  def controller(id)
    return @wiiremotes[id]
  end

  # WiiRemoteのステータスを更新
  def update
    @wiiremotes.each do |wiiremote|
      wiiremote.update
    end
  end

  # ステータス表示(debug)
  def __status
    @wiiremotes.each do |wiiremote|
      wiiremote.__status
    end
    puts
  end

end


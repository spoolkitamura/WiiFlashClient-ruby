
wiiflashclient.rb
=================

■概要
------

WiiFlashServer(<https://github.com/spoolkitamura/WiiFlashServer-TR)と
ソケット通信をおこない、Rubyのアプリケーションから Wiiリモコンの状態を
取得できるようにするためのクラスライブラリです。

■インストール手順
------------------

コマンドプロンプトから、同梱の install.rbを実行してください。  
(> ruby install.rb)

■アンインストール手順
----------------------

コマンドプロンプトから、同梱の uninstall.rbを実行してください。  
(> ruby uninstall.rb)

■使用例
--------

>  wii = WiiFlashClient.new  
>  wiiremote = wii.controller(0)  
>  wiiremote.update  
>  puts "x=#{wiiremote.x}  y=#{wiiremote.y}  z=#{wiiremote.z}"  
>  puts "[A]" if wiiremote.button_a  


■サンプルプログラム
--------------------

 1. .\sample\ut_wiiflashclient.rb (DXRuby使用)  
       - wiiflashclientの加速度センサーの値やボタン押下状況などが表示されます

 2. .\sample\sample_wiiflashclient.rb (DXRuby使用)  
       - X軸の傾きや Y軸の傾きに応じで図形の大きさや色の明度が変わります
       - [A]ボタンの押下によって図形の色相が変わります(青→黄→赤→緑)
       - [B]ボタンの押下で終了します

■ドキュメント
--------------

makerdoc.cmdを実行すると、rdocによって .\docディレクトリ以下にドキュメントが作成されます。  
クラス、属性、メソッドなどの一覧として参考にしてください。

■環境および前提条件
--------------------

このクラスライブラリは WiiFlashServerとの間でソケット通信をおこなうものですので、
あらかじめ以下の環境が構築されていることを確認してください。

   - Blutoothによる Wiiリモコンと PCとの接続
   - WiiFlashServer(0.4.5-tr)による Wiiリモコンの認識

上記についての詳細は、同梱の PDFファイルを参照してください。

また、おもに DXRubyとあわせた利用シーンを想定しており、以下の環境で
動作確認をおこなっています。  

  - Windows7(32bit) SP1
  - Ruby 2.0.0p247
  - DXRuby 1.4.1

■ライセンス
------------

このクラスライブラリには、MITライセンスが適用されています。


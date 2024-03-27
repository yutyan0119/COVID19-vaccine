# COVID19-vaccine
![all.png](all.png)
## 1. What is this
東京大学の講義である現代経済理論(2021)の課題で行った新型コロナのワクチン接種に関する分析に使用したMATLABファイルなどをアップロードしてあります。
githubを使用するのは初めてなので、よくわかりません。
## 2. Code Description
簡単にコード(originalSIRD.m)の解説を載せておきます。はっきり言って可読性はないです。レポートの式と合わせてご参照願いたい…。

1から77行目までは初期状態を決めるためのパラメータです。いくつか使用していないものがありますが、いじりたいものはここでほとんどいじることが出来ます。

使用していないもの
- Vall
- VR_y,VR_e
- h_y
- VN_y_all,VN_e_all

お察しの良い方ならわかると思いますが、ワクチンの分配については手計算したスプレッドシートからデータを読み込む形式にしているため、MATLABのコードでこれを宣言する意味がなくなっています。

60行目から72行目は、ワクチンの配分についてのエクセルシート「vaccine.xlsx」を読み込み、その中のどのシートを利用するかについて宣言するのが62行目です。

基本的にワクチン分配の若者:老人の割合がx:yで、接種希望率がzのとき、シート名はx_y_zです。初期状態では20通り存在しています。vaccine.xlsxにシートを追加し、ご自分の好きなようにワクチン配分を決めることでワクチン接種を自由に変化させることが出来ます。

74～76行目は初期状態の設定です。

80行目から108行目までのfor文が今回使用したSIRD(V)モデルの部分になります。レポートの式の通りなのでそれを見て下さい。

110行目から135行目はグラフ描画についてのコードが書かれています。何もわからない場合は、「MATLAB plot」なりで検索すればだいたいわかります。

136行目以降は実は60行目から135行目の繰り返しを4回載せているだけです。

作成当初、一つのグラフに様々なワクチン配分の分析結果を掲載するということを想定していなかったため、このような形になっています。そのうち変更したいと思っています。

以上です。なにかご不明な点がありましたら、教えて下さい。

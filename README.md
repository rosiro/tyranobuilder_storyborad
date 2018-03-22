# tyranobuilder storyboard maker.

This program is a script that reads the scenario(.ks file) of tyranobuilder and creates a storyboard.
I started making it for use for debugging.

perl -Ilib script/generate_storyboard.pl project_directory generate_storyboard_directory

tyranobuilder storyboard makerはティラノビルダーのシナリオファイル(.ks)から絵コンテ(html)を生成するスクリプトです。  
一覧性に優れていないティラノビルダー画面や、スクリプトのままだとそのまま見てもわかりづらいです。  
シナリオが大きい、シナリオファイルが多い場合、デバッグが大変なので作りました。デバッグ用に閲覧用にご利用ください。

## 使い方
perl -Ilib script/generate_storyboard.pl ティラノビルダープロジェクトディレクトリ 絵コンテ出力ディレクトリ

なるだけ素のperlで動くようにモジュールの利用は控えています。

## Todo
- キャラクターがちゃんと退出しているかどうか
- シナリオが最後まで行くかどうか（途切れていないか）


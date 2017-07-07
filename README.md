# オブジェクト指向システム分析設計入門 to EPUB

[『オブジェクト指向システム分析設計入門』](http://aokilab.kyoto-su.ac.jp/documents/IntroductionToOOAOOD/index-j.html)のHTML版をEPUB3形式に変換します。

以下の点を改善してみました：

* 目次の表示
* 脚注をポップアップ

動作確認は、Mac OS XとiOSのiBooksのみで行なっています。

## 必要なもの

* pandoc
    * HTMLをEPUB3に変換します
* ruby
    * lib/itooaood-html.rbはHTMLを修正します
* curl
    * itooaood-epub.shスクリプトはHTMLと表紙をダウンロードします
* unzip
    * epubファイルを展開します
* zip
    * epubファイルを圧縮します

## 使い方

```
$ ./itooaood-epub.sh
$ open itooaood.epub
```

## 感謝

貴重なドキュメントを公開してくださった著者の青木淳さんに感謝します。


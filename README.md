# hs-soumu-code-normalizer

総務省が提供する全国地方公共団体コードのxlsからjsonに変換する。

- - - - -

NOTE: まず最初に、Numbersやその他ソフトウェアを使い、xlsをxlsxに変換してください。

- - - - -

```shell-session
$ stack exec soumu-code-normalizer -- ./000618153.xlsx
[
    {
        "code": "010006",
        "prefecture": "北海道",
        "city": null,
        "prefectureKana": "ﾎｯｶｲﾄﾞｳ",
        "cityKana": null
    },
    {
        "code": "011002",
        "prefecture": "北海道",
        "city": "札幌市",
        "prefectureKana": "ﾎｯｶｲﾄﾞｳ",
        "cityKana": "ｻｯﾎﾟﾛｼ"
    },
    # ...
]
```

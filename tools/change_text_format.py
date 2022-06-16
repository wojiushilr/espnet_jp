#!/usr/bin/env python3

"""Script to change text format correctly."""
import argparse
import re

def jp(x):
    if  not x:
        return ''
    else:
        x = x.lower()
        x = re.sub(r'[【】<>＜＞]', ' ', x)       # 【】の除去
        x = re.sub(r'[（）()]', ' ', x)     # （）の除去
        x = re.sub(r'[［］\[\]]', ' ', x)   # ［］の除去
        x = re.sub(r'[@＠]\w+', '', x)  # メンション の除去
        x = re.sub(r'　', ' ', x)  # 全角空白 の除去
        x = re.sub(r' ', '', x)  # 半角空白 の除去
        x = re.sub(r'^[RT]+','',x) #  RT-tags の除去
        x = re.sub('https?://[A-Za-z0-9./]+','',x) #  URLs の除去
        x = re.sub(r'[\n]', '', x) # 改行 の除去
    return x

def text_change(input, output):
    with open(input, mode="r") as f:
        s = f.readlines()
        s = list(map(jp, s))
        s = list(filter(lambda a: a != '', s))
    print(len(s))

    with open(output, mode="w+") as f:
        for i, item in enumerate(s):
            print(i, item)
            f.write(str(i) + " " + item + "\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()  # ArgumentParserクラスのインスタンスを生成
    parser.add_argument('input', type=str)  # コマンドライン引数の解析方法を追加（1）
    parser.add_argument('output', type=str)  # コマンドライン引数の解析方法を追加（2）
    args = parser.parse_args()  # コマンドライン引数の解析
    text_change(input = args.input, output = args.output)

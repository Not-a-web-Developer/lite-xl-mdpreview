# lite-xl-mdpreview
a markdown previewer for [LiteXL](https://github.com/lite-xl/lite-xl) using [luamd](https://github.com/bakpakin/luamd).

![preview of the previewer](assets/mdpreview.gif)

## Installation

clone the git repository into your lite-xl plugins folder like so:
```sh
git clone https://not-a-web-developer/lite-xl-mdpreview mdpreview
```
that's it.

**Note**: There's a bug with `luamd` which causes finnicky behaviour with fenced codeblocks that don't have a language specified in them; this causes the preview to fail. if this happens to you, you can try the `pandoc` branch instead.


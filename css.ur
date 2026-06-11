fun siteCss () : transaction page =
    returnBlob (textBlob CssAsset.content) (blessMime "text/css")

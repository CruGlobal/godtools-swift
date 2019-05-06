
these zip files should be downloaded for this version:

- kgp.zip - version_137: https://mobile-content-api.cru.org/translations/2140
- satisfied - version_76: https://mobile-content-api.cru.org/translations/2266
- fourlaws.zip: version_66: https://mobile-content-api.cru.org/translations/1945
- teachmetoshare.zip - version_28: https://mobile-content-api.cru.org/translations/2262

also:
- languages.json: https://mobile-content-api.cru.org/languages
- resources.json: https://mobile-content-api.cru.org/resources?include=latest-translations,attachments

banners should be downloaded like this:
1. search for the attr-banner and attr-banner-about id for the specified tool (e.g. "7" and "8" for "kgp" tool) in resources.json
2. search for:
  "id": "7",
  "type": "attachment"
download file from "attributes" and save it under "<sha256>.png" filename

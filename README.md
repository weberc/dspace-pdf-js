
# dspace-pdf-js

dspace-pdf-js is a DSpace theme that adds the mozilla pdf viewer pdf.js (https://mozilla.github.io/pdf.js/).

This theme adds a Preview for every pdf bitstream of an item if it is smaller than 5MB.

## Installation

 * Check out the source from github and copy it over your dspace-src directory.
 * Change your theme to 'dspace-pdf-js' by setting your theme entry to `<theme name="dspace-pdf-js" regex=".*" path="dspace-pdf-js/" />` in
  `dspace/config/xmlui.xconf`
 * Re-Build your DSpace with `mvn -U clean package -Dmirage2.on=true`

## Demo

For a demo visit https://oda.mfo.de/handle/mfo/552
#!/bin/sh

swift package --allow-writing-to-directory docs \
    generate-documentation --target TestDRS \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path "swift-test-drs" \
    --output-path docs
echo '<script>window.location.href += "/documentation/testdrs"</script>' > docs/index.html

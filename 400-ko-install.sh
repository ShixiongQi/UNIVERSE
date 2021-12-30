VERSION=0.7.1 # choose the latest version
OS=Linux     # or Darwin
ARCH=x86_64  # or arm64, i386, s390x
curl -L https://github.com/google/ko/releases/download/v${VERSION}/ko_${VERSION}_${OS}_${ARCH}.tar.gz | tar xzf - ko
sudo chmod +x ./ko
sudo install ko /usr/bin

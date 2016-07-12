FROM base/archlinux
MAINTAINER Spenser Reinhardt <spenserreinhardt@gmail.com>

# update system
RUN pacman -Sy --noconfirm && \
pacman -S --noconfirm archlinux-keyring && \
pacman -S --noconfirm pacman && \
pacman-db-upgrade && \
pacman -Syu --noconfirm && \
pacman -S --noconfirm wget curl git base-devel clang openssl python2 python cmake vim llvm

RUN cd /opt/ && \
git clone https://github.com/rust-lang/rust.git && \
cd rust && \
./configure --enable-clang --disable-libcpp --enable-optimize --disable-docs && \
make -j 2 && \
cd .. && \
export PATH=$PATH:/opt/rust/x86_64-unknown-linux-gnu/stage2/bin && \
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rust/x86_64-unknown-linux-gnu/stage2/lib/ && \
echo 'export PATH=$PATH:/opt/rust/x86_64-unknown-linux-gnu/stage2/bin' >> /root/.bashrc && \
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rust/x86_64-unknown-linux-gnu/stage2/lib/' >> /root/.bashrc

RUN cd /opt/ && \
git clone https://github.com/rust-lang/cargo && \
cd cargo && \
./configure --local-rust-root=/opt/rust/x86_64-unknown-linux-gnu/stage2/ --enable-optimize && \
make && \
export PATH=$PATH:/opt/cargo/target/x86_64-unknown-linux-gnu/release && \
echo 'export PATH=$PATH:/opt/cargo/target/x86_64-unknown-linux-gnu/release' >> /root/.bashrc

RUN cd /opt/ && \
VERSION=1.96b && \
wget http://lcamtuf.coredump.cx/afl/releases/afl-$VERSION.tgz && \
tar xf afl-$VERSION.tgz && \
cd afl-$VERSION && \
make && \
make install

WORKDIR /root/
ENTRYPOINT ["/usr/bin/bash"]
#docker build --force-rm --rm=true -t arch-rust-afl .

#!/bin/sh
# Ox518/cpuminer-opt optimized build script
# Targets yescryptr16 on x86_64 Linux (GitHub Actions / EPYC runners)

make distclean 2>/dev/null || true
rm -f config.status
./autogen.sh || echo "autogen done"

# -fno-semantic-interposition: allow inlining across TU boundaries (GCC 9+)
# -fomit-frame-pointer:        free one register for the hot loop
# -funroll-loops:              unroll the 16-iteration Salsa20 core
# -fno-plt:                    avoid PLT thunks for external calls
# These are all safe / non-breaking additions on top of upstream -O3 -march=native
CFLAGS="-O3 -march=native -Wall \
  -fno-semantic-interposition \
  -fomit-frame-pointer \
  -funroll-loops \
  -fno-plt" \
  ./configure --with-curl

make -j$(nproc)

# Strip debug symbols — smaller binary, faster cold load on Actions runners
strip -s cpuminer 2>/dev/null || true

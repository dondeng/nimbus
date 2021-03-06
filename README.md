# Nimbus: an Ethereum 2.0 Sharding Client for Resource-Restricted Devices

[![Windows build status (Appveyor)](https://img.shields.io/appveyor/ci/nimbus/nimbus/master.svg?label=Windows "Windows build status (Appveyor)")](https://ci.appveyor.com/project/nimbus/nimbus)
[![Build Status (Travis)](https://img.shields.io/travis/status-im/nimbus/master.svg?label=Linux%20/%20macOS "Linux/macOS build status (Travis)")](https://travis-ci.org/status-im/nimbus)
[![License: Apache](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Stability: experimental](https://img.shields.io/badge/stability-experimental-orange.svg)

Join the Status community chats:
[![Gitter: #status-im/nimbus](https://img.shields.io/badge/gitter-status--im%2Fnimbus-orange.svg)](https://gitter.im/status-im/nimbus)
[![Riot: #nimbus](https://img.shields.io/badge/riot-%23nimbus%3Astatus.im-orange.svg)](https://chat.status.im/#/room/#nimbus:status.im)
[![Riot: #dev-status](https://img.shields.io/badge/riot-%23dev--status%3Astatus.im-orange.svg)](https://chat.status.im/#/room/#dev-status:status.im)


## Rationale
[Nimbus: an Ethereum 2.0 Sharding Client](https://our.status.im/nimbus-for-newbies/). The code in this repository is currently focusing on Ethereum 1.0 feature parity, while all 2.0 research and development is happening in parallel in [nim-beacon-chain](https://github.com/status-im/nim-beacon-chain). The two repositories are expected to merge in Q1 2019.

## Development Updates

To keep up to date with changes and development progress, follow the [Nimbus blog](https://our.status.im/tag/nimbus/).

## Building & Testing

### Prerequisites

* A recent version of Facebook's [RocksDB](https://github.com/facebook/rocksdb/)
  * Compile [from source](https://github.com/facebook/rocksdb/blob/master/INSTALL.md) or use the package manager of your OS; for example, [Debian](https://packages.debian.org/search?keywords=librocksdb-dev&searchon=names&exact=1&suite=all&section=all), [Ubuntu](https://packages.ubuntu.com/search?keywords=librocksdb-dev&searchon=names&exact=1&suite=all&section=all), and [Fedora](https://apps.fedoraproject.org/packages/rocksdb) have working RocksDB packages
  * on Windows, you can [download pre-compiled DLLs](#windows)

* GNU make, Bash and the usual POSIX utilities

#### Obtaining the prerequisites through the Nix package manager

Users of the [Nix package manager](https://nixos.org/nix/download.html) can install all prerequisites simply by running:

``` bash
nix-shell nimbus.nix
```

### Build & Develop

#### POSIX-compatible OS

To build Nimbus (in "build/nimbus"), just execute:

```bash
make
```

Running `./build/nimbus --help` will provide you with a list of
the available command-line options. To start syncing with mainnet, just execute `./build/nimbus`
without any parameters.

To execute all tests:
```bash
make test
```

To pull the latest changes in all the Git repositories involved:
```bash
make update
```

To run a command that might use binaries from the Status Nim fork:
```bash
./env.sh vim
```

Our Wiki provides additional helpful information for [debugging individual test cases][1]
and for [pairing Nimbus with a locally running copy of Geth][2].

#### Windows

Install Mingw-w64 for your architecture using the "[MinGW-W64 Online
Installer](https://sourceforge.net/projects/mingw-w64/files/)" (first link
under the directory listing). Run it and select your architecture in the setup
menu ("i686" on 32-bit, "x86\_64" on 64-bit), set the threads to "win32" and
the exceptions to "dwarf" on 32-bit and "seh" on 64-bit. Change the
installation directory to "C:\mingw-w64" and add it to your system PATH in "My
Computer"/"This PC" -> Properties -> Advanced system settings -> Environment
Variables -> Path -> Edit -> New -> C:\mingw-w64\mingw64\bin (it's "C:\mingw-w64\mingw32\bin" on 32-bit)

Install [Git for Windows](https://gitforwindows.org/) and use a "Git Bash" shell to clone and build Nimbus.

If you don't want to compile RocksDB and SQLite separately, you can fetch pre-compiled DLLs with:
```bash
mingw32-make fetch-dlls
```

This will place the right DLLs for your architecture in the "build/" directory.

You can now follow those instructions in the previous section by replacing `make` with `mingw32-make` (regardless of your 32-bit or 64-bit architecture).

### Development tips

- you can switch the DB backend with a Nim compiler define:
  `-d:nimbus_db_backend=...` where the (case-insensitive) value is one of
  "rocksdb" (the default), "sqlite", "lmdb".

### Troubleshooting

Report any errors you encounter, please, if not [already documented](https://github.com/status-im/nimbus/issues)!


Sometimes, the build will fail even though the latest CI is green - here are a few tips to handle this:

#### Using the Makefile

* Turn it off and on again:
```bash
make clean update
```

#### Using Nimble directly

* Wrong Nim version
  * We depend on many bleeding-edge features - Nim regressions often happen
  * Use the [Status fork](https://github.com/status-im/Nim) of Nim
* Wrong versions of dependencies
  * nimble dependency tracking often breaks due to its global registry
  * wipe the nimble folder and try again
* C compile or link fails
  * Nim compile cache is pretty buggy and sometimes will fail to recompile
  * wipe your nimcache folder

## License

Licensed and distributed under either of

* MIT license: [LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT

or

* Apache License, Version 2.0, ([LICENSE-APACHEv2](LICENSE-APACHEv2) or http://www.apache.org/licenses/LICENSE-2.0)

at your option. This file may not be copied, modified, or distributed except according to those terms.

[1]: https://github.com/status-im/nimbus/wiki/Understanding-and-debugging-Nimbus-EVM-JSON-tests
[2]: https://github.com/status-im/nimbus/wiki/Debugging-state-reconstruction

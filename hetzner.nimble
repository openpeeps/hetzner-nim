# Package

version       = "0.1.0"
author        = "George Lemon"
description   = "Asynchronous Nim client for interacting with Hetzner Cloud API"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.2"
requires "jsony"

task build_action, "build /action":
  exec "nim c -d:ssl -o:./bin/action src/hetzner/action.nim"

task build_certificate, "build /certficates":
  exec "nim c -d:ssl -o:./bin/certificates src/hetzner/certificate.nim"

task build_network, "build /networks":
  exec "nim c -d:ssl -o:./bin/networks src/hetzner/network.nim"
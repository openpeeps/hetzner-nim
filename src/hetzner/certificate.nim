# Asynchronous Nim client for
# interacting with the Hetzner Cloud API
#
# (c) 2023 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/hetzner-nim

import std/times
import pkg/jsony
import ./meta

type
  CertificateStatus* = enum
    certificateStatusIssuance
    certificateStatusRenewal
    certificateStatusError

  CertificateType* = enum
    certificateTypeUploaded = "uploaded"
    certificateTypeManaged = "managed"

  Certificate* = ref object
    id: int64
    name: string
    labels: seq[string]
    `type`: CertificateType
    certificate: string
    created: Time
    not_valid_before, not_valid_after: Time
    domain_names: seq[string]
    fingerprint: string
    status: CertificateStatus

  Certificates* = ref object
    certificates: seq[Certificate]
    meta: Pagination

  CertificateClient* = ref object of HetznerClient

proc get*(client: CertificateClient): Future[Certificates] {.async.} =
  ## Make a `GET` request to retrieve all `Certificates`
  let res = await client.getHetzner()
  let body = await res.body
  fromJSON body, Certificates
  client.httpClient.close()

proc `$`*(certs: Certificates): string =
  ## Serialize available `Certificates`
  toJSON certs

proc len*(certs: Certificates): int = 
  certs.certificates.len

proc isEmpty*(certs: Certificates): bool =
  certs.certificates.len == 0

when isMainModule:
  import pkg/dotenv
  from std/os import getEnv
  from std/macros import getProjectPath
  
  dotenv.load(getProjectPath())
  var hcloud = initHetzner(getEnv("hetznerApiKey"))
  var client = newClient[CertificateClient](hcloud, epCertificates)
  let certs = waitFor client.get()
  echo certs
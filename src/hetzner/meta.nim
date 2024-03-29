# Asynchronous Nim client for
# interacting with the Hetzner Cloud API
#
# (c) 2023 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/hetzner-nim

import std/[asyncdispatch, httpclient, tables,
  strutils, sequtils, times]

import pkg/jsony

from std/httpcore import HttpMethod

export HttpMethod, asyncdispatch, httpclient,
  tables, sequtils

type
  HetznerEndpoint* = enum
    # Action
    epAction = "action"
    epActions = "actions"
    # Certifications
    epCertificates = "certificates"
    epCertificate = "certificates/{$1}"
    # Datacenters
    epDatacenters = "datacenters"
    epDatacenter = "datacenter/{$1}"

    epNetworks = "networks"
    epNetwork = "networks/{$1}"

  HetznerClient* = ref object of RootObj
    uri*: HetznerEndpoint
    httpClient*: AsyncHttpClient
    query*: QueryTable
    multiQuery*: MultiQueryTable
  
  QueryTable* = OrderedTable[string, string]
  MultiQueryTable* = OrderedTable[string, seq[string]]

  Pagination* = object
    page, per_page, previous_page,
      next_page, last_page, total_entries: int

  HetznerCloud* = ref object
    apiKey: string

const baseHetznerUri = "https://api.hetzner.cloud/v1/"

proc initHetzner*(key: string): HetznerCloud =
  ## Initialize a new HetznerCloud
  HetznerCloud(apiKey: key)

proc newClient*[T: HetznerClient](hcloud: HetznerCloud, endpoint: HetznerEndpoint): T =
  new(result)
  result.uri = endpoint
  result.httpClient = newAsyncHttpClient()
  result.httpClient.headers = newHttpHeaders({
    "Authorization": "Bearer " & hcloud.apiKey
  })

proc `$`*(query: QueryTable): string =
  ## Convert `query` QueryTable to string
  if query.len > 0:
    add result, "&"
    add result, join(query.keys.toSeq.mapIt(it & "=" & query[it]), "&")

proc `$`*(query: MultiQueryTable): string =
  ## Convert `query` MultiQuerytable to string
  if query.len > 0:
    add result, "?"
    var i = 0
    let len = query.len - 1
    for k, x in query:
      if x.len == 1:
        add result, k
        add result, "=" & x[0]
      else:
        add result, join(x.mapIt(k & "=" & it), "&")
      if i != len:
        add result, "&"
      inc i

#
# JSONY hooks
#
proc parseHook*(s: string, i: var int, v: var Time) =
  var str: string
  parseHook(s, i, str)
  v = parseTime(str, "yyyy-MM-dd'T'hh:mm:sszzz", local())

proc dumpHook*(s: var string, v: Time) =
  add s, '"'
  add s, v.format("yyyy-MM-dd'T'hh:mm:sszzz", local())
  add s, '"'

proc endpoint*(uri: HetznerEndpoint,
    multiQuery: MultiQueryTable, query: QueryTable): string =
  ## Return the url string of an endpoint
  result = baseHetznerUri & $uri & $multiQuery & $query

proc getHetzner*(client: HetznerClient): Future[AsyncResponse] {.async.} =
  ## Make a GET request using an instance of `HetznerClient`
  let uri = client.uri.endpoint(client.multiQuery, client.query)
  result = await client.httpClient.request(uri, HttpGet)
  client.httpClient.close()


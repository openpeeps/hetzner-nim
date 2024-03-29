# Asynchronous Nim client for
# interacting with the Hetzner Cloud API
#
# (c) 2023 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/hetzner-nim

import std/times
import pkg/jsony
import ./meta

## Actions show the results and progress of asynchronous requests to the API.
## Check Hetzner API Reference: https://docs.hetzner.cloud/#actions

type
  ActionStatus* = enum
    actionStatusRunning = "running"
    actionStatusSuccess = "success"
    actionStatusError = "error"

  Action* = object
    id: int64
    command: string
    status: ActionStatus
    progress: int
    started, finished: Time
    error: ActionError
    resources: seq[ActionResource]

  ActionResourceType* = enum
    actionResourceTypeServer = "server"
    actionResourceTypeImage = "image"
    actionResourceTypeISO = "iso"
    actionResourceTypeFloatingIP = "floating_ip"
    actionResourceTypeVolume = "volume"

  ActionResource* = object
    id: int64
    `type`: ActionResourceType

  ActionError* = ref object
    code: string
    message: string

  Actions* = object
    actions: seq[Action]
    meta: Pagination

  ActionClient* = ref object of HetznerClient


#
# `/actions`
#
# proc newActionClient*(): ActionClient =
#   ## Create a new HttpClient for GET `/action`

proc sort*(client: ActionClient, filters: varargs[string]): ActionClient {.discardable.} =
  ## Sort actions by field and direction. Can be used multiple times.
  ## For more information, see [Sorting](https://docs.hetzner.cloud/#sorting)
  assert client.uri == epActions
  client.multiQuery["sort"] = filters.toSeq
  result = client

proc status*(client: ActionClient, x: set[ActionStatus]): ActionClient {.discardable.} =
  ## Filter the actions by status. Can be used multiple times.
  ## The response will only contain actions matching the specified statuses
  assert client.uri == epActions
  client.multiQuery["status"] = x.toSeq.mapit($it)
  result = client

proc page*(client: ActionClient, i: int64): ActionClient {.discardable.} =
  ## Maximum number of entries returned per page.
  ## For more information, see [Pagination](https://docs.hetzner.cloud/#pagination)
  client.query["page"] = $i
  result = client

proc perPage*(client: ActionClient, i: int64): ActionClient {.discardable.} =
  ## Page number to return. For more information
  client.query["per_page"] = $i
  result = client

proc get*(client: ActionClient): Future[Actions] {.async.} =
  let res = await client.getHetzner()
  let body = await res.body
  fromJSON body, Actions

proc `$`*(certs: Actions): string =
  ## Serialize available Actions
  toJSON certs

when isMainModule:
  import pkg/dotenv
  from std/os import getEnv
  from std/macros import getProjectPath
  
  dotenv.load(getProjectPath())
  
  var hcloud = initHetzner(getEnv("hetznerApiKey"))
  var client = newClient[ActionClient](hcloud, epActions)
  
  let actions: Actions = waitFor client.get()
  echo actions

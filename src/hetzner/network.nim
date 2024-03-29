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
  NetworkZone* = enum
    ## Name of network zone
    networkZoneEUCentral = "eu-central"
    networkZoneUSEast = "us-east"
    networkZoneUSWest = "us-west"

  NetworkProtection* = ref object
    delete*: bool
      ## If true, prevents the Network from being deleted
  
  NetworkRoute* = ref object
    destination*: string
      ## Destination network or host of this route.
      ## Must not overlap with an existing ip_range in any
      ## subnets or with any destinations in other routes or
      ## with the first IP of the networks ip_range or with
      ## 172.31.1.1. Must be one of the private IPv4
      ## ranges of RFC1918.
    gateway*: string
      ## Gateway for the route. Cannot be the first IP of
      ## the networks ip_range and also cannot be 172.31.1.1
      ## as this IP is being used as a gateway for the
      ## public network interface of Servers.
  
  NetworkSubnetType* = enum
    networkSubnetTypeCloud = "cloud"
    networkSubnetTypeServer = "server"
    networkSubnetTypeVSwitch = "vswitch"
  
  VSwitchID* = ref int64

  NetworkSubnet* = ref object
    `type`: NetworkSubnetType
      # Type of Subnetwork
    ip_range: string
    network_zone: NetworkZone
    vswitch_id: VSwitchID
      # ID of the robot vSwitch. Must be supplied if the
      # subnet is of type vswitch.

  Network* = ref object
    id: int64
    name: string
      # Name of the network
    created: Time
      # Point in time when the Network was created (in ISO-8601 format)
    ip_range: string
      # IPv4 prefix of the whole Network
    labels: Table[string, string]
      # User-defined labels (key-value pairs)
    load_balancers: seq[int64]
      # Sequence of IDs of Load Balancers attached to this Network
    expose_route_to_vswitch: bool
      # Indicates if the routes from this network should be exposed to the vSwitch connection
    protection: NetworkProtection
      # Protection configuration for the Network
    routes: seq[NetworkRoute]
      # Sequence of routes set in this Network
    subnets: seq[NetworkSubnet]
      # Sequence subnets allocated in this Network
    servers: seq[int64]
      # Sequence of IDs of Servers attached to this Network
  
  Networks* = ref object
    networks: seq[Network]
    meta: Pagination

  NetworkClient* = ref object of HetznerClient

proc get*(client: NetworkClient): Future[Networks] {.async.} =
  ## Make a `GET` request to retrieve available `Network`
  let res = await client.getHetzner()
  let body = await res.body
  fromJSON body, Networks

proc `$`*(networks: Networks): string =
  ## Serialize available `Networks`
  toJSON networks

when isMainModule:
  import pkg/dotenv
  from std/os import getEnv
  from std/macros import getProjectPath

  dotenv.load(getProjectPath())
  var hcloud = initHetzner(getEnv("hetznerApiKey"))
  var client = newClient[NetworkClient](hcloud, epNetworks)
  let networks = waitFor client.get()
  echo networks
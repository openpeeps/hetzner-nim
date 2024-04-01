# Asynchronous Nim client for
# interacting with the Hetzner Cloud API
#
# (c) 2024 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/hetzner-nim
import pkg/jsony

import ./meta

type
  Price* = ref object
    net, gross: string

  PriceType* = enum
    priceTypeMonthly = "monthly"
    priceTypeHourly = "hourly"

  PricingImage* = ref object
    price_per_gb_month: Price

  PricingFloatingIp* = ref object
    price_monthly: Price

  PricingFloatingIpType* = ref object
    `type`: string
    prices: seq[PricingFloatingIpTypePrice]

  PricingFloatingIpTypePrice* = ref object
    location: string
    price_monthly: Price
  
  PricingPrimaryIp* = ref object
    location: string

  PricingPrimaryIps* = ref object
    `type`: string
    prices: seq[PricingPrimaryIp]

  PricingLoadBalancerTypePrice* = ref object
    location: string
    price_hourly, price_monthly: Price
  
  PricingLoadBalancerType* = ref object
    id: int64
    name: string
    prices: seq[PricingLoadBalancerTypePrice]

  Pricing* = ref object
    currency, vat_rate: string
    image: PricingImage
    floating_ip: PricingFloatingIp
    floating_ips: seq[PricingFloatingIpType]
    load_balancer_types: seq[PricingLoadBalancerType]
    # primary_ips: PricingPrimaryIps

  Prices* = ref object
    pricing: Pricing

  PricingClient* = ref object of HetznerClient

proc prices*(hcloud: HetznerCloud): PricingClient =
  ## Initialize a new `PricingClient`
  newClient[PricingClient](hcloud, epPrices)

proc get*(client: PricingClient): Future[Prices] {.async.} =
  ## Make a `GET` to `/prices` endpoint
  let res = await client.getHetzner()
  let body = await res.body
  client.httpClient.close()
  fromJSON body, Prices

proc `$`*(pricing: Prices): string =
  ## Serialize available `Certificates`
  toJSON pricing

when isMainModule:
  import pkg/dotenv
  from std/os import getEnv
  from std/macros import getProjectPath
  
  dotenv.load(getProjectPath())
  var hcloud = initHetzner(getEnv("hetznerApiKey"))
  let client = hcloud.prices()
  let pricing = waitFor client.get()

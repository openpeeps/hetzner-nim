<p align="center">
  <img src="https://github.com/openpeeps/hetzner-nim/blob/main/.github/hetzner.png" width="240px" height="240px"><br>
  Asynchronous Nim 👑 client for interacting with the <a href="https://docs.hetzner.cloud/#overview">Hetzner Cloud API</a>
</p>

<p align="center">
  <code>nimble install hetzner</code>
</p>

<p align="center">
  <a href="https://github.com/">API reference</a><br>
  <img src="https://github.com/openpeeps/hetzner-nim/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/openpeeps/hetzner-nim/docs/badge.svg" alt="Github Actions">
</p>

## 😍 Key Features
- Intuitive API interface
- Direct to Object serialization via `pkg/jsony`
- Written in Nim 👑

## Examples
```nim
import pkg/hetzner
let hcloud = initHetzner(getEnv("api_key"))
let: Certificates = waitFor hcloud.getCertificates()
```

### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/openpeeps/hetzner-nim/issues)
- 👋 Wanna help? [Fork it!](https://github.com/openpeeps/hetzner-nim/fork)
- 😎 [Get €20 in cloud credits from Hetzner](https://hetzner.cloud/?ref=Hm0mYGM9NxZ4)
- 🥰 [Donate via PayPal address](https://www.paypal.com/donate/?hosted_button_id=RJK3ZTDWPL55C)

### 🎩 License
MIT license. [Made by Humans from OpenPeeps](https://github.com/openpeeps).<br>
Copyright &copy; 2024 OpenPeeps & Contributors &mdash; All rights reserved.

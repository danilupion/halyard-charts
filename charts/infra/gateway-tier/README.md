# gateway-tier

One Gateway API tier served by Envoy Gateway. Deploy one release per tier per
cluster (e.g. `gateway-public`, `gateway-private`) with `fullnameOverride` set
to the tier name.

Renders:

- **EnvoyProxy** — the tier's LoadBalancer Service shape (MetalLB pool /
  shared-IP annotations, optional `loadBalancerIP`, `externalTrafficPolicy`)
- **Gateway** — HTTPS listener terminating TLS with the tier certificate
  (`allowedRoutes` from all namespaces by default) plus an optional HTTP
  listener; the EnvoyProxy is bound via `spec.infrastructure.parametersRef` so
  multiple tiers share one controller/GatewayClass
- **Certificate** — cert-manager multi-SAN/wildcard certificate (DNS-01)
- **HTTPRoute redirect** — tier-wide HTTP→HTTPS redirect on the HTTP listener
- **ClientTrafficPolicy** (optional) — XFF trust / client IP detection

Applications attach with `parentRefs: [{name: <tier>, namespace: <tier ns>}]`
(see `common.httproute` in the `common` library chart).

## Example

```yaml
fullnameOverride: gateway-public
service:
  annotations:
    metallb.io/address-pool: gateway-public-pool
    metallb.io/allow-shared-ip: public-pool
  externalTrafficPolicy: Cluster
certificate:
  dnsNames:
    - "*.example.com"
    - example.com
clientTrafficPolicy:
  enabled: true
  spec:
    clientIPDetection:
      xForwardedFor:
        numTrustedHops: 1
```

Requires: Envoy Gateway >= 1.1 (Gateway-level `infrastructure.parametersRef`),
cert-manager, and a MetalLB pool for the tier.

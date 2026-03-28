--- CRD schema definitions for yaml-companion's Telescope/UI picker.
--- These are available for manual selection when auto-detection doesn't match.
--- Add new CRDs here as { name = "...", uri = "..." } entries.
---
--- URL pattern for datreeio/CRDs-catalog:
--- https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{group}/{kind}_{version}.json

local datree = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/"
local flux = "https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/"

return {
  -- Flux CD
  { name = "Flux GitRepository", uri = flux .. "gitrepository-source-v1.json" },
  { name = "Flux Kustomization", uri = flux .. "kustomization-kustomize-v1.json" },
  { name = "Flux HelmRelease", uri = flux .. "helmrelease-helm-v2.json" },
  { name = "Flux HelmRepository", uri = flux .. "helmrepository-source-v1.json" },
  { name = "Flux OCIRepository", uri = flux .. "ocirepository-source-v1beta2.json" },

  -- CloudNativePG
  { name = "CNPG Cluster", uri = datree .. "postgresql.cnpg.io/cluster_v1.json" },

  -- Traefik
  { name = "Traefik IngressRoute", uri = datree .. "traefik.io/ingressroute_v1alpha1.json" },
  { name = "Traefik Middleware", uri = datree .. "traefik.io/middleware_v1alpha1.json" },

  -- Kyverno
  { name = "Kyverno ClusterPolicy", uri = datree .. "kyverno.io/clusterpolicy_v1.json" },
  { name = "Kyverno Policy", uri = datree .. "kyverno.io/policy_v1.json" },
}

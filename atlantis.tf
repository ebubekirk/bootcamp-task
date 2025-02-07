resource "helm_release" "atlantis" {
  name       = "atlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"
  version    = "4.0.0"
  namespace  = "atlantis"

  values = [
    <<-EOF
    git:
      user: "ebubekirk"
      token: "#################################"
      secret: "3758e2b06af0d5206ebb607cb48420a6d4d0984d9fa32ad9d74e1fcf185e"
      repos:
        - name: "bootcamp-task"
          branch: "main"
    EOF
  ]

  depends_on = [
    module.eks
  ]
}

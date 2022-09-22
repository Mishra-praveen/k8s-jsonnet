local k = import "github.com/jsonnet-libs/k8s-libsonnet/1.25/main.libsonnet";
{
  _config:: error "Must provide deploy config",
  // initiate resources
  local deploy = k.apps.v1.deployment,
  local namespace = k.core.v1.namespace,
  local service = k.core.v1.service,
  local container = k.core.v1.container,
  local port = k.core.v1.containerPort,
  local volMount = k.core.v1.volumeMount,
  local vol = k.core.v1.volume,

  //carts deploy,service
  deployment_cart:: deploy.new(
    name=$._config.carts.name, 
    containers=[
      container.new(
        name=$._config.carts.name, image=$._config.carts.image
      ) + 
      container.withEnv(
        [
          {
            "name": "JAVA_OPTS", "value": "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
          }
        ]
      ) + 
      container.withPorts(
        [
          port.new(8000)
        ]
      ) +
      container.securityContext.withRunAsNonRoot(true) +
      container.securityContext.withRunAsUser(1001) +
      container.securityContext.capabilities.withAdd(["NET_BIND_SERVICE"]) + 
      container.securityContext.capabilities.withDrop("all") +
      container.resources.withLimits(limits=({cpu: 300, memory: 500})) +
      container.resources.withRequests(requests=({cpu: 300, memory: 500})) +
      container.withVolumeMounts(volMount.new(name="tmp-vol", mountPath="/tmp"))

    ], 
    replicas=1
  ) +
  deploy.spec.template.spec.withVolumes(vol.fromEmptyDir(name="tmp-vol", emptyDir={}) +
  vol.emptyDir.withMedium("Memory"))+
  deploy.spec.template.spec.withNodeSelector({"beta.kubernetes.io/os": "linux"}),
  
  service: service.new(
    name=$._config.carts.name,
    selector={
      "name": $._config.carts.name
    }, 
    ports=[{"port": 80, "targetPort": 80}]
  ),
}
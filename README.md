# k8s-jsonnet

mkdir k8s-jasonnet

jb init

jb install github.com/jsonnet-libs/k8s-libsonnet/1.25@main

jsonnet -J vendor -m manifests sample.jsonnet | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml' -- {}

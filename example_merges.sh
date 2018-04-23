#!/bin/bash
PROJS="kubernetes prometheus containerd envoy grpc allprj opentracing fluentd linkerd coredns rkt cni jaeger notary tuf rook vitess nats opa spiffe spire cncf" ./merge_results.sh
RRE="release;;;(?i)cncf" RNAME="join" PROJS="prometheus kubernetes containerd envoy grpc allprj opentracing fluentd linkerd coredns rkt cni jaeger notary tuf rook vitess nats opa spiffe spire cncf" ./merge_results.sh
RRE='release;;;^\d{4}$' RNAME="yearly" PROJS="kubernetes allprj envoy grpc opentracing fluentd linkerd coredns rkt cni jaeger notary tuf rook vitess nats opa spiffe spire cncf" ./merge_results.sh
RRE='release;;;^Quarter from' RNAME="quarterly" PROJS="kubernetes prometheus containerd envoy grpc allprj opentracing fluentd linkerd coredns rkt cni jaeger notary tuf rook vitess nats opa spiffe spire cncf" ./merge_results.sh
RRE='release;;;^\d{2}/\d{4}$' RNAME="monthly" PROJS="kubernetes prometheus containerd envoy grpc allprj opentracing fluentd linkerd coredns rkt cni jaeger notary tuf rook vitess nats opa spiffe spire cncf" ./merge_results.sh
RRE='release;;;(?i)v\d\.\d' RNAME="releases" PROJS="kubernetes prometheus containerd" ./merge_results.sh

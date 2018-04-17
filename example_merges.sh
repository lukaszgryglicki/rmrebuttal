#!/bin/bash
PROJS="kubernetes prometheus containerd envoy grpc allprj" ./merge_results.sh
RRE="release;;;(?i)cncf" RNAME="join" PROJS="prometheus kubernetes containerd envoy grpc allprj" ./merge_results.sh
RRE='release;;;^\d{4}$' RNAME="yearly envoy grpc" PROJS="allprj" ./merge_results.sh
RRE='release;;;^Quarter from' RNAME="quarterly" PROJS="kubernetes prometheus containerd envoy grpc allprj" ./merge_results.sh
RRE='release;;;^\d{2}/\d{4}$' RNAME="monthly" PROJS="kubernetes prometheus containerd envoy grpc allprj" ./merge_results.sh
RRE='release;;;(?i)v\d\.\d' RNAME="releases" PROJS="kubernetes prometheus containerd" ./merge_results.sh

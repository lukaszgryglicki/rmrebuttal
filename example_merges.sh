#!/bin/bash
PROJS="kubernetes prometheus containerd allprj" ./merge_results.sh
RRE="release;;;(?i)cncf" RNAME="join" PROJS="prometheus kubernetes containerd allprj" ./merge_results.sh
RRE='release;;;^\d{4}$' RNAME="yearly" PROJS="allprj" ./merge_results.sh
RRE='release;;;^Quarter from' RNAME="quarterly" PROJS="kubernetes prometheus containerd allprj" ./merge_results.sh
RRE='release;;;^\d{4}-\d{2}-\d{2}$' RNAME="monthly" PROJS="kubernetes prometheus containerd allprj" ./merge_results.sh
RRE='release;;;(?i)v\d\.\d' RNAME="releases" PROJS="kubernetes prometheus containerd" ./merge_results.sh

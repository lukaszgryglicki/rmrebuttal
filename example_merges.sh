#!/bin/bash
PROJS="prometheus kubernetes allprj" ./merge_results.sh
RRE="release;;;(?im)cncf" RNAME="join" PROJS="prometheus kubernetes allprj" ./merge_results.sh
RRE='release;;;^\d{4}$' RNAME="yearly" PROJS="allprj" ./merge_results.sh
RRE='release;;;^Quarter from' RNAME="quarterly" PROJS="allprj kubernetes prometheus" ./merge_results.sh
RRE='release;;;^\d{4}-\d{2}-\d{2}$' RNAME="monthly" PROJS="allprj kubernetes prometheus" ./merge_results.sh
RRE='release;;;(?i)v\d\.\d' RNAME="releases" PROJS="kubernetes prometheus" ./merge_results.sh

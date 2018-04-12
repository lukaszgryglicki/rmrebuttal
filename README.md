# rmrebuttal
Use DevStats databases and tools to generate contributors stats


# Usage
- You need to have DevStats K8s database and `runq` binary copied to the root directory of this repo.
- Just run `PG_PASS=... ./get_data.sh 10` script to generate Top 10 data for Kubernetes.
- Run `PG_PASS=... PG_DB=prometheus ./get_data.sh 30` script to generate Top 30 data for Prometheus.
- Argument is the N parameter, script analyses Top N developers, contributors, issue creators etc.
- You can also regenerate all data for N=1, 2, 3, 5, 10, 15, 20, 25, 50, 100, 200, 500, 1000 via `PG_PASS=... ./generate_all.sh`.
- You can generate only specific Top N's for a specific project by: `PG_PASS=... ONLY="1 10 100" PG_DB=prometheus ./generate_all.sh`.

# Data
- Data is available [here](https://docs.google.com/spreadsheets/d/1dK7h8i62G7JEtTrJ2XEYoX0vInEoA7lW0m9ssl5bXag/edit?usp=sharing)
- Analysis is [here](https://github.com/lukaszgryglicki/rmrebuttal/blob/master/ANALYSIS_RELEASES.md).

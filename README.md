# rmrebuttal
Use DevStats databases and tools to generate contributors stats


# Usage
- You need to have DevStats K8s database and `runq` binary copied to the root directory of this repo.
- Just run `PG_PASS=.. ./get_data.sh file.csv 10` script.
- First oarameter is the CSV output filename (will be put in results/ directory).
- Second argument is the N parameter, script analyses Top N developers, contributors, issue creators etc.
- You can also regenerate all data for N=1, 2, 5, 10, 20, 25, 50 and 100 via `PG_PASS=... ./generate_all.sh`.

# Data
- Data is available [here](https://docs.google.com/spreadsheets/d/1dK7h8i62G7JEtTrJ2XEYoX0vInEoA7lW0m9ssl5bXag/edit?usp=sharing)
- Analysis is [here](https://github.com/lukaszgryglicki/rmrebuttal/blob/master/ANALYSIS_RELEASES.md).

#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  echo "PASS: $*"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  echo "FAIL: $*"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

run_cmd() {
  local label="$1"
  shift

  if "$@"; then
    pass "$label"
    return 0
  fi

  fail "$label"
  return 1
}

echo "[1/4] Building each conda environment file with micromamba"
if ! command -v micromamba >/dev/null 2>&1; then
  fail "micromamba not installed (required to validate conda env creation)"
else
  export MAMBA_ROOT_PREFIX="$ROOT_DIR/.mamba-check"
  mkdir -p "$MAMBA_ROOT_PREFIX"

  # Use explicit names to avoid colliding with user environments.
  run_cmd "L24_conda_envs/r-models_environment.yml can be solved and created" \
    micromamba create -y -n check-rmodels -f L24_conda_envs/r-models_environment.yml

  run_cmd "L25_conda-job/parallel_env.yml can be solved and created" \
    micromamba create -y -n check-parallel -f L25_conda-job/parallel_env.yml

  run_cmd "L26_nextflow-intro/nextflow_environment.yml can be solved and created" \
    micromamba create -y -n check-nextflow-intro -f L26_nextflow-intro/nextflow_environment.yml

  run_cmd "L34_cloud_nextflow/setup_code/nextflow_environment.yml can be solved and created" \
    micromamba create -y -n check-nextflow-cloud -f L34_cloud_nextflow/setup_code/nextflow_environment.yml
fi

echo
echo "[2/4] Running class R scripts directly (real execution)"
mkdir -p /tmp/class-bigdata-checks

run_cmd "L29 import script" \
  Rscript L29_nextflow_assembling-workflow/bin/run_import.R \
    L29_nextflow_assembling-workflow/L29_dataset_biodegradation.tsv \
    /tmp/class-bigdata-checks/l29_dataset

run_cmd "L29 linear model script" \
  Rscript L29_nextflow_assembling-workflow/bin/run_linear_model.R \
    /tmp/class-bigdata-checks/l29_dataset.rds \
    /tmp/class-bigdata-checks/l29_linear

run_cmd "L29 random forest script" \
  Rscript L29_nextflow_assembling-workflow/bin/run_random_forest.R \
    /tmp/class-bigdata-checks/l29_dataset.rds 1 /tmp/class-bigdata-checks/l29_rf

run_cmd "L30 import script" \
  Rscript L30_nextflow_your-workflow/solution/scripts/run_import.R \
    L30_nextflow_your-workflow/L30_dataset_metastasis_risk.tsv \
    /tmp/class-bigdata-checks/l30_dataset

run_cmd "L30 logistic model script" \
  Rscript L30_nextflow_your-workflow/solution/scripts/run_logistic_model.R \
    /tmp/class-bigdata-checks/l30_dataset.rds 1 /tmp/class-bigdata-checks/l30_logreg

run_cmd "L30 random forest script" \
  Rscript L30_nextflow_your-workflow/solution/scripts/run_random_forest.R \
    /tmp/class-bigdata-checks/l30_dataset.rds 1 /tmp/class-bigdata-checks/l30_rf

run_cmd "L31 mean/sd script" \
  Rscript L31_nextflow_more-coding/solution/bin/mean_sd.R \
    L31_nextflow_more-coding/data/experiment1.tsv experiment1

run_cmd "L31 MAD script" \
  Rscript L31_nextflow_more-coding/solution/bin/mad.R \
    L31_nextflow_more-coding/data/experiment1.tsv experiment1

run_cmd "L31 PC1 loading script" \
  Rscript L31_nextflow_more-coding/solution/bin/pc1_loading.R \
    L31_nextflow_more-coding/data/experiment1.tsv experiment1

run_cmd "L31 summary script" \
  Rscript L31_nextflow_more-coding/solution/bin/generate_final_summary.R \
    experiment1_mean_sd.tsv experiment1_mad.tsv experiment1_pc1load.tsv summary.tsv

run_cmd "L37 import script" \
  Rscript L37_tutoring/nextflow/pipeline/scripts/run_import.R \
    L37_tutoring/regression/dataset/mbg_exams_blood_pressure_data.tsv \
    /tmp/class-bigdata-checks/l37_dataset

run_cmd "L37 linear model script" \
  Rscript L37_tutoring/nextflow/pipeline/scripts/run_lm.R \
    /tmp/class-bigdata-checks/l37_dataset.rds 1 /tmp/class-bigdata-checks/l37_lm

run_cmd "L37 KNN script" \
  Rscript L37_tutoring/nextflow/pipeline/scripts/run_knn.R \
    /tmp/class-bigdata-checks/l37_dataset.rds 1 /tmp/class-bigdata-checks/l37_knn

echo
echo "[3/4] Running Nextflow class scripts (real execution, not preview)"
run_nf() {
  local rel_dir="$1"
  local script="$2"
  shift 2

  if (cd "$rel_dir" && nextflow run "$script" -ansi-log false "$@"); then
    pass "$rel_dir/$script"
  else
    fail "$rel_dir/$script"
  fi
}

run_nf L26_nextflow-intro hello.nf
run_nf L26_nextflow-intro/exercise_channels factories.nf
run_nf L26_nextflow-intro/exercise_channels pairs.nf
run_nf L27_nextflow-coding/01_exercise_processes inputfile.nf
run_nf L27_nextflow-coding/02_exercise_config params.nf
run_nf L27_nextflow-coding/03_exercise_lines hello.nf
run_nf L27_nextflow-coding/03_exercise_lines/solution solution_each_line.nf
run_nf L28_nextflow-modules/modules modules.nf --x verify
run_nf L28_nextflow-modules/modules/exercise_solution solution_workflow.nf
run_nf L28_nextflow-modules/operators collect.nf
run_nf L28_nextflow-modules/operators group.nf
run_nf L28_nextflow-modules/operators map.nf
run_nf L28_nextflow-modules/operators mix.nf
run_nf L28_nextflow-modules/operators/group_exercise group_solution.nf
run_nf L29_nextflow_assembling-workflow main.nf
run_nf L30_nextflow_your-workflow/solution main.nf
run_nf L31_nextflow_more-coding/solution main.nf
run_nf L34_cloud_nextflow/pipeline main.nf
run_nf L37_tutoring/nextflow/pipeline main.nf

echo
echo "[4/4] Shell syntax checks for class shell scripts"
while IFS= read -r sh_file; do
  run_cmd "bash -n $sh_file" bash -n "$sh_file"
done < <(rg --files \
  L24_conda_envs \
  L25_conda-job \
  L26_nextflow-intro \
  L27_nextflow-coding \
  L28_nextflow-modules \
  L29_nextflow_assembling-workflow \
  L30_nextflow_your-workflow \
  L31_nextflow_more-coding \
  L34_cloud_nextflow \
  L37_tutoring/nextflow \
  -g '!**/work/**' \
  -g '!**/.command.sh' \
  -g '*.sh')

echo
echo "Summary: PASS=$PASS_COUNT FAIL=$FAIL_COUNT"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi

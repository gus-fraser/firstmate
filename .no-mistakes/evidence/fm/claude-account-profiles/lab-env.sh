# Sourced by the live account-selection driver. Shared lab variables.
# Strip the parent Claude Code session's identity so the lab worker is not
# treated as a nested session of this validating agent.
for v in $(env | sed -n 's/^\(CLAUDE_CODE_[A-Z_]*\|CLAUDECODE\|CLAUDE_PID\|CLAUDE_EFFORT\|CLAUDE_PLUGIN_DATA\)=.*/\1/p'); do unset "$v"; done
unset HERDR_ENV HERDR_PANE_ID HERDR_TAB_ID HERDR_WORKSPACE_ID HERDR_SOCKET_PATH CLAUDE_CONFIG_DIR
ROOT=/Users/gusfraser/.no-mistakes/worktrees/8a501578f0e3/01M37FR9CMN31VV6XN10J1PYGH
EV=/Users/gusfraser/.no-mistakes/evidence/01M37FR9CMN31VV6XN10J1PYGH
LABSTATE=$EV/.labstate
HELPER="$ROOT/bin/fm-herdr-lab.sh"
[ -f "$LABSTATE" ] && . "$LABSTATE"
lab() { "$HELPER" run "$SESSION" "$@"; }
spawn() { # <id> [args...]
  local id=$1; shift
  env FM_GATE_REFUSE_BYPASS=1 HERDR_SESSION="$SESSION" CLAUDE_CONFIG_DIR="$AMBIENT" FM_SPAWN_NO_GUARD=1 FM_HOME="$HOME_DIR" FM_ROOT_OVERRIDE="$ROOT" \
    "$ROOT/bin/fm-spawn.sh" "$id" "$PROJ" --mode local-only --yolo off --backend herdr "$@"
}
control() { # <id> <verb> [args...]
  env FM_GATE_REFUSE_BYPASS=1 HERDR_SESSION="$SESSION" CLAUDE_CONFIG_DIR="$AMBIENT" FM_HOME="$HOME_DIR" FM_ROOT_OVERRIDE="$ROOT" \
    "$ROOT/bin/fm-control.sh" "$@"
}
meta() { cat "$HOME_DIR/state/$1.meta"; }
pane_of() { sed -n 's/^herdr_pane_id=//p' "$HOME_DIR/state/$1.meta"; }
# Environment of the claude process running in a task pane (ps eww of our own uid).
claude_env_of() { # <id>
  local pid
  pid=$(lab pane process-info "$(pane_of "$1")" 2>/dev/null | jq -r '.. | objects | select(has("pid")) | .pid' | head -1)
  echo "# pane process-info root pid: $pid"
  pgrep -P "$pid" >/dev/null 2>&1 || true
  for p in $pid $(pgrep -P "$pid") ; do
    ps -o pid=,comm= -p "$p"
    ps eww -o command= -p "$p" | tr ' ' '\n' | grep -E '^CLAUDE_CONFIG_DIR=' || echo "  (no CLAUDE_CONFIG_DIR in env of pid $p)"
  done
}

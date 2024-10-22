SSH_PID="$HOME/.ssh/agent-pid"
function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"$SSH_PID"
    echo succeeded
    chmod 600 "$SSH_PID"
    . "$SSH_PID" >/dev/null
}
if [ -f "$SSH_PID" ]; then
    . "$SSH_PID" >/dev/null
    ps -ef | grep $SSH_AGENT_PID | grep ssh-agent$ >/dev/null || {
        start_agent
    }
else
    start_agent
fi

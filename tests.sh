MIX_ENV=test elixir --sname node1@localhost --cookie a_cookie_string -S mix start_node &
NODE_1_PID=$!
echo "started node1 with pid $NODE_1_PID"

MIX_ENV=test elixir --sname node2@localhost --cookie a_cookie_string -S mix start_node &
NODE_2_PID=$!
echo "started node2 with pid $NODE_2_PID"


MIX_ENV=test elixir --sname test@localhost --cookie a_cookie_string -S mix test

kill -9 $NODE_1_PID
kill -9 $NODE_2_PID

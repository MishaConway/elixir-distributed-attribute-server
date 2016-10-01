defmodule DistributedAttributeServer.Master do
  defmacro __using__(_opts) do
    quote do
      alias DistributedAttributeServer.States.MasterState, as: MasterState
      alias DistributedAttributeServer.States.SlaveState, as: SlaveState

      def run_for_master key do
        if :global.set_lock {key, self}, Elixir.Node.list ++ [Elixir.Node.self], 0 do
          true
        else
          if master_assigned? do
            # if another master was assigned, we did not win the race for the lock
            false
          else
            # keep doing this until we become master or someone else becomes master
            run_for_master key
          end
        end
      end

      def init_master do
        SlaveState.remove_component __MODULE__
        MasterState.mark_component __MODULE__

        log "SELF: promoting to master"

        {:ok, pid} = :gen_server.start_link(__MODULE__, %{}, [])
        unless registered_locally? do
          Process.register pid, __MODULE__
        end
        :global.register_name(__MODULE__, pid)

        receive_pid = spawn fn -> master_listen end
        :global.register_name(master_receive_pid_name, receive_pid)
        {:ok, pid}
      end

      def master_listen do
        if master? do
          receive do
            {client, :subscribe} ->
              log "MASTER LISTENER: got `subscribe` from #{:i.i client}"
              MasterState.append_slave __MODULE__, %{client => 1}
              log "MASTER: sending `set_all` #{:i.i all} to #{:i.i client}"
              send client, {:set_all, all}
            {client, :set, attr, value} ->
              log "MASTER LISTENER: got `set` #{:i.i attr}=#{:i.i value} from #{:i.i client}"
              set(attr, value)
            {client, :set_all, attributes} ->
              log "MASTER LISTENER: got `set_all` #{:i.i attributes} from #{:i.i client}"
              set_all attributes
            {client, :get, attr} ->
              log "MASTER LISTENER: got `get` #{:i.i attr} from #{:i.i client}"
              send(client, {:get_response, get(attr)})
            {client, :all} ->
              log "MASTER LISTENER: got `all` from #{:i.i client}"
              send(client, {:all_response, all})
            {client, :clear} ->
              log "MASTER LISTENER: got `clear` from #{:i.i client}"
              clear
            {client, :size} ->
              log "MASTER LISTENER: got `size` from #{:i.i client}"
              send(client, {:size_response, size})
            _ ->
              IO.puts :stderr, "Unexpected message received"
          end
          master_listen
        end
      end

      def master_broadcast(payload) do
        slaves = (MasterState.get(__MODULE__) || %{})[:slaves] || %{}
        Enum.each slaves, fn({client, client_info}) ->
          log "MASTER: sending #{:i.i payload} to #{:i.i client}"
          send client, payload
        end
      end

      def master_receive_pid_name do
        ((__MODULE__ |> to_string) <> "." <> "Master" <> ".Receive") |> String.to_atom
      end

      def master_receive_pid do
        :global.whereis_name master_receive_pid_name
      end

      def master? do
        MasterState.marked? __MODULE__
      end

      defp master_assigned? do
        Enum.find :global.registered_names, fn(name) ->
          name == __MODULE__
        end
      end
    end
  end
end
